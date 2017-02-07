# This program evaluates simple algebraic expressions
# Procedure:
# 1. Create a buffer ("inputString" in this case) to store the input string
# 2. Load the address of the buffer to register $a0
# 3. Load the length of the buffer to register $a1
# 4. Load register $v0 with 8
# 5. Issue "syscall"
# Remove spaces from inputString by copying inputString to another string but not copying the spaces
# Set aside 5 registers to hold the three operands and two operators 
# Iterate over new string, checking each byte to see if it is an operator - if it is, load it into one of the op registers. Now we know that from the beginning of the string to this register is our first operand
# Get all the operators. I should then end up with all the operands.
# 
.data			# What follows will be data
inputString: .space 64	# set aside 64 bytes to store the input string
spacelessString: .space 64 # set aside 64 bytes that we will copy the input string (minus any spaces) into 
prompt: .asciiz "Enter an algebraic expression: "
answer: .asciiz "Answer: "
.text			# What follows will be actual code
main: 
	# Display prompt
	la	$a0, prompt	# display the prompt to begin
	li	$v0, 4	# system call code to print a string to console
	syscall
	# get the string from console
	la	$a0, inputString	# load $a0 with the address of inputString; procedure: $a0 = buffer, $a1 = length of buffer
	la	$a1, spacelessString	# maximum number of character
	li	$v0, 8	# The system call code to read a string input
	syscall
	jal removeSpaces
	# Print "You typed: " to console
	la	$a0, ($a1) # store the contents of $a1 (which is spacelessString) in $a0 
	
#FndOps: add $t0, $zero, $zero # i = 0
#   FL1: add $t1, $t0, $a0 # Store the address of spacelessString[i] in $t1
#    	lbu $t2, 0($t1) # Store inputString[i] in $t2
#    	beq $t2, 43, L2 # if $t2 is equal to 43, then inputString[i] == '+' and we add
#	add $t3, $s1 , $a1 # store the address of spacelessString[j] in $t3
#	sb $t2, 0($t3) # save inputString[i] into the space for spacelessString[j]
#	addi $s1, $s1, 1 # increment j
 #  FL2: beq $t2, $zero, L3 # if $t2 is equal to $zero, then inputString[i] == '\0' and we are done copying
  #  	addi $s0, $s0, 1 # increment i
   # 	j L1 
	li	$v0, 4
	syscall
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
	add $t3, $s1 , $a1 # store the address of spacelessString[j] in $t3
	sb $t2, 0($t3) # save inputString[i] into the space for spacelessString[j]
	addi $s1, $s1, 1 # increment j
    L2: beq $t2, $zero, L3 # if $t2 is equal to $zero, then inputString[i] == '\0' and we are done copying
    	addi $s0, $s0, 1 # increment i
    	j L1 
    L3: lw $s0, 0($sp) #restore $s0 and s1
    	lw $s1, 4($sp)
    	addi $sp, $sp, 8 #deallocate the space on the stack
    	jr $ra #return
    	
#findOperators:
#Find the operators in the expression and store them
#	addi $sp, $sp, -4    # Make space on the stack 
#	sw $s0, 0($sp) #save $s0
#	#Set $s0 to zero so it can be used as counter
#	add $s0, $zero, $zero # i = 0
#    L1: add $t1, $s0, $a0 # Store the address of spacelessString[i] in $t1
#    	lbu $t2, 0($t1) # Store inputString[i] in $t2
#    	beq $t2, 32, L2 # if $t2 is equal to 32, then inputString[i] == ' ' and we skip copying this char
#	add $t3, $s1 , $a1 # store the address of spacelessString[j] in $t3
#	sb $t2, 0($t3) # save inputString[i] into the space for spacelessString[j]
#	addi $s1, $s1, 1 # increment j
#    L2: beq $t2, $zero, L3 # if $t2 is equal to $zero, then inputString[i] == '\0' and we are done copying
#    	addi $s0, $s0, 1 # increment i
#   	j L1 
#    L3: lw $s0, 0($sp) #restore $s0 and s1
#   	lw $s1, 4($sp)
#    	addi $sp, $sp, 8 #deallocate the space on the stack
#    	jr $ra #return
	
