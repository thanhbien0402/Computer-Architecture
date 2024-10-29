	.data
a: .asciiz "Insert a: "       
HEHE:
b: .asciiz "Insert b: "      
result_add: .asciiz "a + b = "         
result_sub: .asciiz "a - b = "        
newline: .asciiz "\n"               

	.text
main:
	li	$v0, 4
    	la      $a0, a              
    	jal	HEHE
    	syscall                            
	
   
    	li      $v0, 5                     	
    	syscall                            
    	move    $t0, $v0                   

    	
    	li      $v0, 4                    
    	la      $a0, b              
    	syscall                            

	
    	li      $v0, 5                     
    	syscall                            
    	move    $t1, $v0                  

    	# Calculate a + b
    	add     $t2, $t0, $t1              # t2 = a + b

   	# Print "a + b = "
    	li      $v0, 4                     
    	la      $a0, result_add          
    	syscall                            

    	# Print result of a + b
    	move    $a0, $t2                   
    	li      $v0, 1                  
    	syscall                          

    	# Print newline
    	li      $v0, 4              
    	la      $a0, newline  
    	syscall      

    	# Calculate a - b
    	sub     $t3, $t0, $t1              # t3 = a - b

    	# Print "a - b = "
    	li      $v0, 4     
    	la      $a0, result_sub 
    	syscall 

    	# Print result of a - b
    	move    $a0, $t3 
    	li      $v0, 1 
    	syscall

    	# Print newline
    	li      $v0, 4 
    	la      $a0, newline
    	syscall                    

    	# Exit the program
    	li      $v0, 10             
    	syscall
