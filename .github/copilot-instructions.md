# Copilot Instructions for Farm SiK-Ness

## 1. Project Overview
**Farm SiK-Ness** is a cross-platform Idle/Management game built with **Godot 4.5.1** and **GDScript**.
The core loop involves placing Tetris-like buildings on a grid to maximize production through adjacency synergies.

## 2. Workflow: Issue-Driven Development
We strictly follow an Issue-Driven Development workflow using GitHub Issues.

### Creating a New Task
Before starting any implementation, you MUST create a GitHub Issue with the following structure:
1.  **Objective:** Clear statement of what needs to be achieved.
2.  **Analysis:** Current state of the project and requirements for this task.
3.  **Implementation Proposal:** Detailed plan, including scripts, scenes, and algorithms to be used.

### Working on a Task
1.  Reference the Issue ID in commits (e.g., `feat: implement grid logic #1`).
2.  Update the Issue with comments for significant progress or changes in design.
3.  Close the Issue only when the objective is fully met and tested.

## 3. Tech Stack & Conventions
-   **Engine:** Godot 4.5.1 (Compatibility Mode).
-   **Language:** GDScript (Static typing **MANDATORY**: `var x: int = 0`).
-   **Naming Conventions:**
    -   **Files/Folders:** `snake_case` (e.g., `player_controller.gd`, `main_menu.tscn`).
    -   **Classes/Nodes:** `PascalCase` (e.g., `class_name BuildingData`, `Node2D`).
    -   **Variables/Functions:** `snake_case` (e.g., `func calculate_total()`, `var current_speed`).
    -   **Constants:** `SCREAMING_SNAKE_CASE` (e.g., `const MAX_SPEED = 100`).
-   **Architecture:**
    -   **Managers (Singletons):** For global state ONLY (GameManager, SaveManager).
    -   **Resources (.tres):** For ALL static data (BuildingData, ItemData).
    -   **Composition:** Prefer small, reusable components over deep inheritance.
-   **Modularity & Scenes:**
    -   **Everything is a Scene:** Do NOT generate complex UI or game objects purely via code. Create `.tscn` files for everything (e.g., `BuildingEntity.tscn`, `InventorySlot.tscn`).
    -   **Instantiate, Don't Construct:** Use `preload("res://...").instantiate()` instead of `new()`.
    -   **Exports:** Use `@export` variables to configure instances in the editor, not just in code.

## 4. Agent Behavior & Rules
-   **NO Condescension:** Be direct, professional, and concise. Do not over-explain simple concepts.
-   **Reuse First:** Before creating ANY new script or scene, CHECK if an existing one can be reused or extended.
-   **Directory Hygiene:** NEVER create files in the root directory. Use `project/` for code/assets and `docs/` for documentation.
-   **No Hallucinations:** If a tool fails, admit it. Do not invent file paths or API responses.

## 5. MCP Usage
-   **Git Operations:**
    -   ALWAYS use `mcp_git_*` tools (e.g., `mcp_git_git_status`, `mcp_git_git_add`, `mcp_git_git_commit`) for version control.
    -   **Check Status First:** Before attempting to commit, ALWAYS run `mcp_git_git_status` (or `git status` via terminal if unavailable) to verify there are changes to commit.
    -   **Commit Messages:** Use semantic commit messages referencing the Issue ID (e.g., `feat: add market button #6`).
    -   Avoid `mcp_gitkraken_*` for basic git operations unless `mcp_git_*` fails.
-   **GitHub Operations:**
    -   Use `mcp_github_*` tools to manage issues.
-   **Godot Operations:**
    -   Use `mcp_godot_*` tools (if available) or file operations to manage Godot assets.
