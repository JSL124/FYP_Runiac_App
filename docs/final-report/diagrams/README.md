# Chapter 3 and Annex G — diagram sources

PlantUML sources for the four figures of Chapter 3 (Database Design) and Annex G
(Detailed Firestore Schema Reference).

| File | Figure | Placed at |
| --- | --- | --- |
| `figure-3-1-entity-model.puml` | Figure 3.1 — Entity-relationship model | Chapter 3 §3.2 |
| `figure-3-2-trust-boundary.puml` | Figure 3.2 — Trust boundary | Chapter 3 §3.4 |
| `figure-g-1-activity-lifecycle.puml` | Figure G.1 — Activity document lifecycle | Annex G §G.7 |
| `figure-g-2-leaderboard-aggregation.puml` | Figure G.2 — Leaderboard aggregation data flow | Annex G §G.9 |

## Rendering

Requires Java and Graphviz (`dot`).

```bash
java -jar plantuml.jar -tpng -Sdpi=150 *.puml     # raster, for Word
java -jar plantuml.jar -tsvg *.puml               # vector, scales cleanly
```

Fields shown in Figure 3.1 are the identifying and relating ones only; the
complete field list for every entity is in the tables of Chapter 3 §3.3. If a
field is added to an entity there, add it here only if it is a key or a
reference — the diagram is meant to stay readable at one page.
