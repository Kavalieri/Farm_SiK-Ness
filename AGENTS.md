# Root Agents Instructions

This repository follows a strict **Issue-Driven Development** workflow.

## Responsibilities
-   **Orchestration:** Manage the high-level workflow between `docs/` and `project/`.
-   **Git Management:** Ensure all changes are committed with semantic messages referencing active Issues.
-   **Issue Tracking:** Create and update GitHub Issues for every task.

## Directory Structure
-   `/project`: The Godot 4.5.1 game project. **ALL** game assets and code go here.
-   `/docs`: Documentation (GDD, Architecture, Design). **ALL** design docs go here.
-   `/.github`: Workflows and Copilot instructions.

## Strict Rules
1.  **No Root Pollution:** Do NOT create files in the root directory (except strictly necessary config files).
2.  **Context Awareness:** Before answering, check which directory you are working in.
3.  **Issue Linking:** Every commit MUST reference an Issue ID.

## Development Workflow

### Running the Game
To run the game and see the console output (logs, errors, print statements):
1.  **VS Code Task:** Run the task `Run Game` (Ctrl+Shift+B or Terminal -> Run Task...).
2.  **Terminal:** Execute `godot --path project/ --verbose`.

### Refreshing Assets (Headless)
To force a re-import of assets (e.g., after creating files externally) without opening the GUI:
1.  **VS Code Task:** Run the task `Refresh Assets`.
2.  **Terminal:** Execute `godot --path project/ --headless --import`.

### Opening the Editor
To open the project in the Godot Editor:
1.  **VS Code Task:** Run the task `Open Godot Editor`.
2.  **Terminal:** Execute `godot --path project/ -e`.

