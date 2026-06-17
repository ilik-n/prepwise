# PrepWise — CLAUDE.md

## Project Overview

PrepWise is an offline Android flashcard app for practicing English prepositions.
It groups prepositions into **confusion clusters** — sets of prepositions commonly
mixed up together (e.g. IN / ON / AT for place). The user browses clusters, reads
a short intro, then practices with flashcard exercises. Progress is saved locally.

No internet. No accounts. No backend. One APK, works anywhere.

---

## Tech Stack

- **Flutter** — Android only (`--platforms android`)
- **Hive + hive_flutter** — local persistence for card progress and app state
- **Provider** — state management
- **JSON asset** — all card data lives in `assets/data/prepositions.json`

---

## File Structure

```
lib/
  main.dart
  models/
    cluster.dart          — Cluster (intro, rules list, card IDs)
    card_item.dart        — CardItem (sentence, correct, distractors, tags)
    rule.dart             — Rule (short text, example)
    card_progress.dart    — CardProgress (streak, attempts, mastered) [Hive]
    app_state.dart        — AppState (last cluster, sessions count) [Hive]
  services/
    data_service.dart     — loads + parses prepositions.json, provides lookups
    progress_service.dart — Hive read/write, mastery logic, session card drawing
    session_service.dart  — manages a live session (current index, answers)
  providers/
    data_provider.dart
    progress_provider.dart
    session_provider.dart
  screens/
    home_screen.dart
    cluster_intro_screen.dart
    card_screen.dart
    session_summary_screen.dart
    progress_screen.dart
  widgets/
    cluster_tile.dart
    answer_button.dart
    feedback_overlay.dart

assets/
  data/
    prepositions.json     ← SINGLE SOURCE OF TRUTH for all content

docs/
  CLI/
    session_01_setup_and_data.md
    session_02_services_and_state.md
    session_03_screens.md
    session_04_polish_and_apk.md
```

---

## Data Format — How to Add Cards

All cards live in `assets/data/prepositions.json`.
To add a card from an external source, copy this template and append it
to the `cards` array of the appropriate cluster:

```json
{
  "id": "card_custom_001",
  "cluster_id": "place_in_on_at",
  "sentence": "We stayed ___ a small hotel near the beach.",
  "correct": "in",
  "distractors": ["on", "at", "by"],
  "rule_id": "rule_in_enclosed_space",
  "tags": ["difficulty_1"],
  "is_famous": false,
  "is_irregular": false,
  "source": null
}
```

**Rules:**
- `id` must be unique across all cards. Use prefix `card_custom_` for externally added cards.
- `cluster_id` must match one of the cluster `id` values.
- `distractors` should always be plausible for the sentence — never obviously wrong.
- `rule_id` must match a key in the top-level `rules` map.
- `tags`: always include one of `difficulty_1`, `difficulty_2`, `difficulty_3`.
- `is_famous: true` if from a song/film/play — also add `source`.
- `is_irregular: true` if it's a fixed collocation with no spatial logic.

---

## Cluster IDs

| id                    | Title                          | Prepositions         |
|-----------------------|--------------------------------|----------------------|
| place_in_on_at        | IN / ON / AT — Place           | in, on, at           |
| time_in_on_at         | IN / ON / AT — Time            | in, on, at           |
| duration_by_until_for | BY / UNTIL / FOR — Time Spans  | by, until, for       |
| movement_to_for_with  | TO / FOR / WITH                | to, for, with        |
| origin_of_about_from  | FROM / OF / ABOUT              | from, of, about      |
| collocations          | Fixed Phrases                  | various              |
| famous_lines          | You've Heard This Before       | various              |

---

## Mastery Logic

- Each card has a **streak** counter (0–N).
- **3 consecutive correct answers** = card is mastered.
- **Any wrong answer** resets streak to 0 and unmastered the card.
- Mastered cards re-enter review pool at a ratio of roughly 1:5 in any session.
- Session size: **15 cards**, drawn weighted toward unmastered/low-streak cards.

---

## Naming Conventions

- Dart: `lowerCamelCase` for variables/methods, `UpperCamelCase` for classes.
- JSON keys: `snake_case`.
- Card IDs: `p_001` (place), `t_001` (time), `d_001` (duration), `m_001` (movement), `o_001` (origin), `c_001` (collocation), `f_001` (famous).
- Custom/external cards: `card_custom_001`, `card_custom_002`, etc.
- Rule IDs: `rule_` prefix, descriptive name.

---

## How to Run

```bash
flutter pub get
flutter run                  # USB-connected Samsung device
flutter build apk --release  # signed APK for distribution
```

> **TODO — App Icon:** Replace the default Flutter icon before publishing.
> Put a 1024×1024 PNG at `assets/images/icon.png`, add `flutter_launcher_icons`
> to `dev_dependencies`, configure it in `pubspec.yaml`, then run
> `flutter pub run flutter_launcher_icons`. Until then the default blue Flutter
> logo is used.

---

## Session Doc Usage

```bash
cat CLAUDE.md docs/session_01_setup_and_data.md | claude
cat CLAUDE.md docs/session_02_services_and_state.md | claude
cat CLAUDE.md docs/session_03_screens.md | claude
cat CLAUDE.md docs/session_04_polish_and_apk.md | claude
```

Each session is self-contained. Verify on device after each before proceeding.
