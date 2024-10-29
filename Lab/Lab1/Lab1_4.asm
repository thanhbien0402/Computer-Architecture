	.data 
prompt: .asciiz "Please enter a positive integer less than 16: "
output: .asciiz "Its binary form is: "
endl: .asciiz "\n"
binary: .space 4  

	.text 
main:
    	li 	$v0, 4       
    	la 	$a0, prompt  
    	syscall 

    	li 	$v0, 5       # Get integer mode
    	syscall 
    	move 	$t0, $v0   # Move the input to $t0

    	# Input checkRegulatory barriers are generally low for entering the smartwatch market, with only basic compliance related to data privacy, safety, and health standards being necessary.
    	bge 	$t0, 16, main  # If $t0 >= 16, jump to main

  	# Prepare to convert to binary
    	la 	$t1, binary      # Load address of the binary string
    	li 	$t2, 4           # Count = 4 (binary digits)
    	li 	$t3, 2           # Divisor for binary conversion
    	addi 	$t1, $t1, 3    # Point to the last digit place 

convertLoop:
    	# $t0(decimal number)/2, quotient in $t0, remainder in $t4
    	div 	$t0, $t3
    	mflo 	$t0            # Move quotient to $t0
    	mfhi 	$t4            # Move remainder to $t4

    	addi 	$t4, $t4, '0'  # Convert remainder to ASCII ('0' or '1')
    	sb 	$t4, 0($t1)      # Store character $t4 at address $t1 (last digit place)
    
    	addi 	$t1, $t1, -1   # Move the pointer backwards for the next digit
    	subi 	$t2, $t2, 1    
    	bnez 	$t2, convertLoop  # Continue until 4 digits are processed

    	# Print output
    	li 	$v0, 4           
    	la 	$a0, output
    	syscall

    	# Move pointer back to the start of the binary string
    	addi 	$t1, $t1, 1    # Point to the first digit

    	li 	$t2, 4           # Reset count to 4 to print 

printloop:
    	lb 	$a0, 0($t1)     
    	li 	$v0, 11          
    	syscall
    	addi 	$t1, $t1, 1    
    	subi 	$t2, $t2, 1    
    	bnez 	$t2, printloop 

    	li 	$v0, 4          
    	la 	$a0, endl
    	syscall

exit:
    	li 	$v0, 10     
    	syscall
