# Documentation Agents Instructions

## Context
This directory contains all design documents, GDDs, and architectural diagrams.

## Guidelines
1.  **Single Source of Truth:** The `GDD/` folder contains the current approved design.
2.  **Structure:**
    -   `GDD/`: Main Game Design Documents.
    -   `mechanics/`: Specific mechanic details.
    -   `algorithms/`: Pseudo-code and logic definitions.
    -   `diagrams/`: Mermaid or image diagrams.
3.  **Archiving:** When a design document is superseded, move it to `.archive/` instead of deleting it.
4.  **Format:** Use Markdown for all text documentation. Use Mermaid for diagrams.

## Workflow
-   **No Loose Files:** Do not create files directly in `docs/`. Use subdirectories.
-   Before implementing a complex feature in `/project`, ensure it is defined here.
-   Update the GDD if implementation details change significantly during development.

