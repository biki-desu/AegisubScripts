AegisubScripts
--------------

Aegisub Automation Scripts written by biki, feel free to visit #biki on rizon!

## ./
--------------


### Copy/paste tags to/from clipboard
**File:** copypastetags.lua

**Version:** 2.0.1

**Info:** This script has no gui, it's designed for hotkey binding. This script can:
* Strip out text and comments from selected lines and put them into the clipboard.
* Paste tags from clipboard (prepends them to the line), same (basic) core functionality as "Prepend stuff to selected lines" but with no gui and less features.

##### Changelog:
* 2.0.1: Close [Issue#9](https://github.com/biki-desu/AegisubScripts/issues/9)
* 2.0: Initial merge of copytags.lua and pastetags.lua


### Fix karaoke keyframes
**File:** fixkarakeyframes.lua

**Version:** 1.0.1

##### Info:
* This script can shift karaoke lines by frames while maintaining audio sync.
* This script can also autodetect keyframes and auto-snap start & end times to keyframes (**WARNING**: this required an xvid keyframe file to be loaded into aegisub), this can be done either on a per-frame basis or a mean average shifting all the frames.

##### To-do:
* Clean up helper functions
* Add a half-decent keyframe bias estimator for consistent auto frame shift
* Make a decent average function for consistent auto frame shift
* Make per-frame auto frame shift actually work
* Allow for a time shift instead of a frame-only shift
* Actually make the auto frame snapping function work

##### Changelog:
* 1.0.1: Close [Issue#9](https://github.com/biki-desu/AegisubScripts/issues/9)
* 1.0: Initial commit


### Prepend stuff to selected lines
**File:** prepend.lua

**Version:** 2.2.7

##### Info:
* This script can prepend & append text & tags from the textbox to selected lines.
* If the same amount of lines is present in the txtbox as the amount of selected lines then the script prepends/appends each new line from the txtbox to each new line in selection.
* The script can do a variety of different things when there's a different amount of selected lines compared to selected lines:
  * If one line is present in the txtbox, it adds it to all selected lines.
  * If there are "d" lines in the txtbox and "n" lines are selected then if and only if "d" is a divisor of "n" then the script appends/prepends a multiple of the lines from the txtbox to the selected lines.
* The feature above is dependent on the mode in which the script is in. There are 2 modes available, they set the order in which the repetition is performed:
  * The (abcabc) mode. Meaning that what is in the txtbox is repeated n/d times (including new lines, so if you leave a blank line in the middle of the txtbox, the script won't touch the line)
  * The (aabbcc) mode. Meaning that that the first line is repeated n/d times, then the 2nd line is repeated n/d times and so on...
* **WARNING**: New lines are significant, so if you leave a blank new line at the end in the textbox the script may not perform as you'd expect.

##### To-do:
* Clean up helper functions
* Add miscellaneous functionality, mainly [Issue#5](https://github.com/biki-desu/AegisubScripts/issues/5)

##### Changelog:
* 2.2.7: Rewrite some core functionality
* 2.2.6: Close [Issue#8](https://github.com/biki-desu/AegisubScripts/issues/8)
* 2.2.5: Close [Issue#9](https://github.com/biki-desu/AegisubScripts/issues/9)
* 2.2.4: Close [Issue#6](https://github.com/biki-desu/AegisubScripts/issues/6)
* 2.2.3: Close [Issue#4](https://github.com/biki-desu/AegisubScripts/issues/4)
* 2.2.2: Do progress reporting, actually stop when user presses cancel, add a clear button and some local config
* 2.2.1: Close [Issue#3](https://github.com/biki-desu/AegisubScripts/issues/3)
* 2.2: Add more functionality and clean up helper functions
* 2.1.4: Make error message more accurate
* 2.1.3: More error handling
* 2.1.2: Actually do error handling & gettext
* 2.1.1: Add support for Winblows and clean up string substitutions
* 2.1: Add append functionality & clean up code
* 2.0.1: Write some documentation & add "multiple of selected lines" functionality
* 2.0: Initial full rewrite of add-stuff-to-selected-lines.lua@v1.1 & initial commit


## ./.old/
--------------
Old/deprecated versions of my scripts


### Add stuff to selected lines
**File:** add-stuff-to-selected-lines.lua

**Version:** 1.1 (**Superseded** by prepend.lua)

**Info:** This script adds text from textbox to all selected lines


### Copy tags
**File:** copytags.lua

**Version:** 1.3.3 (**Superseded** by copypastetags.lua)

**Info:** Strips out text and comments from selected lines and puts them in a textbox (doesn't modify original lines). Can also copy tags directly to clipboard (for hotkey binding (no gui)).

##### Changelog: 
* 1.3.3: Actually do error handling & gettext
* 1.3.2: Fix line endings bug
* 1.3.1: Fix syntax error
* 1.3: Added clipboard functionality
* 1.2: Bugfix: strip comments
* 1.1: Rewrite & initial commit
* 1.0: Initial version (deprecated)


### Deduplicate
**File:** deduplicate.ass

**Version:** 1.0 (**Broken** and needs fixing)

**Info:** It's meant to concatenate identical lines when importing from SRT which had one ASS line per frame throughout. It's not known if this works


### Paste tags
**File:** pastetags.lua

**Version:** 1.1.4 (**Superseded** by copypastetags.lua)

**Info:** Pastes tags from clipboard (prepends them to the line), same (basic) core functionality as "Prepend stuff to selected lines" but with no gui and less features, designed for hotkey binding.

##### Changelog: 
* 1.1.4: Make error message more accurate
* 1.1.3: Unbreak the script
* 1.1.2: More error handling & clean up helper function, fix error in an edge case
* 1.1.1: Actually do error handling & gettext
* 1.1: Make the script actually work & fix line endings
* 1.0: Initial commit (broken)

