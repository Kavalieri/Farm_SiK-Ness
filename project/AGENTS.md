# Project Agents Instructions (Godot)

## Context
This directory contains the **Godot 4.5.1** game project.

## Guidelines
1.  **GDScript Style:**
    -   **Static Typing:** MANDATORY (`var health: int = 100`, `func get_damage() -> int:`).
    -   **Naming:** `snake_case` for files/vars/funcs. `PascalCase` for Classes/Nodes.
2.  **Scene Structure:**
    -   Keep scenes modular and small.
    -   Use `Unique Names` (%) for accessing critical nodes within a scene.
    -   **Folder Structure:** `scenes/`, `scripts/`, `resources/`, `assets/`.
3.  **Resources:** Use `Resource` classes for ALL static data (Buildings, Items, Upgrades).
4.  **Singletons:** Only for truly global state (`GameManager`, `SaveManager`).

## Workflow & Rules
-   **Reuse First:** Check `scripts/core` and `scripts/resources` before creating new logic.
-   **No Magic Numbers:** Use `const` or `export var` for configurable values.
-   **Update `AGENTS.md`** if new architectural patterns are introduced.

