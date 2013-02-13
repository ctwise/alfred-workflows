-- Looks for a sequence of bytes that identifies the path separator in the
-- file-bookmark's data. We can use this to find the start of the file path.
-- Returns the start posiiton of the path separator.
on findPathSeparator(theData, theFile)
    -- list of character IDs that make up the path separator
    set pathSeparator to {0, 0, 0, 1, 1, 0, 0}
    
    try
        read theFile from 0 for 0

        -- keep track of how many bytes we've found in a row matching the
        -- sequence of bytes in pathSeparator
        set bytesFound to 0
        set bytesSearched to 0

        -- Loop through each byte of the data
        repeat (get eof theFile) times
            set theId to id of (read theFile from bytesSearched for 1)
            
            -- Increment bytesFound if we've found another matching byte in
            -- pathSeparator; otherwise, reset the bytesFound counter
            if theId is item (bytesFound + 1) of pathSeparator then
                set bytesFound to bytesFound + 1
            else
                set bytesFound to 0
            end if
            
            -- If we found the full sequence of bytes matching pathSeparator,
            -- we're done!
            if bytesFound is count of pathSeparator then exit repeat
            
            set bytesSearched to bytesSearched + 1
       end repeat
    on error msg
        msg
    end try
    
    -- Return the start position of the path separator
    bytesSearched - count of pathSeparator
end findPathSeparator

-- Read through a file-bookmark's data and return a POSIX path.
on getPathFromData(theData)
    set pathSeparator to {0, 0, 0, 1, 1, 0, 0}
    
    -- Create a temporary storage for the binary data
    set theFile to (open for access POSIX file ("/tmp/get_recent_documents") with write permission)
    set eof theFile to 0
    write contents of theData to theFile
    
    try
        -- Start reading the data at the position of the first path separator
        read theFile from findPathSeparator(theData, theFile) for 0
        
        -- Find the components of the POSIX path and append them to thePath
        set thePath to ""
        repeat
            set idList to id of (read theFile for 8)
            
            -- If the last 7 bytes don't identify a path separator, then we've
            -- read the full file path, and we're done
            if (idList does not end with pathSeparator) then exit repeat
            
            -- The first byte tells us how many bytes to read for the path component
            set theLength to item 1 of idList
            
            -- Read the appropriate number of bytes, and append it to thePath as a string
            set thePath to thePath & ("/" & (read theFile for theLength as «class utf8»))

            -- Skip past any byte padding
            read theFile for (4 - (theLength mod 4)) mod 4
        end repeat
    on error msg
        msg
    end try
    
    close access theFile
    
    -- Return the full POSIX path
    thePath
end getPathFromData

tell application "System Events"
    tell property list file "~/Library/Preferences/com.apple.recentitems.plist"
        set dataItems to property list item "RecentDocuments"'s property list item "CustomListItems"'s property list items's property list item "Bookmark"'s value
        set itemNames to property list item "RecentDocuments"'s property list item "CustomListItems"'s property list items's property list item "Name"'s value
    end tell
end tell

-- Write the name and file path to theOutput, each on a separate line.
set theOutput to ""
set itemNum to 1
repeat (count of dataItems) times
    set theOutput to theOutput & item itemNum of itemNames & "\n" & getPathFromData(item itemNum of dataItems) & "\n"
    set itemNum to itemNum + 1
end repeat

theOutput