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
	la	$a1, spacelessString	
	li	$v0, 4
	syscall
	j main
	
removeSpaces:
	addi $sp, $sp, -4
	sw $s0, 0($sp)
	add $s0, $zero, $zero
    L1: add $t1, $s0, $a0
    	lbu $t2, 0($t1)
	add $t3, $s0 , $a1
	beq $t2, 32, L2
	sb $t2, 0($t3)
    L2: beq $t2, $zero, L3
    	addi $s0, $s0, 1
    	j L1
    L3: lw $s0, 0($sp)
    	addi $sp, $sp, 4
    	jr $ra
	
