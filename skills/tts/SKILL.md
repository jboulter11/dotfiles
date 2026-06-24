---
name: tts
description: Read text aloud using the local OpenVox TTS server. Use when asked to read something aloud, speak text, say something out loud, use voice output, narrate, or pronounce/announce anything audibly.
---

Read the given text aloud using the local OpenVox TTS API.

## Execution

Run this skill in a **background subagent** (`run_in_background: true`) to avoid blocking the conversation. The agent handles the full workflow independently and the user hears the audio without interrupting their flow.

All commands must run outside the sandbox (`dangerouslyDisableSandbox: true`) since the server is local.

## Defaults

- **Server**: `http://127.0.0.1:8000/v1`
- **Model**: `qwen3-tts-medium` (best quality/latency balance; streams incrementally)
- **Voice**: `3F0972FE-C5E8-43D1-9B09-4245F646094F` (Jim)
- **Language**: `en`
- **Speed**: `1.5` (sent under `model_parameters`; **currently ignored server-side** — see Notes)

## Preferred: streaming playback (gapless)

Use the bundled `stream_play.py`. It opens an SSE stream, decodes each `audio.chunk`, and feeds raw PCM into a single long-lived `sox` (`play`) process so audio starts within ~1s and plays without gaps. Requires `sox` (`play` on PATH).

```
python3 ~/src/dotfiles/skills/tts/stream_play.py --text "<TEXT>"
```

For long text (e.g. a whole document), prefer `--file` or stdin over a huge inline `--text`:

```
python3 ~/src/dotfiles/skills/tts/stream_play.py --file ~/path/to/notes.md
echo "<TEXT>" | python3 ~/src/dotfiles/skills/tts/stream_play.py
```

Flags / overrides:
- `--text <s>` — speak inline text.
- `--file <path>` — speak the contents of a file (`~` expanded).
- `--model <id>` — TTS model id (default `qwen3-tts-medium`).
- `--voice <name|id>` — voice id, or a name like `Bella`; resolved against the model's voice list (default Jim).
- `--speed <n>` — speech speed (default 1.5).
- Source precedence: `--text`, then `--file`, then stdin.

## Fallback: non-streaming (omnivoice)

`omnivoice` has the most voices (294) but does **not** stream — it synthesizes the whole utterance and returns a single chunk, so there's no latency benefit. Use it when a specific omnivoice-only voice is requested, or when `sox` isn't available (play the resulting file with `afplay`).

1. Warm the model (idempotent):
   ```
   curl -s -X POST http://127.0.0.1:8000/v1/models/omnivoice/load
   ```
2. Generate:
   ```
   curl -s -X POST http://127.0.0.1:8000/v1/audio/speech \
     -H "Content-Type: application/json" \
     -d '{"model":"omnivoice","input":"<TEXT>","language":"en","voice":"3F0972FE-C5E8-43D1-9B09-4245F646094F","response_format":"wav"}' \
     -o "$TMPDIR/tts.wav"
   ```
3. Play:
   ```
   afplay "$TMPDIR/tts.wav"
   ```

## Choosing a model

**Default case: do not query the server.** Just use the default (`qwen3-tts-medium`) — pass nothing extra to `stream_play.py`. The model list below is a snapshot for reference only.

**Only if the user explicitly names a model to use**, query the live list to resolve/validate the exact id (the installed set changes as models are added or removed):

```
curl -s http://127.0.0.1:8000/v1/models | python3 -c "import json,sys; [print(m['id'],'| voices',m['voice_count']) for m in json.load(sys.stdin)['data']]"
```

Then pass it with `--model <id>` (e.g. `--model qwen3-tts-large`). If the requested model isn't in the list, tell the user and fall back to the default.

Likewise, if the user names a **voice**, pass `--voice <name>` — the script queries the model's voice list and matches by name or id, so you don't have to look up the id yourself. (To preview the options: `curl -s "http://127.0.0.1:8000/v1/models/<model>/voices?language=en"`.)

## Models (as of last check)

Time-to-first-audio measured on the same passage with the Jim voice:

| Model | Voices | Streams? | TTFA | Notes |
|---|---|---|---|---|
| `qwen3-tts-medium` | 149 | ✅ | ~0.80s | **Default** — best quality/latency balance |
| `qwen3-tts-large` | 149 | ✅ | ~1.58s | Higher quality target, ~2x slower to start |
| `qwen3-tts-small` | 149 | ✅ | ~0.78s | Fastest qwen, lower quality |
| `pocket-tts` | 112 | ✅ | ~0.29s | Lowest latency overall |
| `chatterbox-turbo-large` | 38 | ✅ | ~1.43s | Stochastic (temperature-based) |
| `omnivoice` | 294 | ❌ single chunk | ~3.26s | Most voices; no streaming benefit |
| `kokoro` | 54 | advertised | — | Often not installed; verify before use |

## Notes

- If the server is unavailable (connection refused), tell the user local voice output is currently unavailable.
- If the API returns 429 ("another generation or preload request is already in progress"), wait briefly and retry — only one generation/preload can run at a time.
- The user may override model, voice, language, or speed — honor any explicit overrides.
- **Speed is not yet respected server-side.** Verified: output PCM is byte-identical across `speed` 0.5/1.0/3.0 at a constant 24kHz/mono/16-bit, under both `parameters` and `model_parameters` keys, streaming or not. We send `model_parameters.speed` (the key the app uses) anyway so it takes effect once the server fixes it. The server also silently accepts unknown keys (no validation), so a 200 response does not mean a param was applied.
- For extremely long text (>500 words), consider summarizing or asking whether to read the full text.
- `omnivoice` returns one chunk regardless of `stream:true` or text length; the others stream incrementally.
