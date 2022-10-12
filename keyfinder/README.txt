Keyfinder
---------

This application searches for the word password in a file.

Usage:

	keyfinder [file]
	
Without arguments it takes data from stdin that can be introduced from the keyboard.

You can use unix pipes like:

	ls -lisa | keyfinder
	
This turns keyfinder into a powerful analysis tool when used in shell scripts.
