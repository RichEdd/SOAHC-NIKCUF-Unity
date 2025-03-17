# ClickUp Container Tasks Reference

This file contains the IDs of the container tasks created in ClickUp for organizing your Unity project commits.

## Container Tasks

All container tasks are marked with the **CONTAINERS** status in ClickUp to distinguish them from regular work tasks.

| Category | Task ID | Description | Example Commit |
|----------|---------|-------------|---------------|
| Bug Fixes | #86a7a1ddr | Container for all bug fix commits. Use this task ID when committing code that fixes bugs, resolves issues, or addresses unexpected behavior. | `git commit -m "Fix player collision detection #86a7a1ddr"` |
| Features | #86a7a1ddt | Container for all new feature implementations. Use this task ID when committing code that adds new functionality, systems, or capabilities to the game. | `git commit -m "Add new weapon system #86a7a1ddt"` |
| Refactors | #86a7a1ddv | Container for code refactoring and improvements. Use this task ID when committing code that improves structure, readability, or maintainability without changing functionality. | `git commit -m "Refactor enemy AI for better maintainability #86a7a1ddv"` |
| Performance Optimizations | #86a7a1ddw | Container for performance-related changes. Use this task ID when committing code that improves game performance, reduces memory usage, or optimizes resource loading. | `git commit -m "Optimize rendering pipeline for better FPS #86a7a1ddw"` |
| UI/UX Improvements | #86a7a1ddy | Container for user interface and experience changes. Use this task ID when committing code that enhances the game's UI, menus, HUD, or overall user experience. | `git commit -m "Update main menu layout and animations #86a7a1ddy"` |
| Art & Assets | #86a7a1ddz | Container for art-related commits. Use this task ID when committing new or updated art assets, models, textures, or visual effects. | `git commit -m "Add new character models and textures #86a7a1ddz"` |
| Audio | #86a7a1de0 | Container for audio-related commits. Use this task ID when committing new or updated sound effects, music, or audio systems. | `git commit -m "Add new background music for forest level #86a7a1de0"` |
| Documentation | #86a7a1de1 | Container for documentation updates. Use this task ID when committing changes to documentation, comments, or README files. | `git commit -m "Update installation instructions in README #86a7a1de1"` |

## Status Workflow

Your ClickUp workspace has the following statuses for task management:

- **CONTAINERS**: Used for container tasks that categorize commits
- **Backlog**: For actual tasks that need to be worked on in the future
- **In Progress**: For tasks currently being worked on
- **Complete**: For tasks that have been completed

## How to Use

1. When making a commit, include the appropriate task ID in your commit message.
2. The ClickUp-GitHub integration will automatically link your commit to the corresponding task.
3. You can view all commits related to a specific category by opening the task in ClickUp.

## Testing the Integration

You can test the integration by running the following script:

```powershell
.\test-clickup-integration.ps1
```

This script will create a test file, commit it with a task ID, and push it to your repository.

## ClickUp CLI

The ClickUp CLI is installed and available through the `clickup.bat` shortcut in this directory. You can use it to create, update, and manage tasks from the command line.

Example usage:
```
.\clickup.bat create -h
``` 