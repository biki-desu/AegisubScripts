AegisubScripts
==============

Aegisub Automation Scripts written by biki

## ./
### Prepend stuff to selected lines
File: prepend.lua
Version: 2.1
Info: This script adds text from the textbox to selected lines. Can add stuff before or after text
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
2.1: Add append functionality & clean up code
2.0.1: Write some documentation & add "multiple of selected lines" functionality
2.0: Initial full rewrite of add-stuff-to-selected-lines.lua@v1.1

## ./.old/
Old/deprecated versions of my scripts
### Add stuff to selected lines
File: add-stuff-to-selected-lines.lua
Version: 1.1 (Superseded by "Prepend stuff to selected lines")
Info: This script adds text from textbox to all selected lines
