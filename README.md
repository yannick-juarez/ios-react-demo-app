# Share Extension + Reaction Unlock

From any iOS app, a sender shares content to a receiver through the BeReal Share Extension.
The receiver must record a short reaction video to unlock the content.
The app then returns a bundle to the sender: original content + reaction video.

## Quick Start (Local)

- Build (simulator, no signing):
  - `xcodebuild -project React.xcodeproj -scheme React -configuration Debug -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build`
- Main app target: `React`
- Share extension target: `Share`

## Architecture

- `Apps/ReactionApp`: app entry point, composition root, root navigation.
- `Packages/CoreDomain`: domain models, repository/use case protocols.
- `Packages/CoreInfrastructure`: concrete use cases, orchestration, notification scheduler.
- `Packages/CorePersistence`: app group inbox store + local demo store.
- `Packages/ReactionFeature`: receiver unlock flow UI.
- `Packages/ShareImportFeature`: share extension controller and request flow.
- `Packages/AnalyticsKit`: typed events + provider abstraction.

## Product Direction

- Objective: increase reciprocal interactions, not raw share volume.
- Core lever: social obligation (react to unlock) to deepen engagement.
- Main risk: excessive friction causing abandonment.
- MVP mitigation: short capture, clear CTA, retry path, strict 1:1 scope.

## User Journey (MVP)

1. Sender opens iOS share sheet in a third-party app and chooses BeReal.
2. Sender selects one friend, optionally adds a hint, then sends.
3. Receiver gets notified and opens a locked inbox card.
4. Receiver records and confirms a short reaction video.
5. Content unlocks for receiver.
6. Bundle is returned to sender inbox.

## Tracking Plan

Core funnel events:
- `share_extension_opened`
- `share_target_selected`
- `share_sent`
- `share_notification_sent`
- `share_lock_screen_opened`
- `reaction_capture_started`
- `reaction_capture_completed`
- `unlock_success`
- `loop_return_sent`
- `loop_return_opened`

Drop-off / error events:
- `reaction_capture_abandoned`
- `unlock_failed`

Tracking rules:
- Propagate `share_id` on every event.
- UTC timestamps + local time context.
- Add client `event_id` for deduplication.
- No media payload in analytics; metadata only.

## Experiment Plan (A/B)

- Hypothesis: reaction-to-unlock increases loop completion and short-term retention.
- Split: user-level 50/50, stable assignment.
- Control: immediate content access.
- Variant: reaction required before unlock + return bundle.
- Primary metric: Loop Completion Rate.
- Secondary: Unlock Rate, Loop Time, D7 uplift.
- Duration: 2-3 weeks minimum, no early peeking.
- Decision:
  - Ship if primary is positive/significant and guardrails hold.
  - Iterate if partial signal exists.
  - Stop if primary is negative/null or guardrails degrade.

## MVP Trade-Offs

- Recipient picker is intentionally mocked for demo flow.
- Identities and some values remain demo-oriented.
- API contract is production-ready in structure; runtime is local/mock.
