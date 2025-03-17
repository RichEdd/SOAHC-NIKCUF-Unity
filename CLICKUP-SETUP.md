# ClickUp Setup for SOAHC-NIKCUF-Unity Project

This document provides instructions for setting up ClickUp integration with your Unity project on a new development machine.

## Quick Start

1. Make sure you have [Node.js](https://nodejs.org/) installed
2. Run the setup script from the root project folder:
   ```
   .\setup-clickup-environment.ps1
   ```
3. Follow the on-screen prompts to complete the setup

## Manual Setup (If Script Fails)

If the automated script doesn't work for any reason, follow these manual steps:

1. Install ClickUp CLI globally:
   ```
   npm install -g clickup-cli
   ```

2. Create a configuration file named `clickup-config.json` with the following content:
   ```json
   {
     "token": "pk_132021316_3Y2JWD1NM4GGY3RV63JJ01PFUA9PQCQJ",
     "team": "9013790997"
   }
   ```

3. Test the ClickUp integration:
   ```
   .\test-clickup-integration.ps1
   ```

## Container Tasks for Commit References

When making commits, reference the appropriate container task ID in your commit message:

| Category | Task ID | Example Commit Message |
|----------|---------|------------------------|
| Bug Fixes | #86a7a1ddr | `Fix collision detection issue #86a7a1ddr` |
| Features | #86a7a1ddt | `Add power-up system #86a7a1ddt` |
| Refactors | #86a7a1ddv | `Refactor player movement code #86a7a1ddv` |
| Performance Optimizations | #86a7a1ddw | `Optimize rendering pipeline #86a7a1ddw` |
| UI/UX Improvements | #86a7a1ddy | `Improve menu navigation #86a7a1ddy` |
| Art & Assets | #86a7a1ddz | `Add character sprites #86a7a1ddz` |
| Audio | #86a7a1de0 | `Add background music #86a7a1de0` |
| Documentation | #86a7a1de1 | `Update code comments #86a7a1de1` |

## Initial Tasks

These are the initial tasks to work on:

1. Set up Unity project with appropriate settings (#86a7a1dwk)
2. Create .gitignore for Unity (#86a7a1dwm)
3. Create initial scene structure (#86a7a1dwn)
4. Implement basic player controller (#86a7a1dwp)
5. Set up camera system (#86a7a1dwr)
6. Create main menu UI (#86a7a1dwt)
7. Implement in-game HUD (#86a7a1dwu)

## Troubleshooting

If you encounter issues with the ClickUp integration:

1. Verify your Node.js installation: `node --version`
2. Check if ClickUp CLI is installed: `npm list -g clickup-cli`
3. Ensure your API token is correct in the configuration file
4. Try using the `clickup.bat` shortcut created by the setup script
5. Restart your terminal or PowerShell session

## Additional Resources

- [ClickUp API Documentation](https://clickup.com/api)
- For more details, refer to:
  - `notes.txt` - Project overview and status
  - `clickup-container-tasks-reference.md` - Detailed container task information
  - `test-clickup-integration.ps1` - Script to test ClickUp integration 