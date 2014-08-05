AegisubScripts
==============

Aegisub Automation Scripts written by biki

## ./


### Copy tags
File: copytags.lua

Version: 1.3.3

Info: Strips out text and comments from selected lines and puts them in a textbox (doesn't modify original lines). Can also copy tags directly to clipboard (for hotkey binding (no gui)).

To-do: 
1. Get re.find to work
2. Kill wrapper functions

Changelog: 
1.3.3: Actually do error handling & gettext
1.3.2: Fix line endings bug
1.3.1: Fix syntax error
1.3: Added clipboard functionality
1.2: Bugfix: strip comments
1.1: Rewrite & initial commit
1.0: Initial version (deprecated)

### Paste tags
File: pastetags.lua

Version: 1.1.4

Info: Pastes tags from clipboard (prepends them to the line), same (basic) core functionality as "Prepend stuff to selected lines" but with no gui and less features, designed for hotkey binding.

To-do:
1. Get re.find to work
2. Kill wrapper functions

Changelog: 
1.1.4: Make error message more accurate
1.1.3: Unbreak the script
1.1.2: More error handling & clean up helper function, fix error in an edge case
1.1.1: Actually do error handling & gettext
1.1: Make the script actually work & fix line endings
1.0: Initial commit (broken)

### Prepend stuff to selected lines
File: prepend.lua

Version: 2.2.1

Info:
This script adds text from the textbox to selected lines. Can add stuff before or after text
If one line is present in txtbox, it adds it to all selected lines.
If there are "d" lines in the txtbox and "n" lines are selected then if and only if "d" is a divisor of "n" the script then adds an ordered multiple of the lines from the txtbox to the selected lines.
If the same amount of lines is in the txtbox as the amount of selected lines then it adds each new line from the txtbox to each new line in selection.
If txtbox lines > selection OR "d" not a multiple of "n" then spit error.

To-do:
1. Clean up helper functions

Changelog:
2.2.1: Fix Issue#3
2.2: Add more functionality and clean up helper functions
2.1.4: Make error message more accurate
2.1.3: More error handling
2.1.2: Actually do error handling & gettext
2.1.1: Add support for Winblows and clean up string substitutions
2.1: Add append functionality & clean up code
2.0.1: Write some documentation & add "multiple of selected lines" functionality
2.0: Initial full rewrite of add-stuff-to-selected-lines.lua@v1.1 & initial commit



## ./.old/
Old/deprecated versions of my scripts


### Add stuff to selected lines
File: add-stuff-to-selected-lines.lua

Version: 1.1 (Superseded by "Prepend stuff to selected lines")

Info: This script adds text from textbox to all selected lines

### Deduplicate
File: deduplicate.ass

Version: 1.0 (Broken and needs fixing)

Info: It's meant to concatenate identical lines when importing from SRT which had one ASS line per frame throughout. It's not known if this works

### Template
File: 
Version: 
Info: 
To-do: 
Changelog: 
