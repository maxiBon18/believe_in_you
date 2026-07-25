# Mood Diary — Business Analysis

**Version:** 3.0
**Status:** All decisions resolved — approved for implementation
**Scope:** Personal-use application, local-only. Backend and multi-user considerations are explicitly out of scope for v1.

---

## 1. Description

The mood diary is an application of **self-monitoring**, one of the oldest techniques in cognitive-behavioural therapy. It stems from two lines of work:

- **Aaron Beck's Daily Record of Dysfunctional Thoughts (DRDT)** — designed to make automatic thoughts visible.
- **Peter Lewinsohn's pleasant events schedules** — used to map the relationship between activities and mood in depression.

The underlying idea is that inner experience, if not recorded, gets reconstructed after the fact — and that reconstruction is systematically distorted.

> **Design consequence.** Everything that trades convenience against recording-accuracy is resolved in favour of accuracy, and everything that trades completeness against adherence is resolved in favour of adherence. A perfect instrument abandoned in week three produces no data at all.

---

## 2. Critical Points — Summary

Fifteen issues were raised against v2 and v3. All are now resolved; §4 gives the full treatment. No decisions remain open.

**1. Automatic fill at 5 / neutral — REMOVED.** It wrote data the user never reported, indistinguishable downstream from real observations. The bias was not random: unlogged evenings are disproportionately bad evenings, so the design systematically replaced the worst data points with neutral ones. Missing data is now recorded as missing.

**2. The ABC block was bound to the wrong trigger — REMOVED FROM v1.** Functional analysis is episode-driven; binding it to a clock slot meant either no answer at 15:00, or an event at 16:47 reconstructed from memory at 21:00 — the very bias the diary exists to counter. Deferred to a future release, where it will be an event-triggered entry rather than a scheduled field.

**3. Entry cost threatened adherence — RESOLVED BY 2.** A slot entry is now scale + emotions + optional one-line note. Nothing else.

**4. Rigid immutability — CONFIRMED, with the strict rule.** Editing is permitted while the slot window is open and impossible once it closes. This is the maximum-integrity option and it makes `skipped` terminal: there is no backfill.

**5. No export path to the psychologist — RESOLVED.** Weekly PDF added as a first-class requirement.

**6. The unanchored 1–10 scale — REPLACED.** Now 1–5, with a verbal label and an emoji at every point.

**7. Arousal axis dropped — DECISION CONFIRMED.** Single valence axis, with the emotion vocabulary carrying the distinction between flat and agitated states.

**8. Daily average rather than a min–max band — DECISION CONFIRMED.** One consequence needs a rule: days with fewer than three completed slots are not comparable to complete days, so incomplete days are marked (see §4.8).

**9. Reminder timing — RESOLVED.** Notification fires shortly before the window closes, not an hour before it opens.

**10. Schedule changes — RESOLVED.** Wake/sleep times are set once at first launch and changeable from Settings. Existing data is never affected.

**11. Safety baseline for free text — RESOLVED.** A findable support-resources screen from v1.

**12. The objectivity message — RESOLVED, and largely obsolete.** It existed to frame the ABC questions. With those removed it survives only as placeholder text on the note field.

**13. Streaks and gamification — EXCLUDED.** No streak mechanics. Completion rate is shown neutrally and factually.

**14. Data retention — INDEFINITE,** with an explicit delete-all action in Settings.

**15. First partial day — EXCLUDED FROM STATISTICS.** Slots whose window closed before installation are not skips and never appear as such.

---

## 3. Function

| Function | Mechanism | Support in v1 |
|---|---|---|
| **Counters mood-congruent memory bias** | Depressed retrieval is selectively biased toward negative material. Asked "how was your week?", you recall the bad moments and generalise. The diary produces data the generalisation cannot absorb. | ✅ Full. Three fixed recordings per day, no backfill, no synthesised values. |
| **Makes variability visible** | Depression subjectively presents as monolithic and unchanging. The diary almost always shows fluctuation — and if it fluctuates it is responsive to something, and therefore in principle modifiable. | ✅ Full. Trend chart plus emotion frequency. |
| **Enables functional analysis** | Recording antecedent → thought → behaviour → consequence surfaces which situations trigger a downturn, which thoughts mediate it, which behaviours maintain it. | ⛔ **Not in v1.** Deferred with the ABC structure — see §4.2. |
| **Generates metacognitive distance** | Writing *"I'm thinking that I'm a failure"* is not the same mental operation as thinking it. Writing shifts position from inside the thought to outside it — *decentering*. | ◐ Partial. The optional note supports it; the removal of the open questions reduces it. |
| **Has a reactive effect** | Measuring a behaviour changes it, even absent other intervention. For mood, reactivity works mainly by increasing awareness of precursors. | ✅ Full. Regular prompting is the mechanism, and it is preserved. |
| **Provides material for the session** | Without a diary the psychologist works from what you recall in the last 48 hours, filtered through your state in that moment. With it, she has a time series. **Probably the main reason she asked for one.** | ✅ Full, via the weekly export — §7.1. |

The trade in v1 is explicit: **functional analysis is sacrificed to protect adherence.** That is the right order — a diary that is filled in without ABC data is useful, while a diary with ABC fields that is abandoned in week three is not.

---

## 4. Resolution of Critical Points

### 4.1 ✅ Skipped slots — no synthesised values

**Removed:** automatic assignment of scale = 5 and neutral emotion to a skipped final slot.

**Rationale.** A synthesised value is indistinguishable from a reported one, and the bias is directional: evenings that go unlogged are disproportionately bad evenings. The design would have replaced the worst observations with neutral ones and flattened the trend precisely where the signal is strongest. It also corrupts any measure of variability, which §3 identifies as a core therapeutic mechanism.

#### Implementation: status is derived, not stored

**A row is written only when the user saves.** `skipped` is computed at read time.

```
status(date D, slot n):
    installed = created_at of the first schedules row
    schedule  = latest schedules row where effective_from <= D
    window    = compute_window(schedule, D, n)
    row       = entries where date(refers_to) = D and slot_index = n

    if row exists                     -> COMPLETED
    else if window.end <= installed   -> NOT_APPLICABLE   (§4.15)
    else if now < window.start        -> LOCKED
    else if now < window.end          -> OPEN
    else                              -> SKIPPED          (terminal)
```

**Why derived rather than stored.** Storing the status would require creating three `pending` rows at the start of each day, which requires the app to be running. If the app is not opened for four days, those rows are never created and the skip records being relied on do not exist. Derivation has no such dependency: the schedule table plus the calendar reconstructs the expected grid for any past date.

**Consequences:**

- No background job, no day-rollover task, no writes on days the app is not opened.
- The `entries` table contains only real observations. Every row is something the user actually reported.
- Because editing ends when the window closes (§4.4), `SKIPPED` is **terminal**. There is no backfill and no "recorded late" flag.
- Charts render skipped slots as gaps. Never interpolated, never hidden.
- The weekly export reports a completion rate (`n` of 21).

**Accepted cost.** A dead battery, a lost phone, or a day too bad to open the app produces a permanent gap. This is deliberate: a gap is honest, and a gap on a bad day is itself clinically informative.

### 4.2 ✅ ABC structure removed from v1

**Removed:** the five open-ended functional-analysis questions (*what happened / alone or with others / what did you think / what did you do / what was the consequence*).

**Rationale.** Functional analysis is **episode-driven** — antecedent → thought → behaviour → consequence describes an event, not a time of day. Attaching it to a fixed slot produces two failures: at the scheduled time nothing has usually happened, so the fields train the user to skip; and when something does happen mid-window it gets written up hours later from memory, which is exactly the mood-congruent recall bias the diary exists to defeat. Beck's DRDT was completed *when a mood shift occurred*.

**Deferred to a future release.** When reintroduced it will be a **separate, user-initiated episode entry** available at any time, not a field inside a scheduled slot. The schema reserves space for it now (§8) so that adding it later requires no migration.

**v1 slot entry is therefore:** scale + emotions + optional note.

### 4.3 ✅ Adherence — resolved by 4.2

**Budget: a slot entry must be completable in under 20 seconds, app launch included.**

Mandatory: scale, and at least one emotion. Optional: a single-line note. Nothing else appears on the entry screen.

### 4.4 ✅ Editing window — strict

- A slot is **editable while its window is open**. Repeated saves update the same row; `edit_count` increments.
- Once the window closes, the row is **permanently read-only**.
- A slot with no row at window close is **skipped, permanently**. No backfill.
- Future slots remain visible but locked, showing the time they open.

**Rationale.** This is the maximum-integrity option. Every stored value was reported during the period it describes, so `recorded_at` never falls outside `[window_start, window_end)` and no provenance flag is needed to interpret the data. The `is_backfilled` field from v2 is dropped.

**Accepted cost.** A mis-drag on the slider that is not corrected before the window closes is permanent. Mitigation is in the UI, not the data model: an explicit save action rather than save-on-change, and a clear indication of remaining time in the window.

### 4.5 ✅ Export

Weekly PDF, first-class requirement. Specification in §7.1.

### 4.6 ✅ Scale — 1 to 5, verbal label plus emoji

| Value | Label | Emoji |
|---|---|---|
| 1 | Very bad | 😞 |
| 2 | Bad | 🙁 |
| 3 | Neither good nor bad | 😐 |
| 4 | Good | 🙂 |
| 5 | Very good | 😄 |

**Rationale.** Five anchored points sit within reliable discrimination for internal states, and every point carries an explicit meaning, so the scale does not drift over months the way an unanchored 1–10 does. Label and emoji are both shown live as the value changes — not only during onboarding.

**Two implementation notes:**

1. **Render the emoji as bundled assets (SVG or PNG), not as system emoji font characters.** Platform rendering differs sharply between iOS, Android vendors, and OS versions; a face that reads as *sad* on one device can read as *distressed* on another. Since the emoji is functioning as a scale anchor, its appearance must be fixed.
2. **Reduced sensitivity is the trade-off.** Five points detect change less finely than seven or ten. This is partly recovered by the daily mean across three slots, which yields effective steps of one third of a point.

### 4.7 ✅ Single valence axis — decision confirmed

No arousal axis. Entry cost is the deciding factor.

The known cost is that *flat, empty, unable to move* and *tense, agitated, unable to settle* both land near 2. This is **compensated through the emotion vocabulary** (§6.2), which retains "numb / empty" and "restless / agitated" as separately selectable, so the distinction is recoverable from the emotion data even though the scale does not carry it.

### 4.8 ✅ Daily average — decision confirmed, with a completeness rule

The trend chart plots the **mean of the day's completed slots**.

**Required rule.** A day with one completed slot and a day with three both produce a mean, but they are not comparable — a single bad morning would otherwise render as an entirely bad day.

- The mean is computed **over completed slots only**. Skipped slots are excluded, never counted as zero and never imputed.
- Days with fewer than three completed slots are drawn with a **hollow marker**; complete days use a filled marker.
- Days with **zero** completed slots produce **no point**, and the line breaks rather than bridging the gap.
- The export states `n/3` per day and the weekly completion rate.

### 4.9 ✅ Notification near window close

- **One notification per slot**, fired **45 minutes before the window closes**.
- **Suppressed** if the slot already has a row — no nagging for work already done.
- Maximum three notifications per day.

**Rationale.** Rating a period after living it is coherent; rating it before it begins is not. Firing before the close leaves time to respond while the window is still open — which matters, because once it closes the slot is unrecoverable (§4.4).

**Specific risk — slot 3.** Its window ends at the declared sleep time, so a notification 45 minutes before close may arrive when the user is already asleep. Accepted for v1, since the alternative (an earlier notification) means rating a period still substantially unlived. To be reviewed against real usage — see §11.

### 4.10 ✅ Schedule — set once, changeable from Settings

- Wake and sleep times are requested **once, at first launch**, as part of onboarding.
- They are changeable later through a **dedicated Settings entry**.
- A change takes effect **from the following day**. Today's windows are already fixed.
- **Existing data is never affected.** Historical entries keep the windows they were recorded against.

**Implementation.** Two mechanisms, both required:

1. `schedules` is append-only, each row carrying `effective_from`. Deriving the status of a past slot (§4.1) uses the schedule that was in effect on that date.
2. Window boundaries are **denormalised onto each entry** at creation. Even if the schedules history were lost, stored entries remain self-describing.

**Edge cases:**

| Case | Handling |
|---|---|
| Sleep time after midnight | Normalise across the date boundary; the "day" is the wake date. |
| Waking span < 8h or > 20h | Reject at input with an explanatory message. |
| Change submitted mid-day | Applies from tomorrow; today's windows are unchanged. |
| Shift work / irregular rhythm | Out of scope for v1. Documented limitation. |
| DST transition | Windows computed from local wall-clock time; IANA timezone ID stored on every entry. |
| App opened outside all windows | Show the next slot and its opening time. No entry possible. |

### 4.11 ✅ Safety baseline

A support-resources screen in Settings from v1: findable, permanent, never interrupting.

No content scanning, no interception, no reactive prompts. The note field must remain a place where the user can write honestly.

### 4.12 ✅ Objectivity framing — reduced to placeholder text

Largely obsolete: the message existed to frame the ABC questions, which are gone.

What remains:

- A brief framing during onboarding, explaining that the value of the record comes from recording what was actually felt rather than what should have been felt.
- **Placeholder text on the note field** as an ongoing cue — e.g. *"What was going on?"*
- The full framing is re-shown at 30-day intervals.

A message displayed before every entry becomes wallpaper within a week; that pattern is not used.

### 4.13 ✅ No streaks, no gamification

**Decision: no streak mechanics, no badges, no scores.**

**Rationale.** Streaks improve adherence in general-purpose apps, but here the cost outweighs the benefit. In a depressed population a broken streak does not read as data — it reads as evidence of failure. That is precisely the cognitive pattern the therapy is working against: generalising from a single negative episode. An app that reinforces it works against the session. And the risk is concentrated by construction on the worst days, since those are the days the user misses.

**What is shown instead.** The **completion rate**, stated factually.

- Neutral phrasing: *"18 of 21 recordings"*. Never a percentage colour-coded by merit, never a run of consecutive days.
- No celebratory language (*"great job!"*, *"don't break your streak!"*) and no admonishing language (*"you missed 3 days"*).
- It appears in the weekly export (§7.1) and in History. It does not appear on Home, where it would distract from the only action that matters: entering the current recording.

Notifications follow the same rule — they prompt an action, they do not comment on past behaviour.

### 4.14 ✅ Indefinite retention, with explicit deletion

**Decision: data is retained indefinitely.** No rolling window, no automatic deletion.

**Rationale.** Clinical value grows with series length. A year of data shows seasonality, response to a change in treatment, recovery after an episode — none of which is visible in thirty days. Automatic deletion would silently destroy the very information the app exists to produce.

**Mandatory counterpart.** Indefinite retention is only acceptable if the user has an explicit way out. In Settings:

- **Delete all data** — single, complete action.
- Explicit confirmation, stating how many recordings will be lost.
- An offer to **export before deleting**.
- Deletion is **final and local**: no copy exists elsewhere, because there is no backend (§9).

Selective deletion of individual entries is not provided. It would be a retroactive edit of the record, inconsistent with §4.4, and it would open the door to removing the bad days — that is, to reconstructing the memory the diary exists to counter.

### 4.15 ✅ First partial day — excluded from statistics

**Decision: slots whose window closed before installation are not skips.**

**Rationale.** Installing at 16:00 means slots 1 and 2 of that day have already passed. Counting them as skipped would produce an artificially incomplete first day and a completion rate biased downward at exactly the moment the user is deciding whether the tool is worth keeping.

**Implementation.** No new field is required: the `created_at` of the **first `schedules` row** is the moment of installation, because the schedule is collected during onboarding.

A slot whose `window_end` precedes that instant has status `NOT_APPLICABLE`:

- It does not render as a gap in the charts.
- It is not counted in the denominator of the completion rate.
- In History the day is marked as partial-by-installation, not as incomplete.

A slot already **open** at the moment of installation remains normally fillable — it falls within its own period and counts as a full recording.

---

## 5. Prerequisites

- Data collection **3 times per day**.
- The three moments are **generated dynamically** from wake and sleep times declared at first launch.
- **One reminder notification per slot**, 45 minutes before the window closes, suppressed if already completed.
- **Onboarding** to explain the app, teach the scale, collect the schedule, and request notification permission.
- **Local-only storage.** No account, no network, no transmission in v1.

### 5.1 Slot computation

Given wake time `W` and sleep time `S`, the waking span is divided into three equal windows:

```
span      = S − W                                (handles crossing midnight)
window_n  = [W + (n−1)·span/3, W + n·span/3)     for n ∈ {1,2,3}
```

Computed once per day from the schedule in effect, and denormalised onto every entry created that day.

---

## 6. Information Collected

### 6.1 Slot entry — the only entry type in v1

| Field | Required | Notes |
|---|---|---|
| Scale 1–5 | ✅ | Label + emoji at every point (§4.6). |
| Emotions | ✅ | One or more, fixed vocabulary (§6.2). |
| Note | ⬜ | Single line, free text. |

Target: **under 20 seconds**, app launch included.

### 6.2 Emotion vocabulary

**Design principle:** the set must include **positive emotions**. An application offering only negative options teaches the user that good states are not worth recording, and makes the "variability is visible" mechanism (§3) impossible to demonstrate — a chart that can only go down is not evidence of fluctuation.

Multi-select, presented as small cards.

**Unpleasant**

| Emotion | Included because |
|---|---|
| Sad | Core affect. |
| Anxious | Highest comorbidity with depression. |
| Irritable / angry | Frequently the presenting affect, especially in men. |
| Guilty | Distinct from shame; targets behaviour. |
| Ashamed | Distinct from guilt; targets self. Strong maintenance factor. |
| Lonely | Directly actionable through behavioural activation. |
| Hopeless | Clinically significant; tracked separately. |
| **Numb / empty** | **Not a low score — an absence.** Selectable independently of the scale. |
| Overwhelmed | Common, and points to load rather than mood. |
| Restless / agitated | Recovers the distinction lost with the arousal axis (§4.7). |

**Pleasant**

| Emotion |
|---|
| Calm |
| Content |
| Happy |
| Hopeful |
| Energetic |
| Connected |

Sixteen cards. The vocabulary is **fixed** — no user-defined tags. Free-form tags become unanalysable within months, and the entire value of tagging is aggregation.

---

## 7. App Structure

- **Splash screen** — native, via `flutter_native_splash`.
- **Onboarding** — why track → how the scale works → wake and sleep times → notification permission → data stays on device.
- **Main body**, bottom bar with 3 sections:

### Home

**Block A — Data collection.** A pager, one page per moment of the day.

| Slot state | Rendering |
|---|---|
| Locked | Visible, greyed, showing the opening time. |
| Open | Editable. Explicit save. Remaining time in the window visible. |
| Completed | Values shown, read-only. |
| Skipped | Marked as skipped. Not fillable. |

Opens on the current open slot; if none is open, on the next one, with its opening time.

**Block B — Charts.**

1. **Mood trend, rolling 30 days**
   - x: date
   - y: mean of the day's completed slots
   - Filled marker = 3/3 slots; hollow marker = 1–2 slots; no point and a broken line = 0 slots

2. **Emotion frequency**
   - x: emotion
   - y: occurrence count
   - Period selector: 7 / 30 / 90 days
   - Pleasant and unpleasant visually distinguished

### History

Calendar heatmap: one cell per day, coloured by the daily mean, empty for days with no data. Tapping a day opens its three slots read-only.

### Settings

- App information
- Notifications
- **Wake and sleep times** (§4.10)
- **Weekly export** (§7.1)
- **Support resources** (§4.11)
- **Delete all data** (§4.14)

### 7.1 Weekly export

One-page PDF, generated on demand and offered weekly:

- 7-day chart with visible gaps
- Mean, min, max, standard deviation
- Completion rate (`n` of 21 slots), and `n/3` per day
- Emotion frequency for the week
- Notes, if present, listed by day

**Constraint:** readable in under 60 seconds, on paper, without installing anything. Not a CSV. Not an app login.

---

## 8. Data Model

```
entries
  id                UUID        PK
  type              ENUM        slot            (episode reserved for a future release)
  slot_index        INT         1..3
  refers_to         TIMESTAMP   moment described
  recorded_at       TIMESTAMP   moment entered
  window_start      TIMESTAMP   denormalised (§4.10)
  window_end        TIMESTAMP   denormalised
  timezone          TEXT        IANA identifier
  scale             INT         1..5
  arousal           INT NULL    reserved, unused (§4.7)
  note              TEXT NULL
  edit_count        INT
  updated_at        TIMESTAMP
  deleted_at        TIMESTAMP NULL

  UNIQUE (date(refers_to), slot_index)

entry_emotions
  entry_id          UUID        FK
  emotion_key       TEXT

schedules                       -- append-only
  id                UUID        PK
  wake_time         TIME
  sleep_time        TIME
  effective_from    DATE
  created_at        TIMESTAMP

assessments                     -- stub, unused in v1
  id                UUID        PK
  type              TEXT        PHQ9 | GAD7 | WHO5
  taken_at          TIMESTAMP
  item_scores       JSON
  total             INT
```

**Notes on this revision:**

- **No `status` column.** Status is derived (§4.1). The table holds only real observations.
- **No `is_backfilled`.** Backfill does not exist (§4.4).
- **ABC columns removed** from the table but the `type` enum retains room for `episode`, so the future release adds columns rather than restructuring.
- **`UNIQUE (date, slot_index)`** enforces at most one row per slot at the database level.
- **`arousal`** kept nullable and unused.

**Three decisions that cost nothing now and prevent a rewrite later:**

1. **UUID primary keys** — makes offline-first sync tractable.
2. **`updated_at` + soft delete on every table** — the minimum basis for last-write-wins reconciliation.
3. **Explicit schema versioning** — you will change your mind about fields, and this is your own clinical record. Losing it to a bad migration is not recoverable.

---

## 9. Non-Functional Requirements

| Requirement | Target |
|---|---|
| Slot entry duration | < 20 s including cold launch |
| Cold start to interactive | < 2 s |
| Offline capability | Total — no network dependency in v1 |
| Data locality | On-device only; no transmission |
| At-rest encryption | Enabled (health data) |
| Notification reliability | Survives reboot and app-kill on both platforms |
| Data portability | PDF + full JSON dump from Settings |

---

## 10. Delivery Phases

| Phase | Contents |
|---|---|
| **0** | Splash · onboarding · schedule setup · slot entry (scale + emotions + note) · notifications · trend chart · full schema |
| **0.5** | Weekly PDF export · support-resources screen |
| **1** | History calendar · emotion frequency chart · settings expansion |
| **2** | Episode entries with ABC structure (§4.2) |
| **3** | Profile, backend, synchronisation — learning objective, not shipped |

Phase the **UI**, not the schema. Screens are cheap to add and cheap to discard. Migrations over data you care about are neither, and retrofitting sync into a codebase that assumed local-only is a rewrite. Build the full schema in Phase 0 and put a repository interface between UI and data layer from the first commit.

---

## 11. Decision Status

Every point raised in previous revisions is resolved (§4.1–§4.15). No open decisions block implementation of Phase 0.

The items below are not open questions but checks to run against real usage, after a few weeks of data:

| To verify | Reference | Signal to watch for |
|---|---|---|
| Slot 3 notification timing | §4.9 | Does it arrive after you are already in bed? If so, a fixed cap relative to declared sleep time is needed. |
| Tone of the emoji assets | §4.6 | Does a smiley scale read as trivialising on the worst days? |
| Sensitivity of the 5-point scale | §4.6 | Do real improvements move the value, or do they all stay within one step? |
| Actual entry cost | §4.3 | Does a recording stay under 20 seconds even on days you don't feel like it? |