-- I don't know AppleScript - copy pasted some code from https://getsatisfaction.com/alfredapp/topics/searching_through_nested_menu_items

on run argv
	tell application "System Events"
		return item 1 of (every process whose frontmost is true)
	end tell
end run
