# This program takes an input string from user and print it to the console
# Procedure:
# 1. Create a buffer ("inputString" in this case) to store the input string
# 2. Load the address of the buffer to register $a0
# 3. Load the length of the buffer to register $a1
# 4. Load register $v0 with 8
# 5. Issue "syscall"
.data			# What follows will be data
#inputString1: .space 64	 set aside 64 bytes to store the input string
#inputString2: .space 64
firstNumPrompt: .asciiz "Enter first number: "
secondNumPrompt: .asciiz "Enter second number: "
operationPrompt: .asciiz "Operation: "
display: .asciiz "Ans: "
.text			# What follows will be actual code
main: 
	# Display firstNumPrompt
	la	$a0, firstNumPrompt	# display the prompt to begin
	li	$v0, 4	# system call code to print a string to console
	syscall
	
	# get the first number from console
	li	$v0, 5
	syscall
	move	$t8, $v0
	
	# Display secondNumPrompt
	la	$a0, secondNumPrompt	# display the prompt to begin
	li	$v0, 4	# system call code to print a string to console
	syscall
	
	# get the second number from console
	li	$v0, 5
	syscall
	move	$t9, $v0	
	
	# Display operationPrompt
	la	$a0, operationPrompt	# display the prompt to begin
	li	$v0, 4	# system call code to print a string to console
	syscall	
			
	# get the operation from console
	li	$v0, 5
	syscall
	move	$t0, $v0	
	# load registers with values from 1 to 4 for comparison with input for operation
	la $t1, 1 # addition
	la $t2, 2 # subtraction
	la $t3, 3 # multiplication
	la $t4, 4 # division
	beq $t0, $t1, addition #check if the user wants to add
	beq $t0, $t2, subtratction #check if the user wants to subtract
	beq $t0, $t3, multiplication #check if the user wants to multiply
	beq $t0, $t4, division #check if the user wants to divide
		
addition:
	add $t5, $t8, $t9 #add inputs one and two
	
	

subtraction:

multiplication:

division:
	
			
	
printResult:					
	# Print "You typed: " to console
	la	$a0, display	
	li	$v0, 4
	syscall
	# Print the entered string to console
	la	$a0, inputString
	li	$v0, 4
	syscall
	
	
