

## Feature: Share Extension + Reaction Unlock

From any iOS app, a user (sender) can share content via BeReal's Share Extension to a friend (receiver).
The receiver must record a short reaction video to unlock and view the content.
The bundle — original content + reaction video — is then returned to the sender.

---

## Quick start (local)

- Build command (simulator, no signing):
   - `xcodebuild -project React.xcodeproj -scheme React -configuration Debug -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build`
- Main app target: `React`
- Share extension target: `Share`

---

## Architecture at a glance

- `Apps/ReactionApp`: app entry point, composition root, root navigation.
- `Packages/CoreDomain`: domain models, state machine contract, repository/use case protocols.
- `Packages/CoreInfrastructure`: concrete use cases, local repository orchestration, notification scheduler.
- `Packages/CorePersistence`: local stores (app group inbox + local demo storage).
- `Packages/ReactionFeature`: receiver unlock flow UI (capture, preview, playback).
- `Packages/ShareImportFeature`: share extension controller and request UI.
- `Packages/AnalyticsKit`: event catalog + provider abstraction.

---

## Implementation status (current)

| Area | Status | Notes |
|---|---|---|
| Share Extension ingest (image) | Implemented | Reads shared image and persists draft in App Group store |
| Receiver lock/unlock UI flow | Implemented | Locked content, capture, preview, send flow |
| Reaction flow state machine | Implemented (partial integration) | Core states modeled and used in incoming flow orchestration |
| Background interruption handling during capture | Implemented | Capture is interrupted and flow returns to resumable locked state |
| Local persistence | Implemented | Local demo storage + app group draft store |
| Analytics event instrumentation | Implemented (demo-level) | Typed event catalog and key funnel events tracked |
| Real backend integration | Planned | Current implementation is front-end first with local persistence |
| Group sharing | Planned | Out of MVP scope |
| Offline end-to-end behavior | Planned | Out of MVP scope |

---

## Known gaps / trade-offs

- Recipient picker is intentionally mocked (single-path demo behavior).
- Some values are still demo-oriented (sample identities and placeholders).
- API contract is specified for design rigor, but runtime integration remains local/mock for MVP.

---

## 1) One-pager strategy

- Why this feature: turn a passive "share" into a reciprocal social interaction (content + authentic emotion), far more memorable than a read receipt.
- Primary retention lever: social obligation. The receiver must act (record themselves) to consume the content, creating a meaningful commitment loop.
- Secondary lever: content depth. A share becomes a short, contextual video conversation rather than a one-way broadcast.
- Sender need addressed: "I want to see my friend's real reaction, not just a 'seen'."
- Receiver need addressed: "I want access to the content, in a fun and social way."
- Target behavior: more intentional shares and a higher rate of complete loops (send → react → return).
- Expected retention impact: increase in D1/D7 return rate among users who complete at least one reciprocal loop — users who invest in a loop have a stronger reason to come back.
- Expected engagement impact: higher open rate on received items and more video interaction sessions.
- Product differentiation: reaction-to-unlock is rare; it aligns strongly with BeReal's authenticity DNA and creates a new sharing primitive distinct from DMs or Stories.
- Main risk: friction too high leading to loop abandonment; mitigation via minimal UX (short capture, clear CTA, retry allowed), 1-to-1 scope only at launch.

---

## 2) User journey

- The sender is in a third-party app (Instagram, Safari, Photos, etc.) and taps the native iOS Share button.
- They select the BeReal Share Extension from the share sheet.
- In the extension UI, they pick one friend, optionally add a hint, and send.
- The receiver gets a push notification: "You received something — record your reaction to see it."
- They open BeReal and see the locked item in their inbox with the CTA "React to unlock".
- They record a short reaction video (product-constrained: max duration, cancel/retake available).
- Once the reaction is validated, the original content unlocks immediately.
- The system packages the original content + reaction video into a bundle.
- The sender receives the bundle in their BeReal inbox and can view the reaction.
- Both users can continue the exchange (reply, secondary reaction, etc.).

---

## 3) Key metrics

> Note: all numeric thresholds below are directional estimates and must be calibrated against real baseline data before launch.

1. **Reaction Unlock Rate** *(core metric)*
   - Definition: % of received locked items that are successfully unlocked via a reaction video.
   - Target: >= ~40–50% in early cohorts. Rationale: users who open a locked item have already expressed intent; a majority should convert given low-friction capture. Below 35% would signal the unlock step is too costly.

2. **Loop Completion Rate**
   - Definition: % of sent shares that result in the bundle being returned to the sender.
   - Target: >= ~30–35% at launch, trending upward week-over-week. Rationale: lower than Unlock Rate since it requires both sides to be active; 1 in 3 loops completing is a reasonable floor for a new social mechanic.

3. **Share-to-First-Loop Time**
   - Definition: median time between share sent and bundle returned to sender.
   - Target: P50 < 10 min, P90 < 2 h. Rationale: social reactions are time-sensitive; anything beyond a few hours risks the sender losing context or interest. Thresholds are illustrative and should be validated against messaging norms in the user base.

4. **D7 Retention uplift** *(experiment metric)*
   - Definition: difference in 7-day retention between exposed cohort and control in the A/B test.
   - Target: a statistically significant uplift of +1.5 to +3 percentage points without guardrail degradation. Rationale: completing a social loop creates a reason to return; the range reflects typical retention lift observed in social reciprocity features, but must be validated experimentally.

5. **Guardrail — Negative Friction Signals**
   - Definition: lock screen abandonment rate + notification opt-out delta vs. control.
   - Threshold: abandon rate < ~25%, notification disable delta <= +0.5 pp vs. control. Rationale: these are kill-switch indicators. If the mechanic feels coercive, abandonment will spike sharply — 25% is an estimated tolerance ceiling before the feature does more harm than good.

---

## 4) Tracking plan

### Funnel events

1. `share_extension_opened`
   - Trigger: user opens the BeReal Share Extension from a third-party app.
   - Properties: `sender_id`, `source_app`, `content_type` (url/image/video/text), `os_version`, `app_version`.

2. `share_target_selected`
   - Trigger: user selects a friend in the extension.
   - Properties: `sender_id`, `receiver_id`, `source_app`, `content_type`, `candidate_count`.

3. `share_sent`
   - Trigger: share confirmed and dispatched.
   - Properties: `share_id`, `sender_id`, `receiver_id`, `source_app`, `content_type`, `payload_size_bucket`, `sent_at`.

4. `share_notification_sent`
   - Trigger: push notification delivered to receiver.
   - Properties: `share_id`, `receiver_id`, `send_channel` (push/in-app), `delivery_status`.

5. `share_lock_screen_opened`
   - Trigger: receiver opens the locked item experience.
   - Properties: `share_id`, `receiver_id`, `open_source` (push/inbox), `latency_from_send_sec`.

6. `reaction_capture_started`
   - Trigger: receiver taps "React to unlock" CTA.
   - Properties: `share_id`, `receiver_id`, `attempt_index`, `camera_permission_state`.

7. `reaction_capture_completed`
   - Trigger: reaction video recorded and locally validated.
   - Properties: `share_id`, `receiver_id`, `reaction_duration_sec`, `retake_count`, `file_size_bucket`.

8. `unlock_success`
   - Trigger: content rendered visible after reaction upload and validation.
   - Properties: `share_id`, `receiver_id`, `unlock_latency_sec`, `reaction_duration_sec`.

9. `loop_return_sent`
   - Trigger: bundle (content + reaction) dispatched to sender.
   - Properties: `share_id`, `sender_id`, `receiver_id`, `total_loop_time_sec`, `transport_status`.

10. `loop_return_opened`
    - Trigger: sender opens the return card in their inbox.
    - Properties: `share_id`, `sender_id`, `open_latency_sec`, `content_type`.

### Error / drop-off events

11. `reaction_capture_abandoned`
    - Trigger: user exits before submitting the reaction.
    - Properties: `share_id`, `receiver_id`, `abandon_step` (pre_recording|recording|preview|upload), `attempt_index`.

12. `unlock_failed`
    - Trigger: technical failure at unlock time.
    - Properties: `share_id`, `receiver_id`, `error_code`, `network_type`, `retry_available` (bool).

### Tracking rules

- `share_id` must be propagated on every event to reconstruct the end-to-end funnel.
- All timestamps in UTC; include `local_time` for time-of-day analysis.
- Client-side `event_id` for deduplication on network retry.
- No raw media content in analytics payloads — metadata only.

---

## 5) A/B test strategy

### Hypothesis

Requiring a reaction video to unlock content increases perceived social value, drives more complete loops, and improves short-term retention compared to a passive share.

### Experiment setup

- **Population**: active users eligible for external sharing (iOS, minimum app version), excluding at-risk/anti-abuse flagged accounts.
- **Randomization**: user-level, stable assignment, 50/50 split.
- **Control**: standard share — receiver sees content immediately, no reaction required.
- **Variant**: reaction-to-unlock required before content is visible + automatic bundle return to sender.

### Metrics

- **Primary**: Loop Completion Rate.
- **Secondary**: Reaction Unlock Rate, Share-to-First-Loop Time, D7 retention uplift.
- **Guardrails**: crash-free session rate, `unlock_failed` rate, notification opt-out delta, report/abuse rate.

### Sample size and duration

- **Statistical target**: detect a +3 pp absolute lift on Loop Completion Rate (illustrative example: baseline 30% → 33%). This MDE should be revisited once a baseline is measured.
- **Parameters**: α = 5%, power = 80% (standard frequentist setup).
- **Estimated sample size**: ~8k–12k users per arm (rough estimate; recalculate with actual baseline and traffic volume before running).
- **Duration**: 2–3 weeks minimum, covering at least 2 full weekly cycles to control for day-of-week effects.
- **Early stopping**: no peeking before minimum sample is reached.

### Decision rules

- **Ship**: primary metric positive and statistically significant, guardrails healthy.
- **Iterate**: primary neutral but secondary metrics show partial signal (e.g., unlock rate up but loop completion flat) → simplify UX, adjust copy or timing.
- **Kill**: primary metric null or negative after full duration, or guardrail deterioration (opt-outs, crashes, abuse reports) that is not addressable quickly.

---

## Framing notes

- This feature is a deliberate trade-off between reach (friction lowers volume) and depth (friction raises quality of each interaction).
- Success is not measured by share volume alone, but by the rate of complete, reciprocal loops.
- Rollout plan must include a feature flag, kill switch, and a real-time funnel dashboard per `share_id`.
