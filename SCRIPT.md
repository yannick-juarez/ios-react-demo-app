# Loom Script (max 5 min) — Share Extension + Reaction Unlock

## 0) Opening (0:00 - 0:20)

Hi, I will present a retention-driven feature called **Share Extension + Reaction Unlock**.
The idea is simple: I can share content from any iOS app to a friend, and the friend must record a short reaction video to unlock it.
Then, the original content plus the reaction are returned to me.

## 1) Problem and Objective (0:20 - 0:55)

The problem I focused on is that many social shares are passive and low-value.
Users send something, the receiver opens it, and the interaction ends quickly.

My objective was to create a loop that increases return intent:
- stronger social reciprocity,
- more memorable interactions,
- and better short-term retention signals (D1/D7).

I also wanted the feature to stay true to BeReal's core essence: spontaneity, authenticity, and focus on the present moment.

This feature is not in BeReal today, and it creates a new sharing behavior: **react-to-unlock**.

## 2) User Experience Walkthrough (0:55 - 2:00)

Now I will walk through the end-to-end flow:

1. Sender flow:
- From any app, the sender taps iOS Share and selects our app extension.
- They pick one friend and send.

2. Receiver flow:
- Receiver gets a locked inbox card: "React to unlock".
- They start recording with front camera.
- Important UX rule: no content preview before recording starts, to preserve authenticity.

3. Unlock and return:
- After reaction upload and validation, content is unlocked for the receiver.
- The bundle (original content + reaction) is returned to the sender inbox.

Design choices:
- camera pre-warm before countdown,
- fast start to recording,
- minimal UI during capture,
- clear recovery for errors.

## 3) Retention Rationale and Metrics (2:00 - 2:55)

Why this should improve retention:
- It converts one-way sharing into a reciprocal loop.
- Both users have a reason to come back: receiver to unlock, sender to watch the reaction.

I track success with 5 metrics:
- Reaction Unlock Rate,
- Loop Completion Rate,
- Share-to-First-Loop Time,
- D7 retention uplift in experiment,
- Guardrails like abandonment and notification opt-out.

Important note: metric thresholds are directional estimates.
They are explicitly marked as examples and should be calibrated with real baseline data.

## 4) Tracking and Experiment Plan (2:55 - 3:55)

Tracking plan covers the full funnel:
- `share_extension_opened`,
- `share_sent`,
- `share_lock_screen_opened`,
- `reaction_capture_started/completed`,
- `unlock_success`,
- `loop_return_sent/opened`,
- plus error events like `unlock_failed` and `reaction_capture_abandoned`.

All events carry `share_id` for end-to-end reconstruction.

A/B test setup:
- Control: normal share, no reaction required.
- Variant: reaction required before unlock.
- Primary metric: Loop Completion Rate.
- Guardrails: crashes, opt-out delta, abuse reports.
- Decision:
	- ship if primary metric is significantly positive and guardrails are healthy,
	- iterate if signal is partial,
	- kill if no impact or harmful friction.

## 5) Technical Choices (3:55 - 4:40)

Short spec choices:
- Front-end states: `loading`, `locked`, `recording`, `preview`, `uploading`, `success`, `error`, `blocked`, `expired`.
- Core models: `ShareRequest`, `Reaction`.
- Core APIs:
	- `POST /v1/shares`,
	- `GET /v1/shares/{id}`,
	- `POST /v1/shares/{id}/reaction`,
	- `POST /v1/shares/{id}/complete`,
	- `GET /v1/inbox`.
- Reliability:
	- idempotency on create/upload,
	- retry strategy on upload,
	- reconciliation for completion race conditions.

### Architecture trade-offs (add ~25s if asked)

- I prioritized a modular front-end architecture with local persistence to deliver a fully testable user flow quickly.
- I kept backend endpoints as explicit contracts, but did not couple delivery to server availability.
- I integrated a typed state machine for flow safety, while accepting that some advanced edge paths are still MVP-level.
- I centralized key dependencies in composition root to keep the flow injectable and easier to evolve.

## 6) Assumptions, Limits, and Close (4:40 - 5:00)

Main assumptions:
- users accept a small amount of friction for higher social value,
- 1-to-1 scope is enough for MVP learning.

Current non-goals:
- no editing tools,
- no group share,
- no offline flow.

Known gaps (explicit):
- recipient selection is currently mocked for demo simplicity,
- backend is represented as contract + local behavior (not production API-wired),
- some analytics properties remain placeholder-level until real identity/session wiring.

That is the proposal: a focused retention loop, measurable end-to-end, with a clear rollout and decision framework.

---

## Optional recording tips (not spoken)

- Keep camera bubble on, product visible full screen.
- Show one full loop quickly, then jump to metrics/tracking docs.
- If repository is public, avoid restricted brand names per instructions.
