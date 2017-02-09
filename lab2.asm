# This program evaluates simple algebraic expressions
# See report for procedure
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
	la	$a1, inputString # maximum number of character
	la	$a2, spacelessString    # load $a2 with the address of spacelessString; procedure: $a2 = buffer, $a3 = length of buffer
	la	$a3, spacelessString
	li	$v0, 8	# The system call code to read a string input
	syscall
	add $t0, $zero, $zero #initialize all temporary registers to zero
	add $t1, $zero, $zero
	add $t2, $zero, $zero
	add $t3, $zero, $zero
	add $t4, $zero, $zero
	add $t5, $zero, $zero
	add $t6, $zero, $zero
	add $t7, $zero, $zero
	add $t8, $zero, $zero
	add $t9, $zero, $zero
	jal removeSpaces # Copy the contents of inputString into spacelessString, removing all spaces
	la	$a0, ($a2) # store the contents of $a2 (which is spacelessString) in $a0 
	jal findOperators # Identify the two operators in the algebraic expression 
	add $t9, $zero, $zero # reset $t9 to zero

	#Evaluate the expression
	beq $t4, $t5,bothSameOperator #If both operators are the same, we don't need to worry about order of operations
	#If they are not both the same, we need to deal with order of operations (PEMDAS)
	beq $t4, 42, mul1 #First operator is *
	beq $t5, 42, mul2 #First operator is not *, second operator is *
	beq $t4, 47, div1 #First operator is /
	beq $t5, 47, div2 #First operator is not /, second operator is / 
	beq $t4, 43, add1 #First operator is +
	beq $t4, 45, sub1 #First operator is -
	
	
	
	
	result:
	li	$v0, 1 #System call code to print an int
	add $a0, $zero, $t9 # put result of expression into $a0
	syscall #print
	j main #loop
	
	
bothSameOperator:
	beq $t4, 42, bothMult #Both operators are *
	beq $t4, 43, bothAdd #Both operators are +
	beq $t4, 45, bothSub #Both operators are -
	beq $t4, 47, bothDiv #Both operators are /
bothMult: mul $t6, $t6, $t7
	mul $t9, $t6, $t8
	j result
bothAdd: add $t6, $t6, $t7
	add $t9, $t6, $t8
	j result
bothSub: sub $t6, $t6, $t7
	sub $t9, $t6, $t8
	j result
bothDiv: div $t6, $t7
	mflo $t6
	div $t6, $t8
	mflo $t9
	j result

mul1: mul $t6, $t6, $t7 #First operator is *. Multiply first two operands, then find what the second operator is and perform the second operation
	beq $t5, 47, m1d2
	beq $t5, 43, m1a2
	sub $t9, $t6, $t8 # m1s2
	j result
m1d2: div $t6, $t8
	mflo $t9
	j result
m1a2: add $t9, $t6, $t8
	j result
	
mul2: mul $t7, $t7, $t8 #Second operator is *. Multiply second and third operands, then find what the first operator is and perform the second operation
	beq $t4, 43, a1m2
	sub $t9, $t6, $t7 # m2s1
	j result
a1m2: add $t9, $t6, $t7
	j result

div1: div  $t6, $t7
	mflo $t6
	beq $t5, 42, d1m2
	beq $t5, 43, d1a2
	sub $t9, $t6, $t8 # d1s2
	j result
d1m2: mul $t9, $t6, $t8
	j result
d1a2: add $t9, $t6, $t8
	j result
	
div2: div $t7, $t8
	mflo $t7

	beq $t4, 43, a1d2
	sub $t9, $t6, $t7 # s1d2
	j result
a1d2: add $t9, $t6, $t7
	j result
	
add1: add $t6, $t6, $t7

	sub $t9, $t6, $t8 # a1s2
	j result

	
sub1: sub $t6, $t6, $t7
	add $t9, $t6, $t8 # s1a2
	j result

	
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
    	
findOperators:
#Find the operators in the expression and store them
	addi $sp, $sp, -4    # Make space on the stack 
	sw $s0, 0($sp) #save $s0
	
	addi $t9, $zero, 10 #load the ascii equivalent of a newline into $t9 to use it to see if we have reached the end of the input string
	add $s0, $zero, $zero # i = 0
	add $t0, $zero, $zero # set int accumulator to 0     
 start: add $t1, $s0, $a2 # Store the address of spacelessString[i] in $t1
    	lbu $t2, 0($t1) # Store inputString[i] in $t2
    	beq $t2, $t9, exit #end of string
    	beq $t2, 42, op1 #found *
    	beq $t2, 47, op1 # found /
    	beq $t2, 43, op1 # found +
    	bne $t2, 45, reloop1 #found -
op1:	add $t4, $zero, $t2 #store first operator in $t4   
	
	add $t6, $zero, $t0 #store the current number in $t6
	add $t0, $zero, $zero # clear current number accumulator
	addi $s0, $s0, 1 #increment i
	j start2 
reloop1:addi $s0, $s0, 1 #increment i
	mul $t0, $t0, 10 #multiply the current number accumulator by 10
	addi $t2, $t2, -48 #subtract 48 from the contents of $t2 to convert it from ascii to an int
	add $t0, $t2, $t0 # add contents of $t2 to current number accumulator
	j start
start2: add $t1, $s0, $a2 
	lbu $t2, 0($t1)
	beq $t2, $t9, exit #end of string
    	beq $t2, 42, op2 #found *
    	beq $t2, 47, op2 # found /
    	beq $t2, 43, op2 # found +
    	bne $t2, 45, reloop2 #found -
op2:	add $t5, $zero, $t2 #store second operator in $t5
	add $t7, $zero, $t0 #store the current number in $t7
	add $t0, $zero, $zero # clear current number accumulator
	addi $s0,$s0, 1 #increment i
	j start3
reloop2:addi $s0, $s0, 1 #increment i
	mul $t0, $t0, 10 #multiply the current number accumulator by 10
	addi $t2, $t2, -48 #subtract 48 from the contents of $t2 to convert it from ascii to an int
	add $t0, $t2, $t0 # add contents of $t2 to current number accumulator
	j start2
start3: add $t1, $s0, $a2
	lbu $t2, 0($t1)
	beq $t2, $t9, exit2
	mul $t0, $t0, 10 #multiply the current number accumulator by 10
	addi $t2, $t2, -48 #subtract 48 from the contents of $t2 to convert it from ascii to an int
	add $t0, $t2, $t0 # add contents of $t2 to current number accumulator
	addi $s0, $s0, 1
	j start3
exit2:	add $t8, $zero, $t0 #store the current number in $t8
	j exit
exit:	
	
	lw $s0, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
	
