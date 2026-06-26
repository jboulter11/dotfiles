---
name: tts
description: Read text aloud using the local OpenVox TTS server. Use when asked to read something aloud, speak text, say something out loud, use voice output, narrate, or pronounce/announce anything audibly.
---

Read the given text aloud using the local OpenVox TTS API.

## Execution

The server plays audio itself — pass `"play": true` and it streams to the local speakers. No script, no `sox`, no client-side decoding. Just one `curl`.

The server plays audio in its own process, so the request returns *before* playback finishes — the spoken audio keeps going after `curl` exits. The response only takes as long as synthesis (a few seconds for short text, tens of seconds for a long document), not as long as the speech.

Still run the `curl` as a **background Bash command** (`run_in_background: true`) so the synthesis wait doesn't block the conversation, especially for long text. Run it **outside the sandbox** (`dangerouslyDisableSandbox: true`) since the server is local.

**One request per utterance — do NOT fire requests back-to-back.** Playback does not queue: a new request interrupts whatever is currently playing and cuts it off. Since the request returns before playback finishes, sending a second `curl` while the first is still being spoken kills the first mid-sentence. Put everything you want heard into a single request's `input`. (Verified.)

## Speak it

```
curl -s -X POST http://127.0.0.1:8000/v1/audio/speech \
  -H "Content-Type: application/json" \
  -d '{"model":"qwen3-tts-medium","input":"<TEXT>","language":"en","voice":"3F0972FE-C5E8-43D1-9B09-4245F646094F","play":true,"parameters":{"speed":1.5}}' \
  -o /dev/null
```

Swap `"model"` to `pocket-tts` for long text (see below). For long text, also build the JSON body with `python3 -c 'import json,sys; ...'` (or write the text to a file and read it in) so quoting/newlines in `<TEXT>` can't break the request.

## Model: short vs long text

Pick the model by how long the audio will be. The dividing line is **~1 minute of speech** — roughly **200 words** at the default 1.5x speed:

- **Short (≲1 min / ≲200 words) → `qwen3-tts-medium`** (default). Best quality, but it breaks down on long input — after a few minutes of continuous speech it degrades and stops producing accurate words. (Verified: the breakdown is the model, not the size tier — `qwen3-tts-large` degrades the same way on a ~5-minute clip, and it's far too slow to synthesize long text anyway.)
- **Long (≳1 min / ≳200 words) → `pocket-tts`**. Verified coherent on a ~900-word passage with no degradation, and far faster than the large qwen models. Use it for anything past about a minute of speech — a document, a long answer, multiple paragraphs.

When the length is borderline, prefer `pocket-tts` — a slightly lower-quality voice that says every word beats a higher-quality one that disintegrates halfway through. Both use the same Jim voice id and the same request shape; just swap `"model"`.

Bigger qwen variants are **not** a fix for long text: they break down the same way and are much slower, so they don't earn their cost. There's no qwen tier to escalate to — switch to `pocket-tts` instead.

## Defaults

- **Server**: `http://127.0.0.1:8000/v1`
- **Model**: `qwen3-tts-medium` for short text (≲1 min), `pocket-tts` for long text (≳1 min) — see above
- **Voice**: `3F0972FE-C5E8-43D1-9B09-4245F646094F` (Jim) — present in both models
- **Language**: `en`
- **Speed**: `1.5`, sent as `parameters: {speed: 1.5}`

The user may override any of these — honor explicit overrides. `parameters.speed` is respected server-side (verified: WAV duration scales with the value).

## Choosing a model

**Default case: do not query the server.** Use `qwen3-tts-medium` (short) or `pocket-tts` (long) per the rule above. The table below is a snapshot for reference only.

**Only if the user explicitly names a model**, query the live list to resolve/validate the exact id (the installed set changes):

```
curl -s http://127.0.0.1:8000/v1/models | python3 -c "import json,sys; [print(m['id'],'| voices',m['voice_count']) for m in json.load(sys.stdin)['data']]"
```

Then pass it as `"model":"<id>"`. If the requested model isn't in the list, tell the user and fall back to the default.

If the user names a **voice**, resolve its id from the model's voice list and pass it as `"voice":"<id>"`:

```
curl -s "http://127.0.0.1:8000/v1/models/<model>/voices?language=en" | python3 -c "import json,sys; [print(v['id'],'|',v.get('name','?')) for v in json.load(sys.stdin)['data']]"
```

## Models (as of last check)

| Model | Voices | Notes |
|---|---|---|
| `qwen3-tts-medium` | 149 | **Default for short text (≲1 min)** — best quality, but degrades on long input |
| `qwen3-tts-large` | 149 | Higher quality but much slower; same long-text breakdown — not a long-text fix |
| `qwen3-tts-small` | 149 | Fastest qwen, lower quality |
| `pocket-tts` | 112 | **Default for long text (≳1 min)** — stays coherent over long passages; low latency |
| `chatterbox-turbo-large` | 38 | Stochastic (temperature-based) |
| `omnivoice` | 294 | Most voices |
| `kokoro` | 54 | Often not installed; verify before use |

## Notes

- If the server is unavailable (connection refused), tell the user local voice output is currently unavailable.
- If the API returns 429 ("another generation or preload request is already in progress"), wait briefly and retry — only one generation/preload can run at a time.
- The first call to a cold model is slower (it loads on demand). To pre-warm: `curl -s -X POST http://127.0.0.1:8000/v1/models/<model>/load -d ""`.
- Length alone isn't a problem once you're on `pocket-tts` (verified coherent at ~900 words) — switch models rather than truncating. Only for genuinely huge input (many minutes of speech) consider summarizing or asking whether to read the whole thing.
