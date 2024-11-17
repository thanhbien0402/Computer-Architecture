.data
    fin:	.asciiz		"/home/bcthanh/Documents/input_matrix.txt"
    fout:	.asciiz		"/home/bcthanh/Documents/output_matrix.txt"
    invalid_msg: .asciiz	"Error! Kernel size is larger than the padded image matrix.\n"
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
    character:        	.space  	1
    space:		.asciiz		" "
    newline:        	.asciiz 	"\n"
    
.text
    # Open "input matrix.txt"
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
    lw $a0, descriptor 
    li $v0, 16
    move $a0, $s6
    syscall
    
    jal convolution
    
    # Open "ouput_matrix.txt"
    li $v0, 13
    la $a0, fout
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
    
    		# Calculate index and load matrix element
    		mul $t3, $t1, $t0
    		add $t3, $t3, $t2
    		mul $t3, $t3, 4
    		add $t3, $s0, $t3
    		lwc1 $f0, 0($t3)
    
    		jal write_float

    		# Add space only if not the last column
    		addi $t4, $t2, 1
    		bne $t4, $t0, write_space
    
    		j skip_space
	write_space:
    		addi $v0, $zero, 15
    		lw $a0, descriptor
    		la $a1, space
    		addi $a2, $zero, 1
    		syscall
	skip_space:

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
    
    # Close "ouput_matrix.txt"  
    lw $a0, descriptor
    li $v0, 16
    move $a0, $s6  
    syscall
    
    # end program
    li $v0, 10
    syscall
# -------------------------------------------------------------------------------------------
# ---------------------------------------- Functions ----------------------------------------
# ___________________________________________________________________________________________
read_float:
    # Read a string from file and convert to float and store in f0
    # Use: a0, a1, a2, v0, t0-t3, f1-f2

    # Save registers on stack
    subi $sp, $sp, 40
    sw $a0, 0($sp)
    sw $a1, 4($sp)
    sw $a2, 8($sp)
    sw $v0, 12($sp)
    sw $t0, 16($sp)
    sw $t1, 20($sp)
    sw $t2, 24($sp)
    sw $t3, 28($sp)
    mfc1 $t0, $f1
    sw $t0, 32($sp)
    mfc1 $t0, $f2
    sw $t0, 36($sp)
    
    # Initialize variables
    mtc1 $zero, $f0          # $f0 = 0.0 (result)
    addi $t0, $zero, 0       # t0 = neg_flag (0: positive, 1: negative)
    addi $t1, $zero, 0       # t1 = dec_flag (0: integer part, 1: decimal part)
    addi $t2, $zero, 10
    sw $t2, -88($fp)         # Save initial decimal divisor (10)
    lwc1 $f1, -88($fp)       # $f1 = 10.0
    cvt.s.w $f1, $f1         # Convert to float	
    
    read_float_loop:
    	# Read one character
    	addi $v0, $zero, 14      # Syscall: read character
    	lw $a0, descriptor       # File descriptor
    	la $a1, character             # Buffer for one character
    	addi $a2, $zero, 1       # Read 1 byte
    	syscall

    	# Load character into t2
    	lb $t2, character
    	beq $t2, ' ', read_float_end_loop
    	beq $t2, '\n', read_float_end_loop
    	beq $t2, '\0', read_float_end_loop

    	# Handle negative sign
    	bne $t2, '-', check_decimal
    	addi $t0, $t0, 1         # Set neg_flag
    	j read_float_loop

    check_decimal:
    	# Handle decimal point
    	bne $t2, '.', convert_digit
    	addi $t1, $t1, 1         # Set dec_flag
    	j read_float_loop

    convert_digit:
    	# Convert character to integer
    	sub $t2, $t2, '0'        # Convert ASCII to digit
    	sw $t2, -88($fp)
    	lwc1 $f2, -88($fp)       # Load digit as float
    	cvt.s.w $f2, $f2         # Convert to float

    	# Handle decimal or integer part
    	beq $t1, $zero, add_integer_part
    	div.s $f2, $f2, $f1      # Divide by current decimal divisor
    	add.s $f0, $f0, $f2      # Add to result
    	mul.s $f1, $f1, $f2      # Update decimal divisor (×10)
    	j read_float_loop

     add_integer_part:
    	mul.s $f0, $f0, $f1      # Shift left for next digit
    	add.s $f0, $f0, $f2      # Add digit to result
    	j read_float_loop

     read_float_end_loop:
    	# Apply negative sign if needed
    	beqz $t0, restore_registers
    	addi $t2, $zero, -1      # Multiplier for negative
    	sw $t2, -88($fp)
    	lwc1 $f2, -88($fp)
    	cvt.s.w $f2, $f2
    	mul.s $f0, $f0, $f2      # Negate result if necessary
    
restore_registers:    
    # Restore registers
    lw $t0, 36($sp)
    mtc1 $t0, $f2
    lw $t0, 32($sp)
    mtc1 $t0, $f1
    lw $t3, 28($sp)
    lw $t2, 24($sp)
    lw $t1, 20($sp)
    lw $t0, 16($sp)
    lw $v0, 12($sp)
    lw $a2, 8($sp)
    lw $a1, 4($sp)
    lw $a0, 0($sp)
    addi $sp, $sp, 40
    jr $ra        
               
# ___________________________________________________________________________________________
read_image:
    # Read nxn value from file and store into image
    # Use: a0, s0, s1, t0, t1, t2, t3, t4, f0

    # Adjust the stack for saving registers
    subi $sp, $sp, 48               # Reserve space for 12 registers (12 * 4 bytes)

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

    sll $t1, $t1, 1                # Multiply p by 2 (to adjust offset)
    add $t0, $t0, $t1              # Add p*2 to n
    
    sll $t0, $t0, 2                # Multiply by 4 to account for element size
    add $t0, $a0, $t0              # Add base address to the offset

    # Clear image array
    clear_image_loop:
        beq $t0, $a0, end_clear_image_loop
        subi $t0, $t0, 4                # Move pointer to next element
        sw $zero, 0($t0)                 # Set the memory value to zero
        j clear_image_loop       # Repeat loop

    end_clear_image_loop:

    # Read NxN values and store into image
    la $a0, image                    # Reload base image address
    lw $t0, N                        # Reload n value
    lw $s0, p                        # Reload p value
    addi $s1, $s0, 0                 # Copy p to s1
    sll $s0, $s0, 1                  # Multiply p by 2
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
            sll $t3, $t3, 2             # Multiply by 4 (size of each element)
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
    sw $s0, N                        # N + 2p

    # Restore registers from stack
    # Restore registers
    lw $ra, 36($sp)
    lw $t0, 32($sp)
    mtc1 $t0, $f0
    lw $t4, 28($sp)
    lw $t3, 24($sp)
    lw $t2, 20($sp)
    lw $t1, 16($sp)
    lw $t0, 12($sp)
    lw $s1, 8($sp)
    lw $s0, 4($sp)
    lw $a0, 0($sp)
    addi $sp, $sp, 48       
    jr $ra                 

# ___________________________________________________________________________________________
read_kernel:
    # Lưu các thanh ghi cần thiết
    subi $sp, $sp, 32         # Tạo không gian trên stack
    sw $ra, 28($sp)            # Lưu giá trị $ra
    sw $a0, 24($sp)            # Lưu giá trị $a0
    sw $t0, 20($sp)
    sw $t1, 16($sp)
    sw $t2, 12($sp)
    sw $t3, 8($sp)
    sw $t4, 4($sp)
    mfc1 $t0, $f0
    sw $t0, 0($sp)             # Lưu giá trị $f0 dưới dạng số nguyên

    # Bắt đầu xử lý
    la $a0, kernel             # Địa chỉ của `kernel`
    lw $t0, M                  # Giá trị của `m` (số hàng/cột)
    li $t1, 0                  # Khởi tạo t1 (chỉ số hàng)

read_kernel_outer_loop:
    bge $t1, $t0, read_kernel_done_outer_loop  # Nếu t1 >= m, thoát vòng lặp
    li $t2, 0                  # Khởi tạo t2 (chỉ số cột)

read_kernel_inner_loop:
    bge $t2, $t0, read_kernel_done_inner_loop  # Nếu t2 >= m, thoát vòng lặp
    # Tính địa chỉ kernel[t1][t2]
    mul $t3, $t1, $t0          # t3 = t1 * m (chỉ số dòng * số cột)
    add $t3, $t3, $t2          # t3 = t3 + t2 (thêm chỉ số cột)
    sll $t3, $t3, 2            # t3 = t3 * 4 (mỗi phần tử 4 bytes)
    add $t3, $a0, $t3          # t3 = &kernel[t1][t2]
    
    # Gọi hàm đọc số thực
    jal read_float             # Gọi read_float để đọc số thực vào $f0
    mfc1 $t4, $f0              # Chuyển giá trị $f0 thành số nguyên
    sw $t4, 0($t3)             # Lưu giá trị vào kernel[t1][t2]

    # Tiếp tục vòng lặp trong
    addi $t2, $t2, 1
    j read_kernel_inner_loop

read_kernel_done_inner_loop:
    addi $t1, $t1, 1           # Tăng chỉ số dòng
    j read_kernel_outer_loop

read_kernel_done_outer_loop:
    # Restore
    lw $t0, 0($sp)           
    mtc1 $t0, $f0
    lw $t4, 4($sp)
    lw $t3, 8($sp)
    lw $t2, 12($sp)
    lw $t1, 16($sp)
    lw $t0, 20($sp)
    lw $a0, 24($sp)
    lw $ra, 28($sp)
    addi $sp, $sp, 32        
    jr $ra                     
# ___________________________________________________________________________________________
convolution:
    # Calc convolution
    # Use: a0, a1, a2, t0, t1, t2, t3, t4, t5, t6, t7, f0, f1, f2
    # Store registers
    
    subi $sp, $sp, 24	# space for 14 registers
    
    # Save general-purpose registers (a0 to a2, t0 to t7)
    sw $a0, 0($sp)                # Save $a0
    sw $a1, 4($sp)                # Save $a1
    sw $a2, 8($sp)                # Save $a2

    # Save floating-point registers (f0 to f2) into general-purpose registers
    mfc1 $t0, $f0                 # Move $f0 to $t0
    sw $t0, 12($sp)               # Save $f0 (stored in $t0)
    mfc1 $t0, $f1                 # Move $f1 to $t0
    sw $t0, 16($sp)               # Save $f1 (stored in $t0)
    mfc1 $t0, $f2                 # Move $f2 to $t0
    sw $t0, 20($sp)               # Save $f2 (stored in $t0)
    
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
    
    subi $t4, $zero, 0
    convolution_loop_1:
    	beq $t4, $t2, convolution_end_loop_1
    	
    	addi $t5, $zero, 0
    	convolution_loop_2:
    	    beq $t5, $t2, convolution_end_loop_2
    	    
    	    	mtc1 $zero, $f0
    	    	addi $t6, $zero, 0
    	    	
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
    	    	
 
     		# Store the result into the output matrix
    		mul $t6, $t4, $t2
    		add $t6, $t6, $t5
    		sll $t6, $t6, 2
    		add $t6, $a2, $t6
    		swc1 $f0, 0($t6)  # Store the floating-point result

    	    addi $t5, $t5, 1
     	    j convolution_loop_2
    	convolution_end_loop_2:

    	addi $t4, $t4, 1
    	j convolution_loop_1
    convolution_end_loop_1:

    # Restore general-purpose registers
    lw $a0, 0($sp)
    lw $a1, 4($sp)
    lw $a2, 8($sp)

    # Restore floating-point registers
    lw $t0, 12($sp)
    mtc1 $t0, $f0
    lw $t0, 16($sp)
    mtc1 $t0, $f1
    lw $t0, 20($sp)
    mtc1 $t0, $f2

    addi $sp, $sp, 24  # Deallocate stack space
    jr $ra  # Return to caller

# ___________________________________________________________________________________________
write_float:
    # write float value stored in f0 to file
    # Use: a0, a1, a2, v0, t0, t1, t2, t3, t4, f0, f1
    # Store registers
    subi $sp, $sp, 44
    sw $a0, 40($sp)
    sw $a1, 36($sp)
    sw $a2, 32($sp)
    sw $v0, 28($sp)
    sw $t0, 24($sp)
    sw $t1, 20($sp)
    sw $t2, 16($sp)
    sw $t3, 12($sp)
    sw $t4, 8($sp)
    mfc1 $t0, $f0
    sw $t0, 4($sp)
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
    li $v0, 15
    lw $a0, descriptor
    move $a0, $s6
    la $a1, buffer
    add $a2, $zero, $t0
    syscall
    
    # Restore registers
    lw $t0, 0($sp)
    mtc1 $t0, $f1
    lw $t0, 4($sp)
    mtc1 $t0, $f0
    lw $t4, 8($sp)
    lw $t3, 12($sp)
    lw $t2, 16($sp)
    lw $t1, 20($sp)
    lw $t0, 24($sp)
    lw $v0, 28($sp)
    lw $a2, 32($sp)
    lw $a1, 36($sp)
    lw $a0, 40($sp)
    addi $sp, $sp, 44
    jr $ra
# ___________________________________________________________________________________________