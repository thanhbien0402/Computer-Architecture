.data
string:      .space 101                 # Reserve space for the input string
stringSize:  .word 100                  # Maximum size of the string
prompt:      .asciiz "The input string: " # Prompt for user input
output:      .asciiz "\nOutput: "      # Output label
colon_space: .asciiz ", "               # Formatting text
semicolon_space: .asciiz "; "           # Semicolon and space separator

# Array to store counts of each ASCII character (128 possible characters)
char_count:  .space 128                 # One byte per character (0-127 ASCII)

.text
main:
    # Prompt for the string input
    li $v0, 4
    la $a0, prompt
    syscall

    # Read the string from the user
    li $v0, 8
    la $a0, string
    lw $a1, stringSize
    syscall

    # Initialize the character count array to zero
    la $t0, char_count
    li $t1, 128                        # Total ASCII characters
init_loop:
    sb $zero, 0($t0)                   # Set each byte in char_count to 0
    addiu $t0, $t0, 1
    addiu $t1, $t1, -1
    bnez $t1, init_loop

    # Count occurrences of each alphabetic character in the string
    la $t0, string                     # Address of the input string
count_loop:
    lb $t1, 0($t0)                     # Load each character byte-by-byte
    beq $t1, 0, display_results        # End of string (null terminator)

    # Check if character is within 'A' to 'Z' or 'a' to 'z'
    li $t2, 65                         # ASCII for 'A'
    li $t3, 90                         # ASCII for 'Z'
    li $t4, 97                         # ASCII for 'a'
    li $t5, 122                        # ASCII for 'z'
    blt $t1, $t2, skip_char            # If character < 'A', skip
    bgt $t1, $t5, skip_char            # If character > 'z', skip
    bgt $t1, $t3, check_lowercase      # If character > 'Z', check lowercase
    j count_valid_char                 # Character is uppercase, count it

check_lowercase:
    blt $t1, $t4, skip_char            # If character < 'a', skip

count_valid_char:
    la $t6, char_count                 # Address of char_count array
    add $t6, $t6, $t1                  # Offset by ASCII value of character
    lb $t7, 0($t6)                     # Load current count
    addiu $t7, $t7, 1                  # Increment count
    sb $t7, 0($t6)                     # Store the updated count

skip_char:
    addiu $t0, $t0, 1                  # Move to the next character
    j count_loop

display_results:
    # Print output label
    li $v0, 4
    la $a0, output
    syscall

    # Print each character and its count if it appeared at least once
    li $t0, 65                         # Start from 'A'
    li $t4, 0                          # Counter to track if output started

print_loop:
    lb $t1, char_count($t0)            # Load count of character at index
    beqz $t1, check_next               # Skip if count is zero

    # Only print "; " separator if this is not the first character
    bnez $t4, print_separator
    li $t4, 1                          # Mark that output has started

    # Print the character
    li $v0, 11
    move $a0, $t0                      # ASCII code of the character
    syscall

    # Print ": "
    li $v0, 4
    la $a0, colon_space
    syscall

    # Print the count as integer
    li $v0, 1
    move $a0, $t1                      # Character count
    syscall

    j check_next                       # Skip separator on last item

print_separator:
    # Print "; " separator between entries
    li $v0, 4
    la $a0, semicolon_space
    syscall

    # Print the character after separator
    li $v0, 11
    move $a0, $t0                      # ASCII code of the character
    syscall

    # Print ": "
    li $v0, 4
    la $a0, colon_space
    syscall

    # Print the count as integer
    li $v0, 1
    move $a0, $t1                      # Character count
    syscall

check_next:
    addiu $t0, $t0, 1                  # Move to the next character in ASCII
    li $t2, 122                        # End with lowercase 'z'
    blt $t0, $t2, print_loop           # Continue if within range

    # Exit the program
    li $v0, 10
    syscall
