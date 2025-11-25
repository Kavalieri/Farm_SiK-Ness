# Project Agents Instructions (Godot)

## Context
This directory contains the **Godot 4.5.1** game project.

## Guidelines
1.  **GDScript Style:**
    -   **Static Typing:** MANDATORY (`var health: int = 100`, `func get_damage() -> int:`).
    -   **Naming:** `snake_case` for files/vars/funcs. `PascalCase` for Classes/Nodes.
2.  **Scene Structure & Modularity:**
    -   **Everything is a Scene:** Avoid creating nodes purely via code (`Node.new()`). Create `.tscn` files for reusable elements (UI widgets, game entities).
    -   **Keep it Small:** Break down complex scenes into smaller nested scenes.
    -   **Use Exports:** Expose properties via `@export` to make scenes configurable in the Inspector.
    -   **Unique Names:** Use `%UniqueName` for accessing critical nodes within a scene hierarchy.
    -   **Folder Structure:** `scenes/`, `scripts/`, `resources/`, `assets/`.
3.  **Resources:** Use `Resource` classes for ALL static data (Buildings, Items, Upgrades).
4.  **Singletons:** Only for truly global state (`GameManager`, `SaveManager`).

## Workflow & Rules
-   **Reuse First:** Check `scripts/core` and `scripts/resources` before creating new logic.
-   **No Magic Numbers:** Use `const` or `export var` for configurable values.
-   **Update `AGENTS.md`** if new architectural patterns are introduced.

## Adding New Content

### 1. Adding a New Item (Resource)
1.  Navigate to `resources/data/items/`.
2.  Create a new Resource of type `ItemData`.
3.  Set the `id` (unique string), `name`, `base_value`, and `weight`.
4.  The game will automatically load it on startup via `GameManager`.

### 2. Adding a New Building
1.  Navigate to `resources/data/buildings/`.
2.  Create a new Resource of type `BuildingData`.
3.  Configure properties:
    -   `id`: Unique identifier.
    -   `custom_scene`: (Optional) Link to a `.tscn` if special logic is needed.
    -   `produced_resource_id`: ID of the item it produces (if any).
    -   `base_production`: Amount produced per cycle.
4.  If custom logic is needed, create a script extending `BuildingEntity` and a scene inheriting `BuildingEntity.tscn`.

