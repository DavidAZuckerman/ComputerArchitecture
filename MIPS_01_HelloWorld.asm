# This program prints "Hello World" (already stored in memory) to the I/O window
# Procedure to print a string to I/O window:
# 1. Load the address of the string to register $a0
# 2. Load register $v0 with 4
# 3. Issue "syscall"
.data	# What follows will be data
display1: .asciiz "Hello World!\n"	# the string "Hello World" is stored in the buffer named "display"
.text	# What follows will be actual code
main: 				
	la	$a0, display1	# Load the address of "display1" to $a0
	li	$v0, 4		# Load register $v0 with 4
	syscall			# Issue "syscall" - that brings the string onto the screen
	
