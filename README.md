Alfred 2 Workflows
==================

A collection of Alfred 2 workflows. Some of these workflows are rewrites or extensions of other people's work. I've tried to provide proper attribution where applicable.

character-palette
-----------------

Very simple workflow to display the OS/X Character Palette for selecting obscure characters. Responds to the keyword 'character'.

[Binary download](http://tedwi.se/u/dd)

create-histlist-task
--------------------

Create tasks in the application The Hit List. Task text follows the format:

	<task text> [% <hit list category>] [! <priority>] [| <note text>]

Responds to the keyword 'ta'.

Examples:

	ta Do something				- Create the task 'Do something' in the inbox
	ta Do something else %work	- Create the task 'Do something else' in the Work folder
	ta More work !1				- Create the task 'More work' in the inbox with priority 1
	ta Stuff | Notes about it	- Create the task 'Stuff' in the inbox with 'Notes about it' as a note
	ta list                     - List open tasks

[Binary download](http://tedwi.se/u/ds)

date-and-time
-------------

Very simple workflow to display the current date and time, and, optionally, copy it to the clipboard.

Responds to both keywords 'date' and 'time'.

[Binary download](http://tedwi.se/u/df)

fantastical
-----------

Interfaces with Fantastical to add calendar events.

Responds to keyword 'cal'.

Examples:

	cal Do something at 3pm
	cal Pick up kids at school mar 5 at 6pm

google-autocomplete
-------------------

This is based almost entirely on David Ferguson's workflow. It is rewritten in Ruby but only makes two small changes: it provides the raw search text as an option if there are no Google search results and it times out the Google search result request.

Responds to the keyword 'g'.

[Binary download](http://tedwi.se/u/dg)

kill-process
------------

Search for and kill a process. This lists all the processes that match the text typed. Selecting a process does a 'kill' on it. Holding down the alt modifier key does a 'kill -9' and holding down the cmd modifier does a 'kill -HUP'.

Responds to the keyword 'kill'.

[Binary download](http://tedwi.se/u/cx)

maven-repository
----------------

Searches mvnrepository.com for a given search term.

[Binary download](http://tedwi.se/u/dl)

menu-bar-search
---------------

This is based on the workflow by Jeroen van der Neut. It was his excellent idea and he provided the original Applescript to extract menu items.

This workflow lets you control the front-most application by triggering menu actions. The text entered is used to display matching menu items. Some apps have such large menus that performance is terrible, e.g., Safari.

[Binary download](http://tedwi.se/u/db)

network-info
------------

This is based on David Ferguson's IP Address workflow. The difference is that it provides interface names and mac address.

The workflow responds to the keywords 'ip' and 'mac'. For the 'ip' keyword it lists all interfaces and the local IP addresses. It also displays the external IP address. For the 'mac' keyword it lists all interfaces and the local MAC addresses.

If you select an IP address or MAC address it will be copied to the clipboard. Holding down the cmd modifier key will also paste it in the front-most application.

[Binary download](http://tedwi.se/u/d8)

recent-documents
----------------

Based on the workflows by Clinton Strong and David Ferguson. The difference is it consolidates the OS/X recent documents list and the Alfred recent documentst list.

Triggering the workflow lists all of the recent documents. Selecting one will open it in the default application. Holding down the cmd modifier key will reveal it in Path Finder or Finder (depending on whether Path Finder is installed).

Responds to the keyword 'recent'.

[Binary download](http://tedwi.se/u/d9)

running-apps
------------

Lists all of the running OS/X applications (not processes, what OS/X considers as a running app). Selecting one will activate the application. Holding down the alt modifier key will trigger the built-in 'quit' Alfred command.

Responds to the keyword 'running'.

[Binary download](http://tedwi.se/u/dh)

search-pubmed
-------------

Searches PubMed at ncbi.nlm.nih.gov. Provides two alternates search modes. The first does a keyword search of PubMed articles. Selecting an article displays the article information. The second uses the PubMed search suggestions. Selecting a suggestion performs a PubMed search using that search text.

Responds to the keywords 'pubmed' for article searches and 'pubmed2' for search suggestions.

[Binary download](http://tedwi.se/u/d5)

show-desktop
------------

Simple workflow to hide all applications, showing the desktop.

Responds to the keyword 'show desktop'.

[Binary download](http://tedwi.se/u/dj)

time-machine
------------

Simple Time Machine status and control. Shows the Time Machine completion status and provides support to start and stop Time Machine backups.

Responds to the keywords 'tmac status' to show status, to 'tmac start' to start a Time Machine backup and to 'tmac stop' to stop a Time Machine backup.

[Binary download](http://tedwi.se/u/dc)

top-processes
-------------

Lists the top processes, aka the command-line 'top'. Selecting a process will activate the 'kill-process' workflow to kill the selected process.

[Binary download](http://tedwi.se/u/d6)

urlencode
---------

Encodes and decodes text for use in a URL.

- Keyword 'urlencode' requires text and encodes it for use in a URL, copying it to the clipboard.
- Keyword 'urldecode' requires text and decodes it from a URL, copying it to the clipboard.

[Binary download](http://tedwi.se/u/dk)

vmware-control
--------------

Based on the Parallels Control workflow. Provides a mechanism to control VMWare VMs.

- Keyword 'vm list' lists the known VMs and their current status. Selecting one copies the VM path to the clipboard.
- Keyword 'vm ip' lists the IP addresses of running VMs. Selecing one copies the IP address to the clipboard.
- Keyword 'vm switch' lists the running VMs. Selecting one activates the VM window.
- Keyword 'vm start' lists the stopped VMs. Selecting one starts it.
- Keyword 'vm stop' lists the running VMs. Selecting one stops it.
- Keyword 'vm reset' lists the running VMs. Selecting one resets it.
- Keyword 'vm suspend' lists the running VMs. Selecting one suspends it.
- Keyword 'vm pause' lists the running VMs. Selecting one pauses it.
- Keyword 'vm unpause' lists the running VMS. Selecting one unpauses it.
- Keyword 'vm snapshot' requires a snapshot name and lists the running VMs. Selecting one creates a named snapshot of that VM.
- Keyword 'vm revert' requires a snapshot name and lists the running VMs. Selecting one reverts to a named snapshot of that VM.

[Binary download](http://tedwi.se/u/d4)

volume-control
--------------

Simple workflow that provides volume control. Keyword 'max' sets the volume to max. Keyword 'medium' sets the volume to mid-level. Keyword 'mute' mutes the system volume.

[Binary download](http://tedwi.se/u/di)
