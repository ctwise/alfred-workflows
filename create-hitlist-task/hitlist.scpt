on run argv
	set theTask to item 1 of argv
	tell application "The Hit List"
		# Get the list of all groups from The Hit List
		# and parse the task text looking for a group name
		
		set theFoundGroups to my accumulate_folders()
		set theParsedTask to my parse_task(theTask)

		# The result of parsing the task text is:
		# item 1 is the task text w/o the group
		# item 2 is the group name or null if a group wasn't specified
		# item 3 is the priority
		# item 4 is the jira defect key
		# item 5 is the description
		
		if (item 2 of theParsedTask is equal to null) then
			my create_task(inbox, item 1 of theParsedTask, item 3 of theParsedTask, item 4 of theParsedTask, item 5 of theParsedTask)
		else
			set shortTaskText to item 1 of theParsedTask
			
			# Look for the group name specified in the task
			# The search ignores case.  If there are multiple groups with the
			# same name, only the first one will be used
			
			set theGroup to my find_group(theFoundGroups, item 2 of theParsedTask)
			
			# If we didn't find the group (it's null), use the inbox
			
			if theGroup is equal to null then
				my create_task(inbox, shortTaskText, item 3 of theParsedTask, item 4 of theParsedTask, item 5 of theParsedTask)
			else
				my create_task(theGroup, shortTaskText, item 3 of theParsedTask, item 4 of theParsedTask, item 5 of theParsedTask)
			end if
		end if
	end tell
end run

on split(theText, splitText)
	set tid to AppleScript's text item delimiters
	set AppleScript's text item delimiters to splitText
	set theTextItems to text items of theText
	set AppleScript's text item delimiters to tid
	return theTextItems
end split

on join(theList, joinText)
	set result to ""
	repeat with theToken in theList
		if length of result = 0 then
			set result to theToken
		else
			set result to result & joinText & theToken
		end if
	end repeat
	return result
end join

on trim_line(this_text, trim_chars, trim_indicator)
	-- 0 = beginning, 1 = end, 2 = both
	set x to the length of the trim_chars
	-- TRIM BEGINNING
	if the trim_indicator is in {0, 2} then
		repeat while this_text begins with the trim_chars
			try
				set this_text to characters (x + 1) thru -1 of this_text as string
			on error
				-- the text contains nothing but the trim characters
				return ""
			end try
		end repeat
	end if
	-- TRIM ENDING
	if the trim_indicator is in {1, 2} then
		repeat while this_text ends with the trim_chars
			try
				set this_text to characters 1 thru -(x + 1) of this_text as string
			on error
				-- the text contains nothing but the trim characters
				return ""
			end try
		end repeat
	end if
	return this_text
end trim_line

on trim(theText)
	return trim_line(theText, " ", 2)
end trim

# Create a task in a group (folder)
# Set the start date to today
on create_task(theGroup, theTaskText, thePriority, defectNumber, theDescription)
	tell application "The Hit List"
		set theNotes to ""
		if defectNumber is not null then
			set theNotes to ("http://jira.hdlabinc.com/browse/" & defectNumber) as rich text
		end if
		if theDescription is not null then
			log theNotes
			log theDescription
			-- set theNotes to add_line(theNotes as rich text, theDescription as rich text)
			if theNotes is not null and length of theNotes > 0 then
				set theNotes to (theNotes & return & theDescription) as rich text
			else
				set theNotes to theDescription
			end if
		end if
		set theDueDate to current date
		# set theDueDate to (current date) + 86400
		if length of theNotes > 0 then
			tell theGroup to make new task with properties {timing task:theTaskText, start date:current date, notes:theNotes, due date:theDueDate, priority:thePriority}
		else
			tell theGroup to make new task with properties {timing task:theTaskText, start date:current date, due date:theDueDate, priority:thePriority}
		end if
	end tell
end create_task

# Get the list of all groups
# returns the list
on accumulate_folders()
	tell application "The Hit List"
		set theFolders to folders group
		set theFoundGroups to {}
		repeat with theFolder in theFolders
			my accumulate_groups(groups of theFolder, theFoundGroups)
		end repeat
	end tell
	
	return theFoundGroups
end accumulate_folders

# Recursively searches groups, adding new groups to
# theFoundGroups
on accumulate_groups(theGroups, theFoundGroups)
	tell application "The Hit List"
		repeat with theGroup in theGroups
			# We only want lists, not groups or folders
			set objClass to class of theGroup as rich text
			if objClass = "list" then
				set end of theFoundGroups to theGroup
			end if
			try
				my accumulate_groups(groups of theGroup, theFoundGroups)
			end try
		end repeat
	end tell
end accumulate_groups

# Try to find a named group in a list of groups
# Groups are matched on leading characters, e.g., "des" will match "design"
# If the text matches multiple groups then no match is assumed
# Exact matches are always preferred
# returns the group item if found or null if not found
on find_group(theGroups, theName)
	set theFoundGroups to {}
	repeat with theGroup in theGroups
		if name of theGroup is equal to theName then
			return theGroup
		end if
		if name of theGroup starts with theName then
			set the end of theFoundGroups to theGroup
		end if
	end repeat
	if (count of theFoundGroups) is 1 then
		return first item of theFoundGroups
	else
		return null
	end if
end find_group

# Parse the task text looking for a group name
# returns a two-part list, item 1 is the task text w/ the group name
# item 2 is the group name or null if no group was specified
# item 3 is the priority
# item 4 is the on-time defect number or null
# item 5 is the description or null
on parse_task(theTask)
	set theSubject to null
	set theDefect to null
	set theDescription to null
	set theGroup to null
	set thePriority to 9
	
	set tokens to split(theTask, "%")
	if (count of tokens) > 1 then
		set theTask to trim(join(items 1 thru -2 of tokens, "%"))
		set theGroup to last item of tokens
		
		set tokens to split(theGroup, "!")
		if (count of tokens) > 1 then
			set theGroup to trim(join(items 1 thru -2 of tokens, "!"))
			set thePriority to trim(last item of tokens)
		end if
	end if
	
	set tokens to split(theTask, "!")
	if (count of tokens) > 1 then
		set theTask to trim(join(items 1 thru -2 of tokens, "!"))
		set thePriority to trim(last item of tokens)
	end if
	
	set tokens to split(theTask, "|")
	if (count of tokens) > 1 then
		set theDescription to trim(join(items 2 thru -1 of tokens, return))
		set theTask to trim(item 1 of tokens)
	end if
	
	set theSubject to theTask
	
	if theSubject starts with "#" then
		set tokens to split(theTask, "#")
		if (count of tokens) > 1 then
			set tokens to split(item 2 of tokens, " ")
			set theDefect to uppercase(trim(item 1 of tokens))
			set theSubject to trim(join(items 2 thru -1 of tokens, " "))
		end if
	end if
	
	return {theSubject, theGroup, thePriority, theDefect, theDescription}
end parse_task

on uppercase(s)
	set uc to "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	set lc to "abcdefghijklmnopqrstuvwxyz"
	repeat with i from 1 to 26
		set AppleScript's text item delimiters to character i of lc
		set s to text items of s
		set AppleScript's text item delimiters to character i of uc
		set s to s as text
	end repeat
	set AppleScript's text item delimiters to ""
	return s
end uppercase

on lowercase(s)
	set uc to "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	set lc to "abcdefghijklmnopqrstuvwxyz"
	repeat with i from 1 to 26
		set AppleScript's text item delimiters to character i of uc
		set s to text items of s
		set AppleScript's text item delimiters to character i of lc
		set s to s as text
	end repeat
	set AppleScript's text item delimiters to ""
	return s
end lowercase