# PrepWise

An offline Android flashcard app for practicing English prepositions.

PrepWise groups prepositions into **confusion clusters** — sets of prepositions commonly mixed up together (e.g. IN / ON / AT for place). The user browses clusters, reads a short intro, then drills with flashcard exercises. Progress is saved locally on device.

No internet. No accounts. No backend. One APK, works anywhere.

---

## Features

- 7 preposition clusters covering place, time, duration, movement, origin, collocations, and famous lines
- Spaced-repetition-style mastery: 3 consecutive correct answers marks a card as mastered
- Wrong answers reset the streak and bring the card back into rotation
- Session size of 15 cards, weighted toward unmastered and low-streak cards
- Mastered cards re-enter review at a ~1:5 ratio so nothing is forgotten
- Fully offline — all data is bundled as a JSON asset, progress stored with Hive

---

## Clusters

| Cluster | Prepositions |
|---|---|
| IN / ON / AT — Place | in, on, at |
| IN / ON / AT — Time | in, on, at |
| BY / UNTIL / FOR — Time Spans | by, until, for |
| TO / FOR / WITH | to, for, with |
| FROM / OF / ABOUT | from, of, about |
| Fixed Phrases | various |
| You've Heard This Before | various |

---

## Tech Stack

- **Flutter** (Android target)
- **Hive + hive_flutter** — local persistence
- **Provider** — state management
- **JSON asset** — all card data in `assets/data/prepositions.json`

---

## Getting Started

```bash
flutter pub get
flutter run          # USB-connected Android device
flutter build apk --release
```

> A release keystore is required for `--release` builds and is not included in this repo.
> See the [Flutter docs](https://docs.flutter.dev/deployment/android#signing-the-app) for how to create one.

---

## Adding Cards

All content lives in `assets/data/prepositions.json`. To add a card:

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

- `id` must be unique; use the `card_custom_` prefix for new cards
- `distractors` should always be plausible — never obviously wrong
- `tags`: include exactly one of `difficulty_1`, `difficulty_2`, `difficulty_3`
- `is_famous: true` if from a song/film/play — also set `source`
