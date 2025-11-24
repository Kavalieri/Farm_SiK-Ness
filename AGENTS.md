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

