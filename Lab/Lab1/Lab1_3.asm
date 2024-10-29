	.data
a: .asciiz "Insert a: "          
b: .asciiz "Insert b: "          
c: .asciiz "Insert c: "           
d: .asciiz "Insert d: "          
F: .asciiz "F = "                 
remainder: .asciiz ", remainder = "      
newline: .asciiz "\n"                  
error_case: .asciiz "Error: Division by zero!\n"

	# Main body
	.text
main:
    	li      $v0, 4                  
    	la      $a0, a            
    	syscall                        

    	# Read a
    	li      $v0, 5                 
    	syscall                       
    	move    $t0, $v0            

    	# Prompt for b
    	li      $v0, 4          
    	la      $a0, b             
    	syscall                            

    	# Read b
    	li      $v0, 5                    
    	syscall                            
    	move    $t1, $v0                   

    	# Prompt for c
    	li      $v0, 4                     
    	la      $a0, c              
    	syscall                            

    	# Read c
    	li      $v0, 5                     
    	syscall                            
    	move    $t2, $v0                   

    	# Prompt for d
    	li      $v0, 4                     
    	la      $a0, d              
    	syscall                            

    	# Read d
    	li      $v0, 5                    
    	syscall                            
    	move    $t3, $v0                  



    	# Compute (a - 10)
    	li      $t4, 10                    
    	sub     $t4, $t0, $t4              
    	# Compute (b + d)
    	add     $t5, $t1, $t3             

    	# Compute (c - 2 * a)
    	li      $t6, 2                    
    	mul     $t6, $t6, $t0    
    	sub     $t6, $t2, $t6

    	# Multiply (a - 10) * (b + d)
    	mul     $t7, $t4, $t5         

    	# Multiply the result by (c - 2 * a)
    	mul     $t7, $t7, $t6             

    	# Compute (a + b + c)
    	add     $t8, $t0, $t1        
    	add     $t8, $t8, $t2            

    	beq     $t8, $zero, div_by_zero   

    	div     $t7, $t8               

    	mflo    $t9                        
    	mfhi    $s0                

    	# Print "F = "
    	li      $v0, 4          
    	la      $a0, F                
    	syscall     

    	# Print the quotient (F)
    	move    $a0, $t9           
    	li      $v0, 1                     
    	syscall                        

    	# Print ", remainder = "
    	li      $v0, 4                
    	la      $a0, remainder          
    	syscall                  
	
    	# Print the remainder
    	move    $a0, $s0                 
    	li      $v0, 1             
    	syscall                   

    	# Print newline
    	li      $v0, 4                   
    	la      $a0, newline      
    	syscall          

    	li      $v0, 10            
    	syscall

div_by_zero:
    	li      $v0, 4                 
    	la      $a0, error_case     
    	syscall                         

    	# Exit the program
    	li      $v0, 10                
    	syscall
