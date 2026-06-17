# Session 01 — Setup, Data, and Models

## Goal
Create the Flutter project, configure dependencies, write the complete
`prepositions.json` data file, and define all Dart model classes.
After this session: `flutter run` shows a blank scaffold with no errors.

---

## Step 1 — Create the Flutter Project

```bash
flutter create prep_wise --org com.prepwise --platforms android
cd prep_wise
```

---

## Step 2 — pubspec.yaml

Replace the entire `pubspec.yaml` with:

```yaml
name: prep_wise
description: English preposition practice app
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  provider: ^6.1.1
  path_provider: ^2.1.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  hive_generator: ^2.0.1
  build_runner: ^2.4.8
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
  assets:
    - assets/data/prepositions.json
```

Run `flutter pub get` after writing this file.

---

## Step 3 — Create the Assets Directory

```bash
mkdir -p assets/data
```

---

## Step 4 — Write assets/data/prepositions.json

This is the SINGLE SOURCE OF TRUTH for all app content.
Write the complete file following this exact schema.

### Schema Overview

```
{
  "version": "1.0",
  "rules": {
    "rule_id": { "id": "...", "short": "...", "example": "..." }
  },
  "clusters": [
    {
      "id": "...",
      "title": "...",
      "subtitle": "...",
      "prepositions": ["..."],
      "intro_rules": ["rule_id_1", "rule_id_2"],
      "contrast_note": "...",
      "cards": [ { card objects } ]
    }
  ]
}
```

### Complete File Content

Write `assets/data/prepositions.json` with the following content.

The `rules` section MUST contain all of these rules exactly:

```json
"rules": {
  "rule_in_enclosed_space": {
    "id": "rule_in_enclosed_space",
    "short": "IN — enclosed spaces, rooms, buildings, containers",
    "example": "in the room, in a box, in the car, in a hotel"
  },
  "rule_in_area": {
    "id": "rule_in_area",
    "short": "IN — countries, cities, regions, large open areas",
    "example": "in France, in London, in the north, in the park"
  },
  "rule_on_surface": {
    "id": "rule_on_surface",
    "short": "ON — surfaces (horizontal or vertical), things seen as flat",
    "example": "on the table, on the floor, on the wall, on the ceiling"
  },
  "rule_on_transport": {
    "id": "rule_on_transport",
    "short": "ON — public transport and large vehicles",
    "example": "on the bus, on a train, on a plane, on a ship"
  },
  "rule_at_specific_point": {
    "id": "rule_at_specific_point",
    "short": "AT — specific points, addresses, precise locations",
    "example": "at the station, at home, at the top, at the door"
  },
  "rule_at_event": {
    "id": "rule_at_event",
    "short": "AT — events, institutions, gatherings",
    "example": "at the party, at school, at work, at a concert"
  },
  "rule_in_long_period": {
    "id": "rule_in_long_period",
    "short": "IN — months, years, centuries, seasons, parts of the day",
    "example": "in January, in 2023, in the morning, in summer"
  },
  "rule_on_day": {
    "id": "rule_on_day",
    "short": "ON — days of the week, specific dates, named days",
    "example": "on Monday, on the 5th, on my birthday, on New Year's Day"
  },
  "rule_at_time": {
    "id": "rule_at_time",
    "short": "AT — clock times and fixed time points",
    "example": "at 5pm, at noon, at midnight, at dawn"
  },
  "rule_by_deadline": {
    "id": "rule_by_deadline",
    "short": "BY — no later than a certain point (deadline)",
    "example": "by Friday, by noon, by the end of the week"
  },
  "rule_until_continuous": {
    "id": "rule_until_continuous",
    "short": "UNTIL/TILL — continuously up to a point in time",
    "example": "until midnight, till Monday, until she arrives"
  },
  "rule_for_duration": {
    "id": "rule_for_duration",
    "short": "FOR — over a period of time (how long)",
    "example": "for two hours, for years, for a long time, for a week"
  },
  "rule_to_destination": {
    "id": "rule_to_destination",
    "short": "TO — movement toward a destination",
    "example": "go to school, travel to France, drive to work"
  },
  "rule_for_purpose": {
    "id": "rule_for_purpose",
    "short": "FOR — purpose, benefit, or intended recipient",
    "example": "for you, work for a company, for fun, a gift for her"
  },
  "rule_with_accompaniment": {
    "id": "rule_with_accompaniment",
    "short": "WITH — accompaniment, using a tool or ingredient",
    "example": "with friends, with a knife, pay with cash, coffee with milk"
  },
  "rule_from_origin": {
    "id": "rule_from_origin",
    "short": "FROM — starting point, origin, or source",
    "example": "from London, from the beginning, a letter from her"
  },
  "rule_of_possession": {
    "id": "rule_of_possession",
    "short": "OF — belonging, content, or part of a whole",
    "example": "the top of the hill, a cup of tea, a friend of mine"
  },
  "rule_about_topic": {
    "id": "rule_about_topic",
    "short": "ABOUT — concerning a topic or subject",
    "example": "talk about work, worried about money, a book about history"
  },
  "rule_irregular_collocation": {
    "id": "rule_irregular_collocation",
    "short": "Fixed phrase — this preposition does not follow spatial logic. It must be memorized.",
    "example": "good AT, interested IN, depend ON, responsible FOR"
  }
}
```

The `clusters` array MUST contain these 7 clusters in this order.
Each cluster below shows its required fields and a set of SEED CARDS.
After writing the seed cards, generate additional cards to meet the
MINIMUM TARGET for each cluster. Follow the seed card patterns exactly.
Ensure all distractors are plausible — never obviously wrong.
Vary subjects, tenses, and contexts across cards in the same cluster.

---

### Cluster 1: place_in_on_at

```json
{
  "id": "place_in_on_at",
  "title": "IN / ON / AT — Place",
  "subtitle": "Where exactly are you?",
  "prepositions": ["in", "on", "at"],
  "intro_rules": ["rule_in_enclosed_space", "rule_in_area", "rule_on_surface", "rule_on_transport", "rule_at_specific_point", "rule_at_event"],
  "contrast_note": "IN = inside an area or space. ON = touching a surface. AT = a precise point. Context decides.",
  "cards": [ SEED CARDS + GENERATED CARDS ]
}
```

**Seed cards for place_in_on_at (write these exactly):**

```json
{ "id": "p_001", "cluster_id": "place_in_on_at", "sentence": "She arrived ___ the airport just before midnight.", "correct": "at", "distractors": ["in", "on", "to"], "rule_id": "rule_at_specific_point", "tags": ["difficulty_1"], "is_famous": false, "is_irregular": false, "source": null },
{ "id": "p_002", "cluster_id": "place_in_on_at", "sentence": "The book is ___ the shelf above the desk.", "correct": "on", "distractors": ["in", "at", "under"], "rule_id": "rule_on_surface", "tags": ["difficulty_1"], "is_famous": false, "is_irregular": false, "source": null },
{ "id": "p_003", "cluster_id": "place_in_on_at", "sentence": "He grew up ___ a small village in the south.", "correct": "in", "distractors": ["on", "at", "from"], "rule_id": "rule_in_area", "tags": ["difficulty_1"], "is_famous": false, "is_irregular": false, "source": null },
{ "id": "p_004", "cluster_id": "place_in_on_at", "sentence": "We met ___ the corner of Park Street.", "correct": "at", "distractors": ["in", "on", "by"], "rule_id": "rule_at_specific_point", "tags": ["difficulty_1"], "is_famous": false, "is_irregular": false, "source": null },
{ "id": "p_005", "cluster_id": "place_in_on_at", "sentence": "There's a strange stain ___ the ceiling.", "correct": "on", "distractors": ["in", "at", "across"], "rule_id": "rule_on_surface", "tags": ["difficulty_1"], "is_famous": false, "is_irregular": false, "source": null },
{ "id": "p_006", "cluster_id": "place_in_on_at", "sentence": "She has lived ___ Japan for three years.", "correct": "in", "distractors": ["on", "at", "to"], "rule_id": "rule_in_area", "tags": ["difficulty_1"], "is_famous": false, "is_irregular": false, "source": null },
{ "id": "p_007", "cluster_id": "place_in_on_at", "sentence": "The children are playing ___ the garden.", "correct": "in", "distractors": ["on", "at", "through"], "rule_id": "rule_in_area", "tags": ["difficulty_1"], "is_famous": false, "is_irregular": false, "source": null },
{ "id": "p_008", "cluster_id": "place_in_on_at", "sentence": "He left his keys ___ the kitchen counter.", "correct": "on", "distractors": ["in", "at", "by"], "rule_id": "rule_on_surface", "tags": ["difficulty_1"], "is_famous": false, "is_irregular": false, "source": null },
{ "id": "p_009", "cluster_id": "place_in_on_at", "sentence": "I'll wait for you ___ the entrance.", "correct": "at", "distractors": ["in", "on", "by"], "rule_id": "rule_at_specific_point", "tags": ["difficulty_1"], "is_famous": false, "is_irregular": false, "source": null },
{ "id": "p_010", "cluster_id": "place_in_on_at", "sentence": "She works ___ the third floor of the building.", "correct": "on", "distractors": ["in", "at", "to"], "rule_id": "rule_on_surface", "tags": ["difficulty_2"], "is_famous": false, "is_irregular": false, "source": null },
{ "id": "p_011", "cluster_id": "place_in_on_at", "sentence": "We had a wonderful dinner ___ a restaurant by the river.", "correct": "at", "distractors": ["in", "on", "to"], "rule_id": "rule_at_event", "tags": ["difficulty_2"], "is_famous": false, "is_irregular": false, "source": null },
{ "id": "p_012", "cluster_id": "place_in_on_at", "sentence": "He fell asleep ___ the bus on the way home.", "correct": "on", "distractors": ["in", "at", "during"], "rule_id": "rule_on_transport", "tags": ["difficulty_2"], "is_famous": false, "is_irregular": false, "source": null }
```

**MINIMUM TARGET for place_in_on_at: 60 cards total.**
Generate 48 more cards (id: p_013 through p_060) following the patterns above.
Cover: rooms in a house, public buildings, cities and countries, transport,
outdoor spaces, precise points (desk, door, window, top, bottom, end),
events (conference, wedding, concert), difficulty levels 1–3.

---

### Cluster 2: time_in_on_at

```json
{
  "id": "time_in_on_at",
  "title": "IN / ON / AT — Time",
  "subtitle": "When does it happen?",
  "prepositions": ["in", "on", "at"],
  "intro_rules": ["rule_in_long_period", "rule_on_day", "rule_at_time"],
  "contrast_note": "IN = long periods. ON = days and dates. AT = clock times and fixed moments.",
  "cards": [ SEED CARDS + GENERATED CARDS ]
}
```

**Seed cards for time_in_on_at:**

```json
{ "id": "t_001", "cluster_id": "time_in_on_at", "sentence": "The meeting starts ___ 9 o'clock sharp.", "correct": "at", "distractors": ["in", "on", "by"], "rule_id": "rule_at_time", "tags": ["difficulty_1"], "is_famous": false, "is_irregular": false, "source": null },
{ "id": "t_002", "cluster_id": "time_in_on_at", "sentence": "She was born ___ a cold December morning.", "correct": "on", "distractors": ["in", "at", "during"], "rule_id": "rule_on_day", "tags": ["difficulty_2"], "is_famous": false, "is_irregular": false, "source": null },
{ "id": "t_003", "cluster_id": "time_in_on_at", "sentence": "We usually go skiing ___ winter.", "correct": "in", "distractors": ["on", "at", "during"], "rule_id": "rule_in_long_period", "tags": ["difficulty_1"], "is_famous": false, "is_irregular": false, "source": null },
{ "id": "t_004", "cluster_id": "time_in_on_at", "sentence": "The store opens ___ 8 in the morning.", "correct": "at", "distractors": ["in", "on", "from"], "rule_id": "rule_at_time", "tags": ["difficulty_1"], "is_famous": false, "is_irregular": false, "source": null },
{ "id": "t_005", "cluster_id": "time_in_on_at", "sentence": "He started his new job ___ Monday.", "correct": "on", "distractors": ["in", "at", "from"], "rule_id": "rule_on_day", "tags": ["difficulty_1"], "is_famous": false, "is_irregular": false, "source": null },
{ "id": "t_006", "cluster_id": "time_in_on_at", "sentence": "They got married ___ June 1998.", "correct": "in", "distractors": ["on", "at", "during"], "rule_id": "rule_in_long_period", "tags": ["difficulty_1"], "is_famous": false, "is_irregular": false, "source": null },
{ "id": "t_007", "cluster_id": "time_in_on_at", "sentence": "I always feel tired ___ the afternoon.", "correct": "in", "distractors": ["on", "at", "during"], "rule_id": "rule_in_long_period", "tags": ["difficulty_1"], "is_famous": false, "is_irregular": false, "source": null },
{ "id": "t_008", "cluster_id": "time_in_on_at", "sentence": "The ceremony will be held ___ the 15th of August.", "correct": "on", "distractors": ["in", "at", "by"], "rule_id": "rule_on_day", "tags": ["difficulty_1"], "is_famous": false, "is_irregular": false, "source": null },
{ "id": "t_009", "cluster_id": "time_in_on_at", "sentence": "Everything goes quiet ___ midnight.", "correct": "at", "distractors": ["in", "on", "by"], "rule_id": "rule_at_time", "tags": ["difficulty_1"], "is_famous": false, "is_irregular": false, "source": null },
{ "id": "t_010", "cluster_id": "time_in_on_at", "sentence": "She called me ___ my birthday.", "correct": "on", "distractors": ["in", "at", "for"], "rule_id": "rule_on_day", "tags": ["difficulty_2"], "is_famous": false, "is_irregular": false, "source": null }
```

**MINIMUM TARGET for time_in_on_at: 50 cards total.**
Generate 40 more cards (id: t_011 through t_050).
Cover: clock times, named meal times (at breakfast, at lunchtime), seasons,
months, years, decades, centuries, parts of the day (morning/afternoon/evening/night),
specific dates, holidays, weekdays vs weekends, difficulty levels 1–3.

---

### Cluster 3: duration_by_until_for

```json
{
  "id": "duration_by_until_for",
  "title": "BY / UNTIL / FOR — Time Spans",
  "subtitle": "How long, and when does it end?",
  "prepositions": ["by", "until", "for"],
  "intro_rules": ["rule_by_deadline", "rule_until_continuous", "rule_for_duration"],
  "contrast_note": "BY = deadline (finished no later than). UNTIL = continuous up to a point. FOR = total duration.",
  "cards": [ SEED CARDS + GENERATED CARDS ]
}
```

**Seed cards for duration_by_until_for:**

```json
{ "id": "d_001", "cluster_id": "duration_by_until_for", "sentence": "Please submit your report ___ Friday.", "correct": "by", "distractors": ["until", "for", "on"], "rule_id": "rule_by_deadline", "tags": ["difficulty_1"], "is_famous": false, "is_irregular": false, "source": null },
{ "id": "d_002", "cluster_id": "duration_by_until_for", "sentence": "She studied ___ three hours without a break.", "correct": "for", "distractors": ["by", "until", "during"], "rule_id": "rule_for_duration", "tags": ["difficulty_1"], "is_famous": false, "is_irregular": false, "source": null },
{ "id": "d_003", "cluster_id": "duration_by_until_for", "sentence": "We waited at the station ___ the last train arrived.", "correct": "until", "distractors": ["by", "for", "when"], "rule_id": "rule_until_continuous", "tags": ["difficulty_1"], "is_famous": false, "is_irregular": false, "source": null },
{ "id": "d_004", "cluster_id": "duration_by_until_for", "sentence": "I need this done ___ noon at the latest.", "correct": "by", "distractors": ["until", "for", "at"], "rule_id": "rule_by_deadline", "tags": ["difficulty_1"], "is_famous": false, "is_irregular": false, "source": null },
{ "id": "d_005", "cluster_id": "duration_by_until_for", "sentence": "They have been friends ___ over twenty years.", "correct": "for", "distractors": ["by", "until", "since"], "rule_id": "rule_for_duration", "tags": ["difficulty_2"], "is_famous": false, "is_irregular": false, "source": null },
{ "id": "d_006", "cluster_id": "duration_by_until_for", "sentence": "He kept working ___ he couldn't keep his eyes open.", "correct": "until", "distractors": ["by", "for", "while"], "rule_id": "rule_until_continuous", "tags": ["difficulty_2"], "is_famous": false, "is_irregular": false, "source": null },
{ "id": "d_007", "cluster_id": "duration_by_until_for", "sentence": "Can you finish the painting ___ the end of the month?", "correct": "by", "distractors": ["until", "for", "at"], "rule_id": "rule_by_deadline", "tags": ["difficulty_2"], "is_famous": false, "is_irregular": false, "source": null },
{ "id": "d_008", "cluster_id": "duration_by_until_for", "sentence": "The museum stays open ___ 9 o'clock in the evening.", "correct": "until", "distractors": ["by", "for", "at"], "rule_id": "rule_until_continuous", "tags": ["difficulty_1"], "is_famous": false, "is_irregular": false, "source": null }
```

**MINIMUM TARGET for duration_by_until_for: 40 cards total.**
Generate 32 more cards (id: d_009 through d_040).
Cover: work deadlines, waiting scenarios, durations of trips/relationships/jobs/illnesses,
shop/office opening hours, contracts with end dates, difficulty levels 1–3.
Include some difficulty_3 cards where BY vs UNTIL distinction is genuinely tricky.

---

### Cluster 4: movement_to_for_with

```json
{
  "id": "movement_to_for_with",
  "title": "TO / FOR / WITH",
  "subtitle": "Direction, purpose, and company",
  "prepositions": ["to", "for", "with"],
  "intro_rules": ["rule_to_destination", "rule_for_purpose", "rule_with_accompaniment"],
  "contrast_note": "TO = movement or direction. FOR = purpose or recipient. WITH = accompanying or using.",
  "cards": [ SEED CARDS + GENERATED CARDS ]
}
```

**Seed cards for movement_to_for_with:**

```json
{ "id": "m_001", "cluster_id": "movement_to_for_with", "sentence": "She walked ___ the library after school.", "correct": "to", "distractors": ["for", "with", "into"], "rule_id": "rule_to_destination", "tags": ["difficulty_1"], "is_famous": false, "is_irregular": false, "source": null },
{ "id": "m_002", "cluster_id": "movement_to_for_with", "sentence": "He bought flowers ___ his mother.", "correct": "for", "distractors": ["to", "with", "of"], "rule_id": "rule_for_purpose", "tags": ["difficulty_1"], "is_famous": false, "is_irregular": false, "source": null },
{ "id": "m_003", "cluster_id": "movement_to_for_with", "sentence": "She cut the bread ___ a sharp knife.", "correct": "with", "distractors": ["to", "for", "by"], "rule_id": "rule_with_accompaniment", "tags": ["difficulty_1"], "is_famous": false, "is_irregular": false, "source": null },
{ "id": "m_004", "cluster_id": "movement_to_for_with", "sentence": "They are travelling ___ Rome next week.", "correct": "to", "distractors": ["for", "with", "in"], "rule_id": "rule_to_destination", "tags": ["difficulty_1"], "is_famous": false, "is_irregular": false, "source": null },
{ "id": "m_005", "cluster_id": "movement_to_for_with", "sentence": "This sandwich is ___ you — I made it specially.", "correct": "for", "distractors": ["to", "with", "of"], "rule_id": "rule_for_purpose", "tags": ["difficulty_1"], "is_famous": false, "is_irregular": false, "source": null },
{ "id": "m_006", "cluster_id": "movement_to_for_with", "sentence": "He came home ___ two bags of groceries.", "correct": "with", "distractors": ["to", "for", "and"], "rule_id": "rule_with_accompaniment", "tags": ["difficulty_1"], "is_famous": false, "is_irregular": false, "source": null },
{ "id": "m_007", "cluster_id": "movement_to_for_with", "sentence": "She sent a long email ___ her manager.", "correct": "to", "distractors": ["for", "with", "at"], "rule_id": "rule_to_destination", "tags": ["difficulty_2"], "is_famous": false, "is_irregular": false, "source": null },
{ "id": "m_008", "cluster_id": "movement_to_for_with", "sentence": "He goes jogging ___ his dog every morning.", "correct": "with", "distractors": ["to", "for", "and"], "rule_id": "rule_with_accompaniment", "tags": ["difficulty_1"], "is_famous": false, "is_irregular": false, "source": null }
```

**MINIMUM TARGET for movement_to_for_with: 40 cards total.**
Generate 32 more (id: m_009 through m_040).
Cover: travel destinations, giving/sending to people, tools used (write with, paint with, pay with),
accompaniment (go with, come with, arrive with), purpose phrases (for fun, for work, for sale,
looking for, waiting for), difficulty levels 1–3.

---

### Cluster 5: origin_of_about_from

```json
{
  "id": "origin_of_about_from",
  "title": "FROM / OF / ABOUT",
  "subtitle": "Origins, content, and topics",
  "prepositions": ["from", "of", "about"],
  "intro_rules": ["rule_from_origin", "rule_of_possession", "rule_about_topic"],
  "contrast_note": "FROM = starting point or source. OF = part, content, or belonging. ABOUT = the topic or subject.",
  "cards": [ SEED CARDS + GENERATED CARDS ]
}
```

**Seed cards for origin_of_about_from:**

```json
{ "id": "o_001", "cluster_id": "origin_of_about_from", "sentence": "She received a letter ___ her old friend in Canada.", "correct": "from", "distractors": ["of", "about", "by"], "rule_id": "rule_from_origin", "tags": ["difficulty_1"], "is_famous": false, "is_irregular": false, "source": null },
{ "id": "o_002", "cluster_id": "origin_of_about_from", "sentence": "He told me everything ___ his trip to Morocco.", "correct": "about", "distractors": ["from", "of", "on"], "rule_id": "rule_about_topic", "tags": ["difficulty_1"], "is_famous": false, "is_irregular": false, "source": null },
{ "id": "o_003", "cluster_id": "origin_of_about_from", "sentence": "This is a picture ___ my grandmother as a young woman.", "correct": "of", "distractors": ["from", "about", "with"], "rule_id": "rule_of_possession", "tags": ["difficulty_1"], "is_famous": false, "is_irregular": false, "source": null },
{ "id": "o_004", "cluster_id": "origin_of_about_from", "sentence": "Where are you originally ___?", "correct": "from", "distractors": ["of", "about", "at"], "rule_id": "rule_from_origin", "tags": ["difficulty_1"], "is_famous": false, "is_irregular": false, "source": null },
{ "id": "o_005", "cluster_id": "origin_of_about_from", "sentence": "They argued ___ money for hours.", "correct": "about", "distractors": ["from", "of", "on"], "rule_id": "rule_about_topic", "tags": ["difficulty_1"], "is_famous": false, "is_irregular": false, "source": null },
{ "id": "o_006", "cluster_id": "origin_of_about_from", "sentence": "The roof ___ the old house was leaking badly.", "correct": "of", "distractors": ["from", "about", "in"], "rule_id": "rule_of_possession", "tags": ["difficulty_1"], "is_famous": false, "is_irregular": false, "source": null },
{ "id": "o_007", "cluster_id": "origin_of_about_from", "sentence": "She comes ___ a long line of musicians.", "correct": "from", "distractors": ["of", "about", "in"], "rule_id": "rule_from_origin", "tags": ["difficulty_2"], "is_famous": false, "is_irregular": false, "source": null },
{ "id": "o_008", "cluster_id": "origin_of_about_from", "sentence": "The documentary is ___ the lives of deep-sea fishermen.", "correct": "about", "distractors": ["from", "of", "on"], "rule_id": "rule_about_topic", "tags": ["difficulty_1"], "is_famous": false, "is_irregular": false, "source": null }
```

**MINIMUM TARGET for origin_of_about_from: 40 cards total.**
Generate 32 more (id: o_009 through o_040).
Cover: origins (where things come from, where people are from), content/belonging (a piece of, part of,
the end of, a bottle of, a kind of), topics (complain about, know about, dream about, worried about,
curious about), difficulty levels 1–3.

---

### Cluster 6: collocations

```json
{
  "id": "collocations",
  "title": "Fixed Phrases",
  "subtitle": "These don't follow rules — you just learn them.",
  "prepositions": ["in", "on", "at", "to", "for", "with", "of", "about", "from"],
  "intro_rules": ["rule_irregular_collocation"],
  "contrast_note": "These verb + preposition and adjective + preposition pairs are fixed. There is no spatial logic. Memorize them as units.",
  "cards": [ SEED CARDS + GENERATED CARDS ]
}
```

**Seed cards for collocations:**

```json
{ "id": "c_001", "cluster_id": "collocations", "sentence": "He has always been very good ___ languages.", "correct": "at", "distractors": ["in", "with", "for"], "rule_id": "rule_irregular_collocation", "tags": ["difficulty_2", "adjective_prep"], "is_famous": false, "is_irregular": true, "source": null },
{ "id": "c_002", "cluster_id": "collocations", "sentence": "She is really interested ___ marine biology.", "correct": "in", "distractors": ["at", "about", "for"], "rule_id": "rule_irregular_collocation", "tags": ["difficulty_1", "adjective_prep"], "is_famous": false, "is_irregular": true, "source": null },
{ "id": "c_003", "cluster_id": "collocations", "sentence": "Everything depends ___ the weather tomorrow.", "correct": "on", "distractors": ["in", "at", "from"], "rule_id": "rule_irregular_collocation", "tags": ["difficulty_2", "verb_prep"], "is_famous": false, "is_irregular": true, "source": null },
{ "id": "c_004", "cluster_id": "collocations", "sentence": "She feels very proud ___ her daughter's achievement.", "correct": "of", "distractors": ["for", "about", "in"], "rule_id": "rule_irregular_collocation", "tags": ["difficulty_1", "adjective_prep"], "is_famous": false, "is_irregular": true, "source": null },
{ "id": "c_005", "cluster_id": "collocations", "sentence": "He is responsible ___ the entire project.", "correct": "for", "distractors": ["of", "about", "with"], "rule_id": "rule_irregular_collocation", "tags": ["difficulty_2", "adjective_prep"], "is_famous": false, "is_irregular": true, "source": null },
{ "id": "c_006", "cluster_id": "collocations", "sentence": "They listened carefully ___ the instructions.", "correct": "to", "distractors": ["at", "for", "with"], "rule_id": "rule_irregular_collocation", "tags": ["difficulty_1", "verb_prep"], "is_famous": false, "is_irregular": true, "source": null },
{ "id": "c_007", "cluster_id": "collocations", "sentence": "She agreed ___ everything he said.", "correct": "with", "distractors": ["to", "on", "about"], "rule_id": "rule_irregular_collocation", "tags": ["difficulty_2", "verb_prep"], "is_famous": false, "is_irregular": true, "source": null },
{ "id": "c_008", "cluster_id": "collocations", "sentence": "He is married ___ a doctor he met in university.", "correct": "to", "distractors": ["with", "by", "for"], "rule_id": "rule_irregular_collocation", "tags": ["difficulty_2", "adjective_prep"], "is_famous": false, "is_irregular": true, "source": null },
{ "id": "c_009", "cluster_id": "collocations", "sentence": "She is afraid ___ flying, so she takes the train.", "correct": "of", "distractors": ["about", "from", "with"], "rule_id": "rule_irregular_collocation", "tags": ["difficulty_1", "adjective_prep"], "is_famous": false, "is_irregular": true, "source": null },
{ "id": "c_010", "cluster_id": "collocations", "sentence": "They applied ___ a grant to fund their research.", "correct": "for", "distractors": ["to", "at", "about"], "rule_id": "rule_irregular_collocation", "tags": ["difficulty_2", "verb_prep"], "is_famous": false, "is_irregular": true, "source": null }
```

**MINIMUM TARGET for collocations: 50 cards total.**
Generate 40 more (id: c_011 through c_050).
Include these pairs (at minimum): tired of, full of, similar to, different from,
grateful for, famous for, angry with/at, worried about, concentrate on, rely on,
consist of, belong to, think about, dream of/about, wait for, look at, pay for,
compare with, suffer from, result in, believe in, insist on, succeed in, specialise in.
Each card should test one specific collocation. Distractors must always be other
prepositions that could plausibly (but incorrectly) follow that adjective or verb.

---

### Cluster 7: famous_lines

```json
{
  "id": "famous_lines",
  "title": "You've Heard This Before",
  "subtitle": "Songs, films, and famous quotes",
  "prepositions": ["in", "on", "at", "to", "for", "with", "of", "about", "from", "by", "over"],
  "intro_rules": [],
  "contrast_note": "You probably know these — now identify the preposition.",
  "cards": [ THE FOLLOWING CARDS EXACTLY ]
}
```

**Write these famous_lines cards exactly as given:**

```json
{ "id": "f_001", "cluster_id": "famous_lines", "sentence": "May the Force be ___ you.", "correct": "with", "distractors": ["for", "in", "on"], "rule_id": "rule_with_accompaniment", "tags": ["difficulty_1"], "is_famous": true, "is_irregular": false, "source": "Star Wars (1977)" },
{ "id": "f_002", "cluster_id": "famous_lines", "sentence": "Welcome ___ the Hotel California.", "correct": "to", "distractors": ["in", "at", "for"], "rule_id": "rule_to_destination", "tags": ["difficulty_1"], "is_famous": true, "is_irregular": false, "source": "Hotel California — Eagles (1977)" },
{ "id": "f_003", "cluster_id": "famous_lines", "sentence": "We're living ___ a prayer.", "correct": "on", "distractors": ["in", "for", "by"], "rule_id": "rule_irregular_collocation", "tags": ["difficulty_2"], "is_famous": true, "is_irregular": true, "source": "Livin' on a Prayer — Bon Jovi (1986)" },
{ "id": "f_004", "cluster_id": "famous_lines", "sentence": "The answer is blowin' ___ the wind.", "correct": "in", "distractors": ["on", "with", "through"], "rule_id": "rule_in_enclosed_space", "tags": ["difficulty_1"], "is_famous": true, "is_irregular": false, "source": "Blowin' in the Wind — Bob Dylan (1963)" },
{ "id": "f_005", "cluster_id": "famous_lines", "sentence": "The Sound ___ Silence.", "correct": "of", "distractors": ["from", "in", "about"], "rule_id": "rule_of_possession", "tags": ["difficulty_1"], "is_famous": true, "is_irregular": false, "source": "The Sound of Silence — Simon & Garfunkel (1964)" },
{ "id": "f_006", "cluster_id": "famous_lines", "sentence": "Lean ___ me, when you're not strong.", "correct": "on", "distractors": ["to", "with", "by"], "rule_id": "rule_irregular_collocation", "tags": ["difficulty_2"], "is_famous": true, "is_irregular": true, "source": "Lean on Me — Bill Withers (1972)" },
{ "id": "f_007", "cluster_id": "famous_lines", "sentence": "Stand ___ me. Don't be afraid.", "correct": "by", "distractors": ["with", "for", "near"], "rule_id": "rule_irregular_collocation", "tags": ["difficulty_2"], "is_famous": true, "is_irregular": true, "source": "Stand by Me — Ben E. King (1961)" },
{ "id": "f_008", "cluster_id": "famous_lines", "sentence": "You've got a friend ___ me.", "correct": "in", "distractors": ["with", "for", "from"], "rule_id": "rule_irregular_collocation", "tags": ["difficulty_2"], "is_famous": true, "is_irregular": true, "source": "You've Got a Friend in Me — Randy Newman / Toy Story (1995)" },
{ "id": "f_009", "cluster_id": "famous_lines", "sentence": "Don't you forget ___ me.", "correct": "about", "distractors": ["of", "from", "with"], "rule_id": "rule_about_topic", "tags": ["difficulty_1"], "is_famous": true, "is_irregular": false, "source": "Don't You (Forget About Me) — Simple Minds (1985)" },
{ "id": "f_010", "cluster_id": "famous_lines", "sentence": "I'll be there ___ you.", "correct": "for", "distractors": ["with", "to", "at"], "rule_id": "rule_for_purpose", "tags": ["difficulty_1"], "is_famous": true, "is_irregular": false, "source": "I'll Be There for You — The Rembrandts / Friends (1994)" },
{ "id": "f_011", "cluster_id": "famous_lines", "sentence": "Born ___ the USA.", "correct": "in", "distractors": ["on", "at", "from"], "rule_id": "rule_in_area", "tags": ["difficulty_1"], "is_famous": true, "is_irregular": false, "source": "Born in the USA — Bruce Springsteen (1984)" },
{ "id": "f_012", "cluster_id": "famous_lines", "sentence": "Walking ___ sunshine.", "correct": "on", "distractors": ["in", "with", "through"], "rule_id": "rule_irregular_collocation", "tags": ["difficulty_2"], "is_famous": true, "is_irregular": true, "source": "Walking on Sunshine — Katrina and the Waves (1985)" },
{ "id": "f_013", "cluster_id": "famous_lines", "sentence": "Take ___ me.", "correct": "on", "distractors": ["to", "in", "with"], "rule_id": "rule_irregular_collocation", "tags": ["difficulty_3"], "is_famous": true, "is_irregular": true, "source": "Take On Me — A-ha (1985)" },
{ "id": "f_014", "cluster_id": "famous_lines", "sentence": "Riders ___ the storm.", "correct": "on", "distractors": ["in", "through", "of"], "rule_id": "rule_on_surface", "tags": ["difficulty_2"], "is_famous": true, "is_irregular": false, "source": "Riders on the Storm — The Doors (1971)" },
{ "id": "f_015", "cluster_id": "famous_lines", "sentence": "Singin' ___ the rain.", "correct": "in", "distractors": ["on", "through", "under"], "rule_id": "rule_in_area", "tags": ["difficulty_1"], "is_famous": true, "is_irregular": false, "source": "Singin' in the Rain — Gene Kelly (1952)" },
{ "id": "f_016", "cluster_id": "famous_lines", "sentence": "That's one small step ___ man.", "correct": "for", "distractors": ["of", "to", "by"], "rule_id": "rule_for_purpose", "tags": ["difficulty_1"], "is_famous": true, "is_irregular": false, "source": "Neil Armstrong, Moon landing (1969)" },
{ "id": "f_017", "cluster_id": "famous_lines", "sentence": "Bridge ___ troubled water.", "correct": "over", "distractors": ["on", "through", "above"], "rule_id": "rule_irregular_collocation", "tags": ["difficulty_2"], "is_famous": true, "is_irregular": false, "source": "Bridge over Troubled Water — Simon & Garfunkel (1970)" },
{ "id": "f_018", "cluster_id": "famous_lines", "sentence": "Get ___ the bus, Gus.", "correct": "on", "distractors": ["in", "off", "to"], "rule_id": "rule_on_transport", "tags": ["difficulty_1"], "is_famous": true, "is_irregular": false, "source": "50 Ways to Leave Your Lover — Simon & Garfunkel (1975)" },
{ "id": "f_019", "cluster_id": "famous_lines", "sentence": "Reach ___ the sky!", "correct": "for", "distractors": ["to", "up", "at"], "rule_id": "rule_for_purpose", "tags": ["difficulty_1"], "is_famous": true, "is_irregular": false, "source": "Toy Story — Woody (1995)" },
{ "id": "f_020", "cluster_id": "famous_lines", "sentence": "I'm ___ the top of the world, Ma.", "correct": "on", "distractors": ["at", "in", "to"], "rule_id": "rule_on_surface", "tags": ["difficulty_2"], "is_famous": true, "is_irregular": false, "source": "Top of the World — The Carpenters (1972)" },
{ "id": "f_021", "cluster_id": "famous_lines", "sentence": "Knock ___ heaven's door.", "correct": "on", "distractors": ["at", "to", "for"], "rule_id": "rule_on_surface", "tags": ["difficulty_2"], "is_famous": true, "is_irregular": false, "source": "Knockin' on Heaven's Door — Bob Dylan (1973)" },
{ "id": "f_022", "cluster_id": "famous_lines", "sentence": "Message ___ a bottle.", "correct": "in", "distractors": ["on", "from", "inside"], "rule_id": "rule_in_enclosed_space", "tags": ["difficulty_1"], "is_famous": true, "is_irregular": false, "source": "Message in a Bottle — The Police (1979)" },
{ "id": "f_023", "cluster_id": "famous_lines", "sentence": "Dancing ___ the moonlight.", "correct": "in", "distractors": ["on", "under", "by"], "rule_id": "rule_in_area", "tags": ["difficulty_1"], "is_famous": true, "is_irregular": false, "source": "Dancing in the Moonlight — King Harvest (1972)" },
{ "id": "f_024", "cluster_id": "famous_lines", "sentence": "In the name ___ love.", "correct": "of", "distractors": ["from", "for", "about"], "rule_id": "rule_of_possession", "tags": ["difficulty_1"], "is_famous": true, "is_irregular": false, "source": "Pride (In the Name of Love) — U2 (1984)" },
{ "id": "f_025", "cluster_id": "famous_lines", "sentence": "Life is like a box ___ chocolates.", "correct": "of", "distractors": ["with", "from", "full"], "rule_id": "rule_of_possession", "tags": ["difficulty_1"], "is_famous": true, "is_irregular": false, "source": "Forrest Gump (1994)" },
{ "id": "f_026", "cluster_id": "famous_lines", "sentence": "Fight ___ your right to party.", "correct": "for", "distractors": ["on", "with", "about"], "rule_id": "rule_for_purpose", "tags": ["difficulty_1"], "is_famous": true, "is_irregular": false, "source": "(You Gotta) Fight for Your Right — Beastie Boys (1986)" },
{ "id": "f_027", "cluster_id": "famous_lines", "sentence": "Waiting ___ a girl like you.", "correct": "for", "distractors": ["on", "with", "to"], "rule_id": "rule_for_purpose", "tags": ["difficulty_1"], "is_famous": true, "is_irregular": false, "source": "Waiting for a Girl Like You — Foreigner (1981)" },
{ "id": "f_028", "cluster_id": "famous_lines", "sentence": "Thinking ___ you.", "correct": "of", "distractors": ["about", "for", "with"], "rule_id": "rule_about_topic", "tags": ["difficulty_3"], "is_famous": true, "is_irregular": false, "source": "Thinking of You — Katy Perry (2009) / various" },
{ "id": "f_029", "cluster_id": "famous_lines", "sentence": "On the road ___ nowhere.", "correct": "to", "distractors": ["for", "of", "towards"], "rule_id": "rule_to_destination", "tags": ["difficulty_1"], "is_famous": true, "is_irregular": false, "source": "Road to Nowhere — Talking Heads (1985)" },
{ "id": "f_030", "cluster_id": "famous_lines", "sentence": "Somewhere ___ a rainbow.", "correct": "over", "distractors": ["above", "beyond", "through"], "rule_id": "rule_irregular_collocation", "tags": ["difficulty_1"], "is_famous": true, "is_irregular": false, "source": "Somewhere Over the Rainbow — Wizard of Oz (1939)" }
```

**famous_lines: 30 cards total. Write exactly the 30 cards above — no additions needed.**

---

## Step 5 — Model Classes

Create the following Dart files. Each model must implement `fromJson` and `toJson`.

### lib/models/rule.dart

```dart
class Rule {
  final String id;
  final String short;
  final String example;

  const Rule({required this.id, required this.short, required this.example});

  factory Rule.fromJson(Map<String, dynamic> json) => Rule(
        id: json['id'] as String,
        short: json['short'] as String,
        example: json['example'] as String,
      );
}
```

### lib/models/card_item.dart

```dart
class CardItem {
  final String id;
  final String clusterId;
  final String sentence;
  final String correct;
  final List<String> distractors;
  final String ruleId;
  final List<String> tags;
  final bool isFamous;
  final bool isIrregular;
  final String? source;

  const CardItem({
    required this.id,
    required this.clusterId,
    required this.sentence,
    required this.correct,
    required this.distractors,
    required this.ruleId,
    required this.tags,
    required this.isFamous,
    required this.isIrregular,
    this.source,
  });

  factory CardItem.fromJson(Map<String, dynamic> json) => CardItem(
        id: json['id'] as String,
        clusterId: json['cluster_id'] as String,
        sentence: json['sentence'] as String,
        correct: json['correct'] as String,
        distractors: List<String>.from(json['distractors'] as List),
        ruleId: json['rule_id'] as String,
        tags: List<String>.from(json['tags'] as List),
        isFamous: json['is_famous'] as bool,
        isIrregular: json['is_irregular'] as bool,
        source: json['source'] as String?,
      );

  /// Returns the answer options (correct + distractors) in a shuffled order.
  /// Shuffle is seeded by card id so it is consistent within a session.
  List<String> get options {
    final all = [correct, ...distractors];
    all.shuffle();
    return all;
  }

  int get difficulty {
    if (tags.contains('difficulty_3')) return 3;
    if (tags.contains('difficulty_2')) return 2;
    return 1;
  }
}
```

### lib/models/cluster.dart

```dart
class Cluster {
  final String id;
  final String title;
  final String subtitle;
  final List<String> prepositions;
  final List<String> introRules;
  final String contrastNote;
  final List<CardItem> cards;

  const Cluster({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.prepositions,
    required this.introRules,
    required this.contrastNote,
    required this.cards,
  });

  factory Cluster.fromJson(Map<String, dynamic> json, List<CardItem> clusterCards) =>
      Cluster(
        id: json['id'] as String,
        title: json['title'] as String,
        subtitle: json['subtitle'] as String,
        prepositions: List<String>.from(json['prepositions'] as List),
        introRules: List<String>.from(json['intro_rules'] as List),
        contrastNote: json['contrast_note'] as String? ?? '',
        cards: clusterCards,
      );
}
```

### lib/models/card_progress.dart

This model is stored in Hive. Use `@HiveType` annotations.

```dart
import 'package:hive/hive.dart';

part 'card_progress.g.dart';

@HiveType(typeId: 0)
class CardProgress extends HiveObject {
  @HiveField(0)
  String cardId;

  @HiveField(1)
  int streak; // consecutive correct answers

  @HiveField(2)
  int attemptsTotal;

  @HiveField(3)
  int correctTotal;

  @HiveField(4)
  bool mastered; // true when streak >= 3

  @HiveField(5)
  int lastSeenTimestamp; // millisecondsSinceEpoch, 0 if never seen

  CardProgress({
    required this.cardId,
    this.streak = 0,
    this.attemptsTotal = 0,
    this.correctTotal = 0,
    this.mastered = false,
    this.lastSeenTimestamp = 0,
  });

  void recordCorrect() {
    attemptsTotal++;
    correctTotal++;
    streak++;
    if (streak >= 3) mastered = true;
    lastSeenTimestamp = DateTime.now().millisecondsSinceEpoch;
    save();
  }

  void recordWrong() {
    attemptsTotal++;
    streak = 0;
    mastered = false;
    lastSeenTimestamp = DateTime.now().millisecondsSinceEpoch;
    save();
  }
}
```

### lib/models/app_state.dart

```dart
import 'package:hive/hive.dart';

part 'app_state.g.dart';

@HiveType(typeId: 1)
class AppState extends HiveObject {
  @HiveField(0)
  String lastClusterId;

  @HiveField(1)
  int totalSessionsCompleted;

  AppState({
    this.lastClusterId = '',
    this.totalSessionsCompleted = 0,
  });
}
```

---

## Step 6 — Generate Hive Adapters

After writing the model files, run:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

This generates `card_progress.g.dart` and `app_state.g.dart`.

---

## Step 7 — Stub main.dart

Write `lib/main.dart` with a minimal scaffold to confirm the project compiles:

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(const PrepWiseApp());
}

class PrepWiseApp extends StatelessWidget {
  const PrepWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PrepWise',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('PrepWise')),
        body: const Center(child: Text('Session 01 complete.')),
      ),
    );
  }
}
```

---

## Verification

Run `flutter run` and confirm:
- App launches on device with no errors
- AppBar shows "PrepWise"
- No analysis warnings in `flutter analyze`

Do NOT proceed to Session 02 until this passes cleanly.
