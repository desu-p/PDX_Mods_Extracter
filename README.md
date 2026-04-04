PDX Mods Extractor is a lightweight PowerShell/Bash automation tool designed for Paradox Interactive grand strategy fans who prefer manually managing their mods or downloading them from sources like Paradox Mods, direct archives, etc.

Tired of manually extracting .zip files, renaming folders, and fixing the path="mod/..." line in every single .mod descriptor? This script does it all for you in seconds.

🚀 Key Features:
Auto-Extraction: Automatically finds and extracts all mod archives in the directory.

Smart Renaming: Uses the actual mod name from the internal descriptor.mod to name your folders (no more pdx_12345 gibberish).

Descriptor Fixing: Automatically generates and updates the external .mod file with the correct path, making the mod instantly visible in the Paradox Launcher or Irony Mod Manager.

Clean Workflow: Moves processed archives to a backup folder to keep your workspace tidy.

⚠️ Compatibility Note:
Currently, the script is fully optimized for games using the modern Paradox mod structure (like Crusader Kings III).

If you attempt to use this with older titles or encounter any pathing issues/bugs, please report me on my Discord (@desup_18779) or Issues tab on this repo. I am looking to expand support based on your feedback!

🛠️ How to use:

1. Place the script in your "mod" folder (or where you keep your downloaded archives).

2. Run PDX_Mods_Exctractor.ps1 or it's .sh version with PowerShell/Bash.

3. Enjoy your perfectly organized mod list!
