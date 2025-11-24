# Project Agents Instructions (Godot)

## Context
This directory contains the **Godot 4.5.1** game project.

## Guidelines
1.  **GDScript:** Use static typing (`: type`) whenever possible.
2.  **Scene Structure:**
    -   Keep scenes modular.
    -   Use `Unique Names` (%) for accessing critical nodes within a scene.
3.  **Resources:** Use `Resource` classes for data (Buildings, Items, Upgrades).
4.  **Singletons:** Only for truly global state (`GameManager`, `SaveManager`).

## Workflow
-   When implementing a feature defined in an Issue, work primarily within this directory.
-   Update `AGENTS.md` if new architectural patterns are introduced.
