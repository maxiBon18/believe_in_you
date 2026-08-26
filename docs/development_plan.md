# Development Plan

**Scope:** implementation order for the app described in `business_analysis_en.md`. That document is
the source of truth for *what* is built and *why*; this one covers *in which order* and *behind which
gates*. Where the two disagree, the business analysis wins.

**Status of the repo at the time this plan was written:**

- `lib/main.dart` is still the Flutter counter template.
- `lib/` directory tree is scaffolded with `.gitkeep` files, following the layout in `.claude/CLAUDE.md`.
- `lib/core/presentation/ux/theme/` holds `app_colors.dart`, `app_dimensions.dart`, `app_typography.dart`;
  `app_theme.dart` is empty.
- `pubspec.yaml` has `riverpod`, `flutter_riverpod`, `get_it`, `package_info_plus`,
  `flutter_launcher_icons`. Nothing else from the stack is installed.
- `test/` holds only the template `widget_test.dart`.

---

## Phase 0 — foundations

No feature code until the four steps below are done. Each is one commit.

### Step 0.1 — dependency batch

**Approval gate: `pubspec.yaml` changes need explicit approval.**

Phase 0 needs, and nothing more:

| Package | For |
|---|---|
| `drift`, `drift_dev`, `build_runner` | persistence |
| `sqlite3_flutter_libs`, `sqlcipher_flutter_libs` | encryption at rest (§9) |
| `flutter_secure_storage` | the database key |
| `path_provider` | database file location |
| `uuid` | UUID primary keys (§8) |
| `timezone` | IANA identifier stored on every entry (§4.10) |
| `flutter_local_notifications` | one reminder per slot (§4.9) |
| `fl_chart` | trend chart (§7 Home Block B) |
| `flutter_native_splash` | splash screen (§7) |

Deferred on purpose: `pdf` and `printing` arrive with Phase 0.5, not before. No package that transmits
data off-device, ever — invariant 6.

### Step 0.2 — time source decision

**Confirm-first.** `.claude/CLAUDE.md` records that how the app reads the current time is undecided,
and that introducing an abstraction is a decision to be taken, not assumed.

What has to be settled before Step 2 can start:

- the contract shape (a clock interface in `core/domain/`, or instants passed as parameters throughout)
- where it is registered — GetIt, per the DI rule, if it becomes a dependency
- how tests substitute a fixed instant

Until this is settled, any code needing an instant takes it as a parameter. This step blocks Step 2,
because every window and status computation reads the current time.

### Step 0.3 — app shell

- Fill `app_theme.dart` from the existing colour, dimension, and typography tokens.
- Replace the `main.dart` template with `ProviderScope` + `MaterialApp` wired to the theme.
- Configure `flutter_native_splash`.
- Remove the counter widget and the template `widget_test.dart`.

### Step 0.4 — router and DI bootstrap

- `AppRouter` abstract contract; nothing outside the router implementation reaches Navigator directly.
- Custom Navigator 2.0 implementation, per `.claude/rules/code/routing-rules.md`. No `go_router`.
- GetIt registration in `core/shared/controllers/`, called once at startup.
- Initial route set: onboarding, home, history, settings.

---

## Step 1 — full schema, in one step

**Confirm-first: schema changes and migrations.**

§10 is explicit — phase the UI, not the schema. Every table from §8 is created now, including the ones
v1 never reads:

- `entries` — UUID PK, `type` enum with `episode` reserved, `slot_index`, `refers_to`, `recorded_at`,
  denormalised `window_start` / `window_end` (§4.10), `timezone`, `scale`, `arousal` nullable and
  unused, `note` nullable, `edit_count`, `updated_at`, `deleted_at`, `UNIQUE (date(refers_to), slot_index)`
- `entry_emotions` — entry reference plus emotion key
- `schedules` — append-only, `wake_time`, `sleep_time`, `effective_from`, `created_at`
- `assessments` — stub, unused in v1

No `status` column and no `is_backfilled` column. Status is derived (§4.1) and backfill does not exist
(§4.4). A column for either is a schema-level invariant violation.

Also in this step:

- explicit schema version and a migration test harness, from the first commit — this is the developer's
  own clinical record and invariant 8 admits no migration that can lose recordings
- encrypted database open, key held in secure storage
- DTOs, data sources, and repository implementations in `data/`; repository interfaces in `domain/repo/`

The repository interface sits between UI and data from the first commit, as §10 requires.

---

## Step 2 — domain services

Pure functions over a schedule and a set of recordings. No database, no widgets, no Flutter import.
Tests are written alongside, and this is where the invariant suite lives.

1. **Window computation** — `span = S − W` divided into three equal windows (§5.1); crossing midnight
   normalised to the wake date; a waking span under 8h or over 20h rejected with an explanatory message
   (§4.10).
2. **Slot status derivation** — COMPLETED / NOT_APPLICABLE / LOCKED / OPEN / SKIPPED, evaluated in the
   exact order given in §4.1. `NOT_APPLICABLE` compares the window end against the `created_at` of the
   first `schedules` row (§4.15).
3. **Daily aggregate** — mean over completed slots only, never zeroed and never interpolated
   (invariant 4); `n/3` completeness carried alongside the mean; a day with zero completed slots yields
   no value at all rather than a null-shaped one.

This is the highest-risk logic in the app and the cheapest part to test. It is done before any screen
consumes it.

---

## Step 3 — onboarding feature

Sequence from §7: why track → how the scale works → wake and sleep times → notification permission →
data stays on device. Plus the §4.12 framing on why recording what was actually felt matters.

The step ends by writing the first `schedules` row. Its `created_at` is the installation instant that
§4.15 depends on for `NOT_APPLICABLE`, so nothing else may write that row first.

---

## Step 4 — entry feature (Home, Block A)

A pager, one page per slot, opening on the current open slot or else the next one with its opening time.

| Slot state | Rendering |
|---|---|
| Locked | visible, greyed, shows the opening time |
| Open | editable, explicit save, remaining time visible |
| Completed | values shown, read-only |
| Skipped | marked as skipped, not fillable |

- Scale 1–5 with the verbal label and the emoji shown live at every point (§4.6). **Emoji ship as
  bundled assets, not system emoji font characters** — platform rendering differs enough to change what
  a scale anchor means.
- Sixteen emotion cards from the fixed §6.2 vocabulary, multi-select, at least one required.
- Optional single-line note with the "What was going on?" placeholder.
- Explicit save, not save-on-change (§4.4 mitigation). Repeated saves within the window update the same
  row and increment `edit_count`.

The step is not done until a cold launch to a saved recording has been hand-timed under the 20-second
budget (§4.3).

---

## Step 5 — notifications

- One per slot, fired 45 minutes before the window closes (§4.9).
- Suppressed when the slot already has a row.
- Maximum three per day.
- Rescheduled when the schedule changes, and restored after reboot and app-kill on both platforms (§9).
- Copy prompts the action and never comments on past behaviour (§4.13).

---

## Step 6 — trend chart (Home, Block B, chart 1)

Rolling 30 days: x is the date, y is the mean of the day's completed slots. Filled marker for 3/3,
hollow marker for 1–2, and for a day with no recordings no point at all, with the line broken rather
than bridged. Skipped slots render as gaps and are never interpolated or hidden.

Phase 0 ends here. The app is usable daily from this point.

---

## Later phases

| Phase | Steps |
|---|---|
| **0.5** | add `pdf` + `printing`; weekly one-page export per §7.1; support-resources screen (§4.11, invariant 7) |
| **1** | History calendar heatmap; emotion frequency chart with 7/30/90 selector; Settings expansion — schedule change, delete-all with recording count and an export offer, full JSON dump |
| **2** | episode entries with the ABC structure (§4.2) — additive columns, no restructuring |
| **3** | profile, backend, synchronisation — learning objective, not shipped |

---

## Gates that apply to every step

1. `fvm dart analyze` — zero errors.
2. `fvm dart format .` — never with `--line-length`.
3. `fvm dart run build_runner build --delete-conflicting-outputs` — only after touching Drift tables or
   other annotated classes. Never for a provider.
4. Tests for the logic the step touches. The invariant suite is never skipped to make a step land.
5. `/dart-review` over the new `lib/**` before committing.
6. `/git-flow` for staging and the Conventional Commit.

## Invariant tripwires, by step

| Step | Watch for |
|---|---|
| 1 | a `status` or `is_backfilled` column; a migration path that can drop rows |
| 2 | a default or imputed scale value; skipped slots counted as zero in a mean |
| 3 | anything writing a `schedules` row before onboarding does |
| 4 | an edit path that reopens a closed window; save-on-change; a synthesised value on an untouched slot |
| 5 | notification copy that praises or admonishes |
| 6 | an interpolated or hidden gap |

Any of these is raised, not worked around. An implementation that violates an invariant is wrong
regardless of how clean it looks.
