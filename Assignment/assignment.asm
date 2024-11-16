.data
    fin:	.asciiz		"/home/bcthanh/Documents/input_matrix.txt"
    fout:	.asciiz		"/home/bcthanh/Documents/output_matrix.txt"
    descriptor:  	.word   	4

    N: 	         	.space  	4	
    M:			.space		4
    p: 	         	.space  	4	
    s:			.space		4
    
    image:		.word 		0:100
    kernel:		.word		0:64
    out:		.word		0:100
    output_size:	.word		4
    
    buffer:      	.space  	1024	
    #temp:		.space		1024			
    char:        	.space  	1
    space:		.asciiz		" "
    newline:        	.asciiz 	"\n"
.text
    # Open "input matrix.txt"
    #addi $v0, $zero, 13 
    #la $a0, fin         		
    #addi $a1, $zero, 0
    li $v0, 13
    la $a0, fin
    li $a1, 0
    li $a2, 0           
    syscall
    sw 	$v0, descriptor
    move $s6, $v0
    
    jal read_float
    cvt.w.s $f0, $f0
    mfc1 $t0, $f0
    sw $t0, N
    
    jal read_float
    cvt.w.s $f0, $f0
    mfc1 $t0, $f0
    sw $t0, M
    
    jal read_float
    cvt.w.s $f0, $f0
    mfc1 $t0, $f0
    sw $t0, p
    
    jal read_float
    cvt.w.s $f0, $f0
    mfc1 $t0, $f0
    sw $t0, s
    
    jal read_image
    jal read_kernel
    
    # Close "input_matrix.txt"
    #addi $v0, $zero, 16    
    lw $a0, descriptor 
    li $v0, 16
    move $a0, $s6
    syscall
    
    jal convolution
    
    # Open "ouputmatrix.txt"
    li $v0, 13
    la, $a0, fout
    li $a1, 1
    li $a2, 0  
    syscall
    sw $v0, descriptor
    move $s6, $v0
    
    la $s0, out
    lw $t0, output_size
    addi $t1, $zero, 0
   
     main_loop_1:
    	beq $t1, $t0, main_end_loop_1
    	
    	addi $t2, $zero, 0
    	main_loop_2:
    	    beq $t2, $t0, main_end_loop_2
    	    
    	    mul $t3, $t1, $t0
    	    add $t3, $t3, $t2
    	    mul $t3, $t3, 4
    	    add $t3, $s0, $t3
    	    lwc1 $f0, 0($t3)
    	    
    	    jal write_float
    	    
    	    addi $v0, $zero, 15
    	    lw $a0, descriptor
    	    la $a1, space
    	    addi $a2, $zero, 1
    	    syscall
    	    
    	    addi $t2, $t2, 1
    	    j main_loop_2
    	main_end_loop_2:
    	
    	addi $v0, $zero, 15
	lw $a0, descriptor
	la $a1, newline
	addi $a2, $zero, 1
	syscall
    	
    	addi $t1, $t1, 1
    	j main_loop_1
    main_end_loop_1:
    
    # Close "ouput matrix.txt"  
    lw $a0, descriptor
    li $v0, 16
    move $a0, $s6  
    syscall
    
    # end program
    addi $v0, $zero, 10
    syscall
# -------------------------------------------------------------------------------------------
# ---------------------------------------- Functions ----------------------------------------
# ___________________________________________________________________________________________
read_float:
    # Read a string from file and convert to float and store in f0
    # Use: a0, a1, a2, v0, t0, t1, t2, t3, f1, f2
    # Store registers
    addi $sp, $sp, -4
    sw $a0, 0($sp)
    addi $sp, $sp, -4
    sw $a1, 0($sp)
    addi $sp, $sp, -4
    sw $a2, 0($sp)
    addi $sp, $sp, -4
    sw $v0, 0($sp)
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    addi $sp, $sp, -4
    sw $t1, 0($sp)
    addi $sp, $sp, -4
    sw $t2, 0($sp)
    addi $sp, $sp, -4
    sw $t3, 0($sp)
    addi $sp, $sp, -4 
    mfc1 $t0, $f1
    sw $t0, 0($sp)
    addi $sp, $sp, -4 
    mfc1 $t0, $f2
    sw $t0, 0($sp)
    # Handle
    mtc1 $zero, $f0	# result
    addi $t0, $zero, 0 	# neg flag
    addi $t1, $zero, 0 	# decimal part flag
    addi $t2, $zero, 10
    sw $t2, -88($fp)
    lwc1 $f1, -88($fp)
    cvt.s.w $f1, $f1	
    
    read_float_loop_1:
    	addi $v0, $zero, 14
	lw  $a0, descriptor
	la $a1, char   
	addi $a2, $zero, 1
	syscall
	
	lb $t2, char
	beq $t2, ' ', read_float_end_loop_1
	beq $t2, '\n', read_float_end_loop_1
	beq $t2, '\0', read_float_end_loop_1
	
	bne $t2, '-', read_float_loop_1_end_check_neg
	addi $t0, $t0, 1
	j read_float_loop_1
	read_float_loop_1_end_check_neg:
	
	bne $t2, '.', read_float_loop_1_end_check_frac
	addi $t1, $t1, 1
	j read_float_loop_1
	read_float_loop_1_end_check_frac:
	
	sub $t2, $t2, '0'
	sw $t2, -88($fp)
    	lwc1 $f2, -88($fp)
    	cvt.s.w $f2, $f2
	beq $t1, 0, read_float_loop_1_handle_dec
	div.s $f2, $f2, $f1
	add.s $f0, $f0, $f2
	addi $t3, $zero, 10
	sw $t3, -88($fp)
    	lwc1 $f2, -88($fp)
    	cvt.s.w $f2, $f2
	mul.s $f1, $f1, $f2
	j read_float_loop_1
	
	read_float_loop_1_handle_dec:
    	mul.s $f0, $f0, $f1
    	add.s $f0, $f0, $f2
    	
    	j read_float_loop_1
    read_float_end_loop_1:
    
    beqz $t0, read_float_end_handle_neg
    addi $t2, $zero, -1
    sw $t2, -88($fp)
    lwc1 $f2, -88($fp)
    cvt.s.w $f2, $f2
    mul.s $f0, $f0, $f2
    read_float_end_handle_neg:
    # Restore registers
    lw $t0, 0($sp)
    mtc1 $t0, $f2
    addi $sp, $sp, 4
    lw $t0, 0($sp)
    mtc1 $t0, $f1
    addi $sp, $sp, 4
    lw $t3, 0($sp)
    addi $sp, $sp, 4
    lw $t2, 0($sp)
    addi $sp, $sp, 4
    lw $t1, 0($sp)
    addi $sp, $sp, 4
    lw $t0, 0($sp)
    addi $sp, $sp, 4
    lw $v0, 0($sp)
    addi $sp, $sp, 4
    lw $a2, 0($sp)
    addi $sp, $sp, 4
    lw $a1, 0($sp)
    addi $sp, $sp, 4
    lw $a0, 0($sp)
    addi $sp, $sp, 4
    jr $ra
# ___________________________________________________________________________________________
read_image:
    # Read nxn value from file and store into image
    # Use: a0, s0, s1, t0, t1, t2, t3, t4, f0

    # Adjust the stack for saving registers
    sub $sp, $sp, 48               # Reserve space for 12 registers (12 * 4 bytes)

    # Save registers on the stack
    sw $a0, 0($sp)                 # Save $a0
    sw $s0, 4($sp)                 # Save $s0
    sw $s1, 8($sp)                 # Save $s1
    sw $t0, 12($sp)                # Save $t0
    sw $t1, 16($sp)                # Save $t1
    sw $t2, 20($sp)                # Save $t2
    sw $t3, 24($sp)                # Save $t3
    sw $t4, 28($sp)                # Save $t4

    # Save $f0 to $t0 and store it
    mfc1 $t0, $f0                  # Move $f0 to $t0 (floating-point to integer)
    sw $t0, 32($sp)                # Store the value of $f0 (now in $t0)

    # Save the return address
    sw $ra, 36($sp)                # Save $ra (return address)

    # Handle image initialization
    la $a0, image                  # Load image address into $a0
    lw $t0, N                      # Load n value (image size) into $t0
    lw $t1, p                      # Load p value (offset) into $t1
    mul $t1, $t1, 2                # Multiply p by 2 (to adjust offset)
    add $t0, $t0, $t1              # Add p*2 to n
    mul $t0, $t0, 4                # Multiply by 4 to account for element size
    add $t0, $a0, $t0              # Add base address to the offset

    # Loop to initialize memory to zero
    read_image_clear_memory:
        beq $t0, $a0, read_image_end_clear   # End loop if pointer reaches original base
        addi $t0, $t0, -4                # Move pointer to next element
        sw $zero, 0($t0)                 # Set the memory value to zero
        j read_image_clear_memory        # Repeat loop

    read_image_end_clear:

    # More image reading and processing logic
    la $a0, image                    # Reload base image address
    lw $t0, N                        # Reload n value
    lw $s0, p                        # Reload p value
    addi $s1, $s0, 0                 # Copy p to s1
    mul $s0, $s0, 2                  # Multiply p by 2
    add $s0, $t0, $s0                # Add p*2 to n

    # Initialize outer loop counter
    addi $t1, $zero, 0               # Initialize outer loop counter to 0

    # Outer loop to traverse rows
    read_image_row_loop:
        beq $t1, $t0, read_image_end_row_loop   # Exit loop if counter reaches n
        addi $t2, $zero, 0             # Initialize inner loop counter to 0

        # Inner loop to traverse columns
        read_image_col_loop:
            beq $t2, $t0, read_image_end_col_loop  # Exit inner loop if counter reaches n
            add $t3, $t1, $s1           # Calculate the row address
            mul $t3, $t3, $s0           # Multiply by (n + p*2)
            add $t3, $t3, $t2           # Add column offset
            add $t3, $t3, $s1           # Add p*2 offset
            mul $t3, $t3, 4             # Multiply by 4 (size of each element)
            add $t3, $a0, $t3           # Calculate final memory address for element
            jal read_float              # Call read_float function to read float value
            mfc1 $t4, $f0               # Move floating-point result to $t4
            sw $t4, 0($t3)              # Store the floating-point value at the address

            addi $t2, $t2, 1            # Increment inner loop counter
            j read_image_col_loop       # Repeat column loop

        read_image_end_col_loop:
        addi $t1, $t1, 1                # Increment row counter
        j read_image_row_loop           # Repeat row loop

    read_image_end_row_loop:

    # Store the updated n value back
    sw $s0, N                        # Store updated n value

    # Restore registers from stack
    lw $ra, 36($sp)                  # Restore $ra (return address)
    addi $sp, $sp, 4
    lw $t0, 32($sp)                  # Restore $t0
    mtc1 $t0, $f0                    # Restore $f0 from $t0
    addi $sp, $sp, 4
    lw $t4, 28($sp)                  # Restore $t4
    addi $sp, $sp, 4
    lw $t3, 24($sp)                  # Restore $t3
    addi $sp, $sp, 4
    lw $t2, 20($sp)                  # Restore $t2
    addi $sp, $sp, 4
    lw $t1, 16($sp)                  # Restore $t1
    addi $sp, $sp, 4
    lw $t0, 12($sp)                  # Restore $t0
    addi $sp, $sp, 4
    lw $s1, 8($sp)                   # Restore $s1
    addi $sp, $sp, 4
    lw $s0, 4($sp)                   # Restore $s0
    addi $sp, $sp, 4
    lw $a0, 0($sp)                   # Restore $a0
    addi $sp, $sp, 4

    jr $ra                           # Return from function


# ___________________________________________________________________________________________
read_kernel:
    # Read mxm value from file and store into kernel
    # Use: a0, t0, t1, t2, t3, t4, f0
    # Store registers
    addi $sp, $sp, -4
    sw $a0, 0($sp)
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    addi $sp, $sp, -4
    sw $t1, 0($sp)
    addi $sp, $sp, -4
    sw $t2, 0($sp)
    addi $sp, $sp, -4
    sw $t3, 0($sp)
    addi $sp, $sp, -4
    sw $t4, 0($sp)
    addi $sp, $sp, -4 
    mfc1 $t0, $f0
    sw $t0, 0($sp)
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    # Handle
    la $a0, kernel
    lw $t0, M
    addi $t1, $zero, 0
    read_kernel_loop_1:
    	beq $t1, $t0, read_kernel_end_loop_1
    	    
    	    addi $t2, $zero, 0
    	    read_kernel_loop_2:
    	        beq $t2, $t0, read_kernel_end_loop_2
    	        
    	        mul $t3, $t1, $t0
    	        add $t3, $t3, $t2
    	        mul $t3, $t3, 4
    	        add $t3, $a0, $t3
    	        
    	        jal read_float
    	        mfc1 $t4, $f0
    	        sw $t4, 0($t3)
    	        
    	    	addi $t2, $t2, 1
    	    	j read_kernel_loop_2
    	    read_kernel_end_loop_2:
    	addi $t1, $t1, 1
    	j read_kernel_loop_1
    read_kernel_end_loop_1:
    # Restore registers
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    lw $t0, 0($sp)
    mtc1 $t0, $f0
    addi $sp, $sp, 4
    lw $t4, 0($sp)
    addi $sp, $sp, 4
    lw $t3, 0($sp)
    addi $sp, $sp, 4
    lw $t2, 0($sp)
    addi $sp, $sp, 4
    lw $t1, 0($sp)
    addi $sp, $sp, 4
    lw $t0, 0($sp)
    addi $sp, $sp, 4
    lw $a0, 0($sp)
    addi $sp, $sp, 4
    jr $ra
# ___________________________________________________________________________________________
convolution:
    # Calc convolution
    # Use: a0, a1, a2, t0, t1, t2, t3, t4, t5, t6, t7, f0, f1, f2
    # Store registers
    
    subi $sp, $sp, -56	# space for 14 registers
    
    # Save general-purpose registers (a0 to a2, t0 to t7)
    sw $a0, 0($sp)                # Save $a0
    sw $a1, 4($sp)                # Save $a1
    sw $a2, 8($sp)                # Save $a2
    sw $t0, 12($sp)               # Save $t0
    sw $t1, 16($sp)               # Save $t1
    sw $t2, 20($sp)               # Save $t2
    sw $t3, 24($sp)               # Save $t3
    sw $t4, 28($sp)               # Save $t4
    sw $t5, 32($sp)               # Save $t5
    sw $t6, 36($sp)               # Save $t6
    sw $t7, 40($sp)               # Save $t7
    
    # Save floating-point registers (f0 to f2) into general-purpose registers
    mfc1 $t0, $f0                 # Move $f0 to $t0
    sw $t0, 44($sp)               # Save $f0 (stored in $t0)
    mfc1 $t0, $f1                 # Move $f1 to $t0
    sw $t0, 48($sp)               # Save $f1 (stored in $t0)
    mfc1 $t0, $f2                 # Move $f2 to $t0
    sw $t0, 52($sp)               # Save $f2 (stored in $t0)
    
    # Handle
    la $a0, image
    la $a1, kernel
    la $a2, out
    lw $t0, N
    lw $t1, M
    lw $t3, s
    sub $t2, $t0, $t1
    div $t2, $t3
    mflo $t2
    addi $t2, $t2, 1
    sw $t2, output_size
    
    addi $t4, $zero, 0
    convolution_loop_1:
    	beq $t4, $t2, convolution_end_loop_1
    	
    	addi $t5, $zero, 0
    	convolution_loop_2:
    	    beq $t5, $t2, convolution_end_loop_2
    	    
    	    	addi $t6, $zero, 0
    	    	mtc1 $zero, $f0
    	    	convolution_loop_3:
    	    	    beq $t6, $t1, convolution_end_loop_3
    	    	    	
    	    	    	addi $t7, $zero, 0
    	    	    	convolution_loop_4:
    	    	    	    beq $t7, $t1, convolution_end_loop_4
    	    	    	    
    	    	    	    mul $s0, $t4, $t3
    	    	    	    add $s0, $s0, $t6
    	    	    	    mul $s1, $t5, $t3
    	    	    	    add $s1, $s1, $t7
    	    	    	    
    	    	    	    mul $s0, $s0, $t0
    	    	    	    add $s0, $s0, $s1
    	    	    	    mul $s0, $s0, 4
    	    	    	    add $s0, $a0, $s0
    	    	    	    lwc1 $f1, 0($s0)
    	    	    	    
    	    	    	    mul $s1, $t6, $t1
    	    	    	    add $s1, $s1, $t7
    	    	    	    mul $s1, $s1, 4
    	    	    	    add $s1, $a1, $s1
    	    	    	    lwc1 $f2, 0($s1)
    	    	    	    
    	    	    	    mul.s $f1, $f1, $f2
    	    	    	    add.s $f0, $f0, $f1
    	    	    	    
    	    	    	    addi $t7, $t7, 1
    	    	    	    j convolution_loop_4
    	    	    	convolution_end_loop_4:
    	    	    	
    	    	    addi $t6, $t6, 1
    	    	    j convolution_loop_3
    	    	convolution_end_loop_3:
    	    	
    	    	mul $t6, $t4, $t2
    	    	add $t6, $t6, $t5
    	    	mul $t6, $t6, 4
    	    	add $t6, $a2, $t6
    	    	mfc1 $t7, $f0
		sw $t7, 0($t6)
    	    
    	    addi $t5, $t5, 1
    	    j convolution_loop_2
    	convolution_end_loop_2:
    	
    	addi $t4, $t4, 1
    	j convolution_loop_1
    convolution_end_loop_1:
    # Restore registers
    lw $t0, 0($sp)
    mtc1 $t0, $f2
    addi $sp, $sp, 4
    lw $t0, 0($sp)
    mtc1 $t0, $f1
    addi $sp, $sp, 4
    lw $t0, 0($sp)
    mtc1 $t0, $f0
    addi $sp, $sp, 4
    lw $t7, 0($sp)
    addi $sp, $sp, 4
    lw $t6, 0($sp)
    addi $sp, $sp, 4
    lw $t5, 0($sp)
    addi $sp, $sp, 4
    lw $t4, 0($sp)
    addi $sp, $sp, 4
    lw $t3, 0($sp)
    addi $sp, $sp, 4
    lw $t2, 0($sp)
    addi $sp, $sp, 4
    lw $t1, 0($sp)
    addi $sp, $sp, 4
    lw $t0, 0($sp)
    addi $sp, $sp, 4
    lw $a2, 0($sp)
    addi $sp, $sp, 4
    lw $a1, 0($sp)
    addi $sp, $sp, 4
    lw $a0, 0($sp)
    addi $sp, $sp, 4
    jr $ra
# ___________________________________________________________________________________________
write_float:
    # write float value stored in f0 to file
    # Use: a0, a1, a2, v0, t0, t1, t2, t3, t4, f0, f1
    # Store registers
    addi $sp, $sp, -4
    sw $a0, 0($sp)
    addi $sp, $sp, -4
    sw $a1, 0($sp)
    addi $sp, $sp, -4
    sw $a2, 0($sp)
    addi $sp, $sp, -4
    sw $v0, 0($sp)
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    addi $sp, $sp, -4
    sw $t1, 0($sp)
    addi $sp, $sp, -4
    sw $t2, 0($sp)
    addi $sp, $sp, -4
    sw $t3, 0($sp)
    addi $sp, $sp, -4
    sw $t4, 0($sp)
    addi $sp, $sp, -4 
    mfc1 $t0, $f0
    sw $t0, 0($sp)
    addi $sp, $sp, -4 
    mfc1 $t0, $f1
    sw $t0, 0($sp)
    # Handle
    la $a0, buffer
    addi $t0, $zero, 0
    
    addi $t1, $zero, 10
    sw $t1, -88($fp)
    lwc1 $f1, -88($fp)
    cvt.s.w $f1, $f1
    mul.s $f0, $f0, $f1
    round.w.s $f0, $f0
    mfc1 $t1, $f0
    
    addi $t4, $zero, 0
    blt $t1, $zero, write_float_check_neg
    j write_float_end_check_neg
    write_float_check_neg:
	addi $t4, $zero, 1	# Negative flag
    	mul $t1, $t1, -1
    write_float_end_check_neg:
    
    addi $t2, $zero, 10
    div $t1, $t2
    mflo $t1
    mfhi $t2
    
    write_float_loop_dec:
        addi $t3, $zero, 10
        div $t1, $t3
        mflo $t1
        mfhi $t3
        
        addi $t3, $t3, '0'
        addi $sp, $sp, -1
        sb $t3, 0($sp)
        addi $t0, $t0, 1
        
        bnez $t1, write_float_loop_dec
       
    beqz $t4, write_float_end_hande_neg
    addi $sp, $sp, -1
    addi $t3, $zero, '-'
    sb $t3, 0($sp)
    addi $t0, $t0, 1
    write_float_end_hande_neg:
    
    add $t3, $zero, $t0
    write_float_loop_rev:
       	beqz $t3, write_float_end_loop_rev
    	lb $t4, 0($sp)
    	addi $sp, $sp, 1
    	sb $t4, 0($a0)
    	addi $a0, $a0, 1
    	addi $t3, $t3, -1
    	
    	j write_float_loop_rev
    write_float_end_loop_rev:
    
    addi $t3, $zero, '.'
    sb $t3, 0($a0)
    addi $a0, $a0, 1
    addi $t0, $t0, 1
    
    addi $t2, $t2, '0'
    sb $t2, 0($a0)
    addi $a0, $a0, 1
    addi $t0, $t0, 1
    
    # Write buffer to file
    addi $v0, $zero, 15
    lw $a0, descriptor
    la $a1, buffer
    add $a2, $zero, $t0
    syscall
    
    # Restore registers
    lw $t0, 0($sp)
    mtc1 $t0, $f1
    addi $sp, $sp, 4
    lw $t0, 0($sp)
    mtc1 $t0, $f0
    addi $sp, $sp, 4
    lw $t4, 0($sp)
    addi $sp, $sp, 4
    lw $t3, 0($sp)
    addi $sp, $sp, 4
    lw $t2, 0($sp)
    addi $sp, $sp, 4
    lw $t1, 0($sp)
    addi $sp, $sp, 4
    lw $t0, 0($sp)
    addi $sp, $sp, 4
    lw $v0, 0($sp)
    addi $sp, $sp, 4
    lw $a2, 0($sp)
    addi $sp, $sp, 4
    lw $a1, 0($sp)
    addi $sp, $sp, 4
    lw $a0, 0($sp)
    addi $sp, $sp, 4
    jr $ra
# ___________________________________________________________________________________________
