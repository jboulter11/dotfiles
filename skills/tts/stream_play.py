#!/usr/bin/env python3
"""Stream TTS audio from the local OpenVox server and play chunks as they arrive.

Reads text from --text (or stdin), opens an SSE stream against /v1/audio/speech,
and feeds each audio.chunk's PCM into a single long-lived sox `play` process the
moment it decodes — so playback starts while the rest is still being synthesized,
and stays gapless. Falls back cleanly if the server is down.

Usage:
  stream_play.py --text "Hello there"
  stream_play.py --file ~/notes.md
  echo "Hello there" | stream_play.py
  stream_play.py --text "Faster" --speed 2.0
  stream_play.py --text "Different model" --model qwen3-tts-large
  stream_play.py --text "Different voice" --voice Bella
"""

import argparse
import base64
import json
import os
import struct
import subprocess
import sys
import urllib.error
import urllib.request

BASE_URL = "http://127.0.0.1:8000/v1"
DEFAULT_MODEL = "qwen3-tts-medium"
DEFAULT_VOICE = "3F0972FE-C5E8-43D1-9B09-4245F646094F"  # Jim
LANGUAGE = "en"
# NOTE: the server currently ignores `speed` (verified: identical PCM at any
# value). We still send it under `model_parameters` — the key the OpenVox app
# uses — so playback speeds up automatically once the server honors it.
DEFAULT_SPEED = 1.5


def warm_model(model: str) -> None:
    req = urllib.request.Request(
        f"{BASE_URL}/models/{model}/load", method="POST", data=b""
    )
    try:
        urllib.request.urlopen(req, timeout=120).read()
    except urllib.error.URLError:
        pass  # warming is best-effort; the speech call will surface real errors


def resolve_voice(model: str, language: str, wanted: str) -> str:
    """Resolve a voice name/id to a valid voice id for this model+language.

    Accepts an exact voice id, or a case-insensitive match on the voice's
    display name (e.g. "bella") or id substring. Returns `wanted` unchanged if
    the lookup fails, letting the server surface any error.
    """
    url = f"{BASE_URL}/models/{model}/voices?language={language}"
    try:
        with urllib.request.urlopen(url, timeout=30) as resp:
            voices = json.loads(resp.read()).get("data", [])
    except urllib.error.URLError:
        return wanted

    low = wanted.lower()
    for v in voices:  # exact id wins
        if v.get("id") == wanted:
            return wanted
    for v in voices:  # then exact name match
        if v.get("name", "").lower() == low:
            return v["id"]
    for v in voices:  # then substring on name or id
        if low in v.get("name", "").lower() or low in v.get("id", "").lower():
            return v["id"]

    names = ", ".join(v.get("name", "?") for v in voices[:12])
    print(
        f"Voice '{wanted}' not found for {model}/{language}. "
        f"Available include: {names}. Using '{wanted}' as-is.",
        file=sys.stderr,
    )
    return wanted


def parse_wav(buf: bytes) -> "tuple[int, int, int, bytes]":
    """Return (sample_rate, channels, bits, pcm_bytes) from a WAV chunk.

    Walks the RIFF chunks rather than assuming a fixed 44-byte header so a
    non-canonical header (extra fmt bytes, LIST chunks) can't desync playback.
    """
    if buf[:4] != b"RIFF" or buf[8:12] != b"WAVE":
        raise ValueError("not a WAV chunk")
    rate = channels = bits = 0
    pcm = b""
    pos = 12
    while pos + 8 <= len(buf):
        cid = buf[pos : pos + 4]
        size = struct.unpack_from("<I", buf, pos + 4)[0]
        body = buf[pos + 8 : pos + 8 + size]
        if cid == b"fmt ":
            channels = struct.unpack_from("<H", body, 2)[0]
            rate = struct.unpack_from("<I", body, 4)[0]
            bits = struct.unpack_from("<H", body, 14)[0]
        elif cid == b"data":
            pcm = body
        pos += 8 + size + (size & 1)  # chunks are word-aligned
    return rate, channels, bits, pcm


def stream(
    text: str,
    model: str = DEFAULT_MODEL,
    voice: str = DEFAULT_VOICE,
    speed: float = DEFAULT_SPEED,
) -> int:
    body = json.dumps(
        {
            "model": model,
            "input": text,
            "language": LANGUAGE,
            "voice": voice,
            "stream": True,
            "model_parameters": {"speed": speed},
        }
    ).encode()
    req = urllib.request.Request(
        f"{BASE_URL}/audio/speech",
        data=body,
        headers={"Content-Type": "application/json"},
        method="POST",
    )

    chunks = 0
    player = None  # single long-lived sox `play` reading raw PCM from stdin
    try:
        with urllib.request.urlopen(req, timeout=300) as resp:
            event = None
            for raw in resp:
                line = raw.decode("utf-8", "replace").rstrip("\n")
                if line.startswith("event:"):
                    event = line[len("event:") :].strip()
                elif line.startswith("data:"):
                    payload = line[len("data:") :].strip()
                    if event == "audio.chunk":
                        data = json.loads(payload)
                        audio_b64 = data.get("audio")
                        if not audio_b64:
                            continue
                        rate, channels, bits, pcm = parse_wav(
                            base64.b64decode(audio_b64)
                        )
                        if player is None:
                            # Start one continuous player keyed to the first
                            # chunk's format; feed every chunk's PCM into it so
                            # playback is gapless (no per-chunk process relaunch).
                            player = subprocess.Popen(
                                [
                                    "play", "-q",
                                    "-t", "raw",
                                    "-r", str(rate),
                                    "-c", str(channels),
                                    "-b", str(bits),
                                    "-e", "signed-integer",
                                    "-",
                                ],
                                stdin=subprocess.PIPE,
                                stderr=subprocess.DEVNULL,
                            )
                        player.stdin.write(pcm)
                        chunks += 1
                    elif event == "response.completed":
                        break
    except urllib.error.HTTPError as e:
        detail = e.read().decode("utf-8", "replace")
        print(f"TTS request failed ({e.code}): {detail}", file=sys.stderr)
        return 1
    except urllib.error.URLError as e:
        print(f"Local voice output unavailable: {e.reason}", file=sys.stderr)
        return 2
    finally:
        if player is not None and player.stdin is not None:
            player.stdin.close()
            player.wait()

    print(f"Played {chunks} streamed chunk(s).")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description="Stream OpenVox TTS playback.")
    parser.add_argument("--text", help="Text to speak inline.")
    parser.add_argument(
        "--file", help="Read text to speak from this file path (~ expanded)."
    )
    parser.add_argument(
        "--model",
        default=DEFAULT_MODEL,
        help=f"TTS model id (default {DEFAULT_MODEL}).",
    )
    parser.add_argument(
        "--voice",
        default=DEFAULT_VOICE,
        help="Voice id or name (e.g. 'Bella'); resolved against the model's "
        "voice list. Defaults to Jim.",
    )
    parser.add_argument(
        "--speed",
        type=float,
        default=DEFAULT_SPEED,
        help=f"Speech speed sent to the server (default {DEFAULT_SPEED}; "
        "currently ignored server-side).",
    )
    args = parser.parse_args()

    # Source precedence: --text, then --file, then stdin.
    if args.text is not None:
        text = args.text
    elif args.file is not None:
        path = os.path.expanduser(args.file)
        try:
            with open(path, encoding="utf-8") as f:
                text = f.read()
        except OSError as e:
            print(f"Could not read {args.file}: {e}", file=sys.stderr)
            return 3
    else:
        text = sys.stdin.read()

    text = text.strip()
    if not text:
        print("No text provided.", file=sys.stderr)
        return 3

    warm_model(args.model)
    voice = args.voice if args.voice == DEFAULT_VOICE else resolve_voice(
        args.model, LANGUAGE, args.voice
    )
    return stream(text, model=args.model, voice=voice, speed=args.speed)


if __name__ == "__main__":
    sys.exit(main())
