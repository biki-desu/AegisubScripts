AegisubScripts
==============

Aegisub Automation Scripts written by biki

## ./


### Copy tags
File: copytags.lua
Version: 1.3

Info: Strips out text and comments from selected lines and puts them in a textbox (doesn't modify original lines). Can also copy tags directly to clipboard (for hotkey binding (no gui)).

To-do: 
1. Kill wrapper functions
2. Get re.find to work

Changelog: 
1.3: Added clipboard functionality
1.2: Bugfix: strip comments
1.1: Rewrite & initial commit
1.0: Initial version (deprecated)

### Paste tags
File: pastetags.lua
Version: 1.0

Info: Pastes tags from clipboard, same core functionality as "Prepend stuff to selected lines" byt with no gui.

To-do:
1. Kill wrapper functions
2. Get re.find to work

Changelog: 
1.0: Initial commit

### Prepend stuff to selected lines
File: prepend.lua
Version: 2.1.1

Info:
This script adds text from the textbox to selected lines. Can add stuff before or after text
If one line is present in txtbox, it adds it to all selected lines.
If there are "d" lines in the txtbox and "n" lines are selected then if and only if "d" is a divisor of "n" the script then adds an ordered multiple of the lines from the txtbox to the selected lines.
If the same amount of lines is in the txtbox as the amount of selected lines then it adds each new line from the txtbox to each new line in selection.
If txtbox lines > selection OR "d" not a multiple of "n" then spit error.

To-do:
1. Add clipboard functionality
2. Clean up helper functions
3. Fix error and information messages
4. Enable adding after tags in initial lines
5. Make a script to copy tags from lines

Changelog:
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

### Template
File: 
Version: 
Info: 
To-do: 
Changelog: 
