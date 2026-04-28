# Spec (Concise) — Share Extension + Reaction Unlock

## Scope

User A shares content from any iOS app via BeReal Share Extension to User B.
User B must record a short reaction video to unlock the content.
Then, original content + reaction video are returned to User A.

## 1) Front-end behavior and states

### Main flow

1. Sender opens Share Extension from a third-party app, picks one friend, taps Send.
2. Receiver gets a locked inbox card with CTA: React to unlock.
3. Receiver records reaction (front camera, countdown, reveal at recording start).
4. Receiver reviews and sends reaction.
5. Content unlocks for receiver; bundle is returned to sender inbox.

### UI behavior requirements

- No content preview before recording starts (authenticity rule).
- Camera is pre-warmed before countdown (speed rule).
- Recording starts automatically when countdown ends.
- If app backgrounds during recording, capture is cancelled and session remains resumable.

### Core states

`loading`, `locked`, `recording`, `preview`, `uploading`, `success`, `error`, `blocked`, `expired`

## 2) Data model / API contract

### Data model (minimum)

`ShareRequest`
- `id` (UUID)
- `sender_user_id`, `receiver_user_id`
- `content_type` (url|image|video|text)
- `content_ref` (signed URL/reference)
- `status` (sent|delivered|opened|reaction_required|unlocked|completed|failed|expired)
- `created_at`, `expires_at`

`Reaction`
- `id` (UUID)
- `share_id` (FK)
- `receiver_user_id`
- `video_url`
- `duration_sec`
- `moderation_status` (pending|accepted|rejected)

### API endpoints

- `POST /v1/shares`: create share from extension
- `GET /v1/shares/{id}`: fetch/poll share state
- `POST /v1/shares/{id}/reaction`: upload reaction and request unlock
- `POST /v1/shares/{id}/complete`: finalize and return bundle (idempotent)
- `GET /v1/inbox`: fetch locked shares and returned bundles

### Async events (backend)

`share.created`, `share.delivered`, `reaction.uploaded`, `share.unlocked`, `share.returned_to_sender`, `share.failed`

## 3) Edge cases and error handling

- Camera permission denied: show blocked screen + Open Settings CTA; no unlock bypass.
- Upload/network failure: keep local draft, auto-retry + manual retry.
- Receiver abandons capture: keep item locked, allow resume from inbox.
- Invalid recipient: fail fast if possible; otherwise async failed status + sender feedback.
- Unsupported content type: block send in extension with inline error.
- Share expired (TTL): show expired state to receiver and sender.
- Double submit: idempotency keys on share creation and reaction upload.
- Moderation rejection: withhold unlock per policy, offer recapture if allowed.
- Completion race condition: idempotent complete endpoint + reconciliation job.

## Non-goals (MVP)

- No editing tools (filters/trimming)
- No group sharing (1-to-1 only)
- No offline flow
