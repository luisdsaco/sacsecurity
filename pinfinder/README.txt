Pinfinder
---------

This application searches for a 4 digit pin in a file.

Usage:

	pinfinder [-pin PIN] [file]
	
Without arguments it takes data from stdin that can be introduced from the keyboard.

You can use unix pipes like:

	ls -lisa | pinfinder -p
	
This turns pinfinder into a powerful analysis tool when used in shell scripts.
Default PIN is 1234

Example:

	pinfinder -pin 0000 *.pin
	
This would search for the string "0000" in all files in the current directory with the
extension .pin

It only works with numeric pins of four digits.
