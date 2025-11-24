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
-   **Language:** GDScript (Static typing preferred: `var x: int = 0`).
-   **Architecture:**
    -   **Managers (Singletons):** For global state (GameManager, SaveManager).
    -   **Resources (.tres):** For data definitions (BuildingData).
    -   **Composition:** Prefer small, reusable components over deep inheritance.
-   **Style:** Snake_case for variables/functions, PascalCase for Classes/Nodes.

## 4. MCP Usage
-   Use `mcp_github_*` tools to manage issues and PRs.
-   Use `mcp_godot_*` tools (if available) or file operations to manage Godot assets.
