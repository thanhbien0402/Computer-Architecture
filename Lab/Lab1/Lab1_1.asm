	.data
input: .asciiz "Enter your name: "
greeting: .asciiz "Hello, "
endline: .asciiz ".\n"
name: .space 20         # Allocate 20 bytes for name

	.text
main:
    	li  	$v0, 4          # Print string
    	la  	$a0, input
    	syscall

    	li  	$v0, 8          # Read string
    	la  	$a0, name
    	li  	$a1, 20
    	syscall

    	# Remove the newline character from the input
    	la  	$t0, name       # Load address of name into $t0
    	li  	$t1, 0          # Initialize counter to 0

find_length:
    	lb  	$t2, 0($t0)     # Load byte from the string
    	beqz	$t2, end_find   # If we reach the null terminator, end the loop
    	addi 	$t1, $t1, 1     # Increment the counter
    	addi 	$t0, $t0, 1     # Move to the next character
    	j find_length        # Repeat the loop

end_find:
    	addi 	$t0, $t0, -1    # Point to the last character
    	lb  	$t2, 0($t0)      # Load the last character
    	li  	$t3, 10          # Load newline character in $t3
    	beq 	$t2, $t3, remove_newline  # If it is a newline, remove it

    	j 	print_greeting      # Jump to print greeting if no newline found

remove_newline:
    	sb  	$zero, 0($t0)    # Replace newline with null terminator

print_greeting:
    	li  	$v0, 4           
    	la  	$a0, greeting
    	syscall

    	li  	$v0, 4           
    	la  	$a0, name
    	syscall

    	li  	$v0, 4          
    	la  	$a0, endline
    	syscall

    	li  	$v0, 10        
    	syscall
