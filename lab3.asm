# This program evaluates simple algebraic expressions
# See report for procedure
# 
.data			# What follows will be data
inputString: .space 64	# set aside 64 bytes to store the input string
spacelessString: .space 64 # set aside 64 bytes that we will copy the input string (minus any spaces) into 
prompt: .asciiz "Enter an algebraic expression: "
answer: .asciiz "Answer: "
invalid: .asciiz "Invalid Input"
.text			# What follows will be actual code
main: 
	# Display prompt
	la	$a0, prompt	# display the prompt to begin
	li	$v0, 4	# system call code to print a string to console
	syscall
	# get the string from console
	la	$a0, inputString	# load $a0 with the address of inputString; procedure: $a0 = buffer, $a1 = length of buffer
	la	$a1, inputString # maximum number of character
	la	$a2, spacelessString    # load $a2 with the address of spacelessString; procedure: $a2 = buffer, $a3 = length of buffer
	la	$a3, spacelessString
	li	$v0, 8	# The system call code to read a string input
	syscall
	jal removeSpaces # Copy the contents of inputString into spacelessString, removing all spaces
	la	$a0, ($a2) # store the contents of $a2 (which is spacelessString) in $a0 
	li 	$v0, 4
	syscall
	jal checkForInvalidSymbols
	j main
	
removeSpaces:
#Copy the input string without copying the spaces
	addi $sp, $sp, -8    # Make space on the stack 
	sw $s1, 4($sp) # Save $s0 and $s1
	sw $s0, 0($sp)
	#Set $s0 and $s1 to zero so they can be used as counters
	add $s0, $zero, $zero # i = 0
	add $s1, $zero, $zero # j = 0
    L1: add $t1, $s0, $a0 # Store the address of inputString[i] in $t1
    	lbu $t2, 0($t1) # Store inputString[i] in $t2
    	beq $t2, 32, L2 # if $t2 is equal to 32, then inputString[i] == ' ' and we skip copying this char
	add $t3, $s1 , $a2 # store the address of spacelessString[j] in $t3
	sb $t2, 0($t3) # save inputString[i] into the space for spacelessString[j]
	addi $s1, $s1, 1 # increment j
    L2: beq $t2, $zero, L3 # if $t2 is equal to $zero, then inputString[i] == '\0' and we are done copying
    	addi $s0, $s0, 1 # increment i
    	j L1 
    L3: lw $s0, 0($sp) #restore $s0 and s1
    	lw $s1, 4($sp)
    	addi $sp, $sp, 8 #deallocate the space on the stack
    	jr $ra #return

checkForInvalidSymbols:
#Check the spaceless expression string for any invalid symbols
#Valid symbols are: parentheses, digits from 0 to 9, the operators +,-,*,and/, and the letters from a to z (either uppercase or lowercase)
#This process goes character by character, checking each char's numerical ascii value. If that value does not correspond to one of the above, the process is exited and an error is printed to I/O
#This process makes five checks, based on ranges of ascii values. 
	addi $sp, $sp, -4    # Make space on the stack 
	sw $s0, 0($sp) 	 # Save $s0 
	#Set $s0  to zero so it can be used as a counter
	add $s0, $zero, $zero # i = 0
    L1A: add $t1, $s0, $a0 # Store the address of spacelessString[i] in $t1
    	lbu $t2, 0($t1) # Store the data at the spacelessString[i] in $t2
    	#add $t3, $zero, 40 # Lower bound of the range of ascii values from '(' to '+'
    	#add $t4, $zero, 43 # Upper bound of the range from ( to +
    	beq $t2, 10, exit # if spacelessString[i] is a newline, leave this process
    	blt $t2, 40, failure # fail if spacelessString[i] < the lower bound of the range from ( to +
    	blt $t2, 44, next # go to next char if spacelessString[i] is < the first symbol beyond the range ( to +
    	beq $t2, 45, next # go to next char if spacelessString[i] is equal to 45 (which means it is '-')
    	blt $t2, 47, failure # fail if spacelessString[i] < the lower bound of the range from / to 9
    	blt $t2, 58, next # go to next char if spacelessString[i] is < the first symbol beyond the range / to 9
    	blt $t2, 65, failure # fail if spacelessString[i] < the lower bound of the range from A to Z
    	blt $t2, 91, next # go to next char if spacelessString[i] is < the first symbol beyond the range A to Z
    	blt $t2, 97, failure # fail if spacelessString[i] < the lower bound of the range from a to z
    	blt $t2, 123, next # go to next char if spacelessString[i] is < the first symbol beyond the range a to z
    	j failure # spacelessString[i] is above the range of valid symbols, so go to failure
  next: addi $s0, $s0, 1 # increment j
    	j L1A
 failure: la $a0, invalid # display the invalid input message
	  li $v0, 4 # system call code to print a string to console
	  syscall
 exit: lw $s0, 0($sp) #restore $s0 and s1
    	addi $sp, $sp, 4 #deallocate the space on the stack
    	jr $ra #return

