.data
    array: .word 0:7           # Array to store 7 integers
    size: .word 7             # Size of the array
    prompt: .asciiz "Please insert a element: "
    original: .asciiz "The original array is: "
    sorted: .asciiz "The sorted array is: "
    building: .asciiz "Building max heap: "
    comma: .asciiz ", "
    newline: .asciiz "\n"

.text
.globl main

main:
    # Initialize variables
    la $s0, array            # $s0 = base address of array
    li $s1, 0               # $s1 = counter for input loop
    
    # Input Loop
    input_loop:
        # Print prompt
        li $v0, 4
        la $a0, prompt
        syscall
        
        # Read integer
        li $v0, 5
        syscall
        
        # Store in array
        sw $v0, ($s0)
        
        # Increment counter and array pointer
        addi $s1, $s1, 1
        addi $s0, $s0, 4
        
        # Check if we've got 7 numbers
        bne $s1, 7, input_loop
        
    # Print original array
    la $a0, original
    jal print_message
    la $a0, array
    li $a1, 7
    jal print_array
    
    # Heapsort
    la $a0, array           # Array address
    li $a1, 7              # Array size
    jal heapsort
    
    # Print sorted array
    la $a0, sorted
    jal print_message
    la $a0, array
    li $a1, 7
    jal print_array
    
    # Exit program
    li $v0, 10
    syscall

# Heapsort procedure
heapsort:
    # Save registers
    addi $sp, $sp, -20
    sw $ra, 16($sp)
    sw $s0, 12($sp)
    sw $s1, 8($sp)
    sw $s2, 4($sp)
    sw $s3, 0($sp)
    
    move $s0, $a0           # Array address
    move $s1, $a1           # Array size
    
    # Build max heap
    move $s2, $s1
    srl $s3, $s1, 1        # size/2
    sub $s3, $s3, 1        # (size/2)-1
    
    build_heap:
        move $a0, $s0       # Array address
        move $a1, $s2       # Current size
        move $a2, $s3       # Current root
        jal heapify
        
        addi $s3, $s3, -1
        bgez $s3, build_heap

    # Print max heap state
    la $a0, building
    jal print_message
    move $a0, $s0
    move $a1, $s1
    jal print_array

    # Extract elements from heap
    addi $s2, $s1, -1        # size-1
    
    extract_loop:
        # Swap first and last
        lw $t0, ($s0)
        mul $t1, $s2, 4
        add $t1, $t1, $s0
        lw $t2, ($t1)
        sw $t2, ($s0)
        sw $t0, ($t1)
        
        # Heapify reduced heap
        move $a0, $s0
        move $a1, $s2
        li $a2, 0
        jal heapify
        
        # Print current state
        la $a0, building
        jal print_message
        move $a0, $s0
        move $a1, $s1
        jal print_array
        
        addi $s2, $s2, -1
        bgtz $s2, extract_loop
    
    # Restore registers
    lw $ra, 16($sp)
    lw $s0, 12($sp)
    lw $s1, 8($sp)
    lw $s2, 4($sp)
    lw $s3, 0($sp)
    addi $sp, $sp, 20
    jr $ra

# Heapify procedure
heapify:
    # Save registers
    addi $sp, $sp, -16
    sw $ra, 12($sp)
    sw $s0, 8($sp)
    sw $s1, 4($sp)
    sw $s2, 0($sp)
    
    move $s0, $a0           # Array address
    move $s1, $a1           # Heap size
    move $s2, $a2           # Root index
    
    # Calculate children
    mul $t0, $s2, 2
    addi $t0, $t0, 1       # Left child
    addi $t1, $t0, 1       # Right child
    
    # Find largest
    move $t2, $s2          # Largest = root
    
    # Compare with left child
    bge $t0, $s1, right_child
    mul $t3, $t2, 4
    add $t3, $t3, $s0
    lw $t3, ($t3)          # Value at largest
    mul $t4, $t0, 4
    add $t4, $t4, $s0
    lw $t4, ($t4)          # Value at left child
    bge $t3, $t4, right_child
    move $t2, $t0          # Largest = left child
    
right_child:
    # Compare with right child
    bge $t1, $s1, check_swap
    mul $t3, $t2, 4
    add $t3, $t3, $s0
    lw $t3, ($t3)          # Value at largest
    mul $t4, $t1, 4
    add $t4, $t4, $s0
    lw $t4, ($t4)          # Value at right child
    bge $t3, $t4, check_swap
    move $t2, $t1          # Largest = right child
    
check_swap:
    # If largest is not root
    beq $t2, $s2, heapify_end
    
    # Swap
    mul $t3, $s2, 4
    add $t3, $t3, $s0
    mul $t4, $t2, 4
    add $t4, $t4, $s0
    lw $t5, ($t3)
    lw $t6, ($t4)
    sw $t6, ($t3)
    sw $t5, ($t4)
    
    # Recursively heapify
    move $a0, $s0
    move $a1, $s1
    move $a2, $t2
    jal heapify
    
heapify_end:
    # Restore registers
    lw $ra, 12($sp)
    lw $s0, 8($sp)
    lw $s1, 4($sp)
    lw $s2, 0($sp)
    addi $sp, $sp, 16
    jr $ra

# Print message procedure
print_message:
    li $v0, 4
    syscall
    jr $ra

# Print array procedure
print_array:
    # Save registers
    addi $sp, $sp, -16
    sw $ra, 12($sp)
    sw $s0, 8($sp)
    sw $s1, 4($sp)
    sw $s2, 0($sp)
    
    move $s0, $a0           # Array address
    move $s1, $a1           # Array size
    li $s2, 0              # Counter
    
print_loop:
    # Print number
    li $v0, 1
    lw $a0, ($s0)
    syscall
    
    # Print comma unless last element
    addi $s2, $s2, 1
    beq $s2, $s1, print_end
    li $v0, 4
    la $a0, comma
    syscall
    
    # Move to next element
    addi $s0, $s0, 4
    j print_loop
    
print_end:
    # Print newline
    li $v0, 4
    la $a0, newline
    syscall
    
    # Restore registers
    lw $ra, 12($sp)
    lw $s0, 8($sp)
    lw $s1, 4($sp)
    lw $s2, 0($sp)
    addi $sp, $sp, 16
    jr $ra
