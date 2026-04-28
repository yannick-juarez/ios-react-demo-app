# Spec — Share Extension + Reaction Unlock

## Scope

User A shares content from any iOS app to User B via Share Extension.
User B must record a short reaction video to unlock the content.
The system returns a bundle to User A: original content + reaction video.

Implementation status:
- Runtime is front-end first (local persistence + mocked backend behavior).
- API below is the production contract.

## 1) Front-End Behavior

Main flow:
1. Sender opens Share Extension, selects one friend, sends.
2. Receiver sees a locked card: React to unlock.
3. Receiver records and confirms a short front-camera reaction.
4. Content unlocks for receiver.
5. Bundle is returned to sender inbox.

UI requirements:
- No content preview before recording starts.
- Camera pre-warm before countdown.
- Auto-start recording when countdown reaches zero.
- If app backgrounds during capture, cancel capture and keep flow resumable.

Core states:
- `loading`, `locked`, `recording`, `preview`, `uploading`, `success`, `error`, `blocked`, `expired`

MVP acceptance criteria:
- Locked content remains hidden until recording begins.
- Capture starts automatically at countdown end.
- Background interruption during capture returns to resumable locked state.
- Permission denial shows blocked UI with Settings CTA.
- Abandoning from preview keeps item locked.
- Reaction save failure prevents unlock and emits telemetry.

## 2) Data Model and API Contract

Data model (minimum):

`ShareRequest`
- `id` (UUID)
- `sender_user_id`, `receiver_user_id`
- `content_type` (`url|image|video|text`)
- `content_ref` (signed URL/reference)
- `status` (`sent|delivered|opened|reaction_required|unlocked|completed|failed|expired`)
- `created_at`, `expires_at`

`Reaction`
- `id` (UUID)
- `share_id` (FK)
- `receiver_user_id`
- `video_url`
- `duration_sec`
- `moderation_status` (`pending|accepted|rejected`)

API endpoints:
- `POST /v1/shares`
- `GET /v1/shares/{id}`
- `POST /v1/shares/{id}/reaction`
- `POST /v1/shares/{id}/complete` (idempotent)
- `GET /v1/inbox`

Async backend events:
- `share.created`, `share.delivered`, `reaction.uploaded`, `share.unlocked`, `share.returned_to_sender`, `share.failed`

## 3) Edge Cases and Error Handling

- Camera denied: blocked screen + Settings CTA, no bypass.
- Upload/network failure: keep local draft, auto-retry + manual retry.
- Capture abandoned: item stays locked, resumable from inbox.
- Invalid recipient: fail fast or mark failed asynchronously with sender feedback.
- Unsupported content type: block send with inline extension error.
- Expired share (TTL): explicit expired state for sender and receiver.
- Double submit: idempotency keys on create and reaction upload.
- Moderation rejection: no unlock, optional recapture policy.
- Completion race: idempotent complete endpoint + reconciliation.

## Non-Goals (MVP)

- No editing tools (filters/trimming)
- No group sharing (1:1 only)
- No offline end-to-end loop
