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
	jal checkForUnevenParens
	jal checkForInvalidSymbols
	jal checkForInvalidSyntax
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



checkForInvalidSyntax:
#Goes char by char through the expression (once it has had all spaces removed and has passed the check for invalid symbols)
#Compares each char to the one immediately after it, looking for invalid orderings and combinations
	addi $sp, $sp, -8 # Make space on the stack to save $s0 and $s1
	sw $s1, 4($sp) 
	sw $s0, 0($sp)
	#set $s0 to zero and $s1 to 1 so they can be used as iterators
	add $s0, $zero, $zero #i = 0
	addi $s1, $zero, 1 #j = 1 (this register will be used to keep track of the next char, as we will be checking each char against the one after it
L1B:    add $t1, $s0, $a0 # store the address of spacelessString[i] in $t1
	lbu $t2, 0($t1) #store the data at the location spacelessString[i] in $t2
	add $t3, $s1, $a0 #store the address of spacelessString[i+1] in $t3
	lbu $t4, 0($t3) #store the data at the location spacelessString[i+1] in $t4
	beq $t2, 10, exitB #if spacelessString[i] contains the newline character, leave this process
	beq $t2, 40, operatorsAndOpenParens #if spacelessString[i] contains '(', then jump to the code that evaluates (, +, -, *, and /
	beq $t2, 41, lettersAndClosedParens #if spacelessString[i] contains ')', then jump to the code that evaluates a-z,A-Z, and )
	ble $t2, 47, operatorsAndOpenParens #if spacelessString[i] contains an ascii char whose value is less than or equal to 47, and the program has made it to this
	#point without failing or branching out, the char must be one of +,*,-,or/, so brance to the code that evalues these operators
	ble $t2, 57, digits # if the program has made it to this point, and spacelessString[i] contains a char whose value is less than or equal to 57, then
	#it must be one of the digits from 0 to 9, so jump to the code that evaluates those
	# if the program has made it to this point, and there are no invalid symbols, and we have not branched out of the process yet, then spacelessString[i] must
	# be either a letter from a-z or from A-Z
lettersAndClosedParens: 
	beq $t4, 40, failureB #if spacelessString[i+1] is '(', then we have either x(, X(, or )(, all of which are Invalid
	bge $t4, 48, failureB #at this point, we should have no invalid symbols, so if spacelessString[i+1] is >= 48, it must be in one of the ranges
	#0-9, a-z, or A-Z. This means we have x0, X0, )0, xa, Xa, )a, xA, XA, or )A, all of which are Invalid 
	j nextB #if we have not branched out, then move on to the next iteration
digits: 
	beq $t4, 40, failureB #if spacelessString[i+1] is '(', then we have either a digit immediately followed by (, which is Invalid
	bge $t4, 65, failureB #if spacelessString[i+1] is greater than or equal to 65, because we have no invalid symbols, it must be an upper or lowercase letter.
	#A digit immediately followed by a letter is Invalid
	j nextB #if we have not branched out, then move on to the next iteration
operatorsAndOpenParens:
	beq $t4, 10, failureB #if spacelessString[i+1] is a newline, then we have an operator or a ( at the end of the expression, which is Invalid
	beq $t4, 41, failureB #if spacelessString[i+1] is ), then we either have an operator oa ( immediately followed by a )
			      #so we either have an incomplete subexpression within the parens or we have a set of empty parens. Either case is Invalid.
	beq $t4, 42, failureB #if spacelessString[i+1] is *, then we have one of +*, -*, **, /*, or (*, all of which are Invalid.
	beq $t4, 47, failureB #if spacelessString[i+1] is /, then we have one of +/, -/, */, //, or (/, all of which are Invalid.
nextB:  addi $s0, $s0, 1
	addi $s1, $s1, 1 #increment i and j by one
	j L1B #start the next iteration
failureB: la $a0, invalid # display the invalid input message
	  li $v0, 4 # system call code to print a string to console
	  syscall
exitB:  lw $s0, 0($sp) #restore $s0 and s1
    	lw $s1, 4($sp)
    	addi $sp, $sp, 8 #deallocate the space on the stack
    	jr $ra #return
	  
checkForUnevenParens:
#Checks for uneven parentheses
	addi $sp, $sp, -4    # Make space on the stack 
	sw $s0, 0($sp) 	 # Save $s0 
	#Set $s0  to zero so it can be used as a counter
	add $s0, $zero, $zero # i = 0
	add $t3, $zero, $zero #initialize $t3 to zero because we will be adding and subtracting to/from it to keep track of the parens we have seen
    L1C: add $t1, $s0, $a0 # Store the address of spacelessString[i] in $t1
    	lbu $t2, 0($t1) # Store the data at the spacelessString[i] in $t2
    	bltz $t3, failureAndExitC # if at any time $t3 contains a negative value, it means we have encountered more )'s than ('s, so we must have an imbalance
    	beq $t2, 10, exitC # if spacelessString[i] contains a newline, exit the process
    	bne $t2, 40, L2C # branch if spacelessString[i] is not (
    	addi $t3, $t3, 1 #if spacelessString[i] is a (, add 1 to $t3
    	j L3C # branch to the section after the check to see if spacelessString[i] is )
    L2C: bne $t2, 41, L3C #if spacelessString[i] is neither a ( nor a ), then jump ahead
    	addi $t3, $t3, -1 # if spacelessString[i] isa ), subtract one from $t3
    L3C: addi $s0, $s0, 1 # i = i +1
    	j L1C #jump to the next iteration of the loop
    failureAndExitC: lw $s0, 0($sp) #restore $s0
    		     addi $sp, $sp, 4 #deallocate the space on the stack
    		     la $a0, invalid # display the invalid input message
		     li $v0, 4 # system call code to print a string to console
	 	     syscall
    		     jr $ra #return
    exitC: bne $t3, $zero, failureAndExitC #at this point, if $t3 is not equal to zero, then we have an imbalance of parens
    	lw $s0, 0($sp) #restore $s0
    	addi $sp, $sp, 4 #deallocate the space on the stack
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
 exit: lw $s0, 0($sp) #restore $s0
    	addi $sp, $sp, 4 #deallocate the space on the stack
    	jr $ra #return

