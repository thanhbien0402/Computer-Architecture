.data
promptA: .asciiz "Enter the first positive integer a = "
promptB: .asciiz "Enter the second positive integer b = "
result_gcd: .asciiz "The greatest common divisor GCD = "
result_lcm: .asciiz "The lowest common multiple LCM = "
endl: .asciiz "\n"
error: .asciiz "Invalid input. Please enter a positive number!\n"

.text 
inputA:
	# Print promptA 
	li $v0, 4
	la $a0, promptA
	syscall
	
	# get input for a
	li $v0, 5 		# read_int
	syscall
	move $s0, $v0		# a = $s0, $s0-$s7: dung de luu tru cac bien du lieu
	
	# Check if a is positive or not
	blt $s0, 1, errorA 	# if a < 1, j main and get another a #Branch if less than zero
inputB:	
	# print endl
	li $v0, 4
	la $a0, endl
	syscall
	# Print promptB 
	li $v0, 4
	la $a0, promptB
	syscall
	
	#get input for b
	li $v0, 5 		#read_int
	syscall
	move $s1, $v0 		# b = $s1
	
	# Check if b is positive or not using btlz (Branch if less than zero)
	blt $s1, 1, errorB 	# if b < 1, j main and get another a 

#printGCD
	# print endl
	li $v0, 4
	la $a0, endl
	syscall	
	#print result_gcd
	li $v0, 4		#print string
	la $a0, result_gcd	
	syscall
	
	#store a, b 
	move $a0, $s0	#add $a0, $s0, $zero	# add $a0=$s0+0 <=> $a0=a
	move $a1, $s1	#add $a1, $s1, $zero 	# add $a1=$s1+0 <=> $a1=b	
					
	jal gcdCal
	
	add $t0, $v0, $zero	#store GCD result in $t0
	
	#display gcd	
	move $a0, $t0		# move gcd result in $a0 to display
	li $v0, 1		#print integer
	syscall 
	
	# print endl
	li $v0, 4
	la $a0, endl
	syscall
	
#printLCM
	# print endl
	li $v0, 4
	la $a0, endl
	syscall
	#print result_lcm
	li $v0, 4
	la $a0, result_lcm
	syscall
	
	#store a, b 
	add $a0, $s0, $zero	# add $a0=$s0+0 <=> $a0=a
	add $a1, $s1, $zero 	# add $a1=$s1+0 <=> $a1=b	
					
	jal lcmCal
	
	move $t0, $v0	#add $t0, $v0, $zero 	#store lcm in $t0
	
	#display lcm	
	move $a0, $t0		# move lcm result in $a0 to display
	li $v0, 1		#print integer
	syscall
	
	j exit
#################### gcd function ##################################################
gcdCal:		
	move $t0, $a0	#add $t0, $a0, $zero	# $t0=a
	move $t1, $a1	#add $t1, $a1, $zero 	# $t1=b	
					
	beq $t1, $zero, GCDequalA 	#if b = 0, GCD = a
	move $t2, $t1	#add $t2, $t1, $zero	# $t2 (new a) = b
	div $t0, $t1		# a / b
	mfhi $a1 		# set b = a % b 
	move $a0, $t2		# set a = $t2
	j gcdCal		# return gcd(a, b) with a = b, b = a % b

return:      # trở về main
	jr $ra

GCDequalA:
	# Display gcd = a 
	move $v0, $t0
	j return

################## lcm function	##################################################
lcmCal:		
	addi $sp, $sp, -4   # tạo stack 
	sw $ra, 0($sp)   # lưu trả về của lcm

	move $t4, $a0	#add $t4, $a0, $zero   # lưu đối số
	move $t5, $a1	#add $t5, $a1, $zero

	move $a0, $t4	#add $a0, $t4, $zero   # lưu n1 vào đối số thứ nhất cho gcd
	move $a1, $t5	#add $a1, $t5, $zero   # lưu n2 vào đối số thứ hai cho gcd
	jal gcdCal 
	move $t0, $v0   #add $t0, $v0, $zero

	mult $t4, $t5      # nhân n1 và n2
	mflo $t3

	div $t3, $t0       # phép chia cuối cùng
	mflo $v0

	lw $ra, 0($sp)   # nạp lại $ra
	addi $sp, $sp, 4   # giải phóng stack

	jr $ra      # trở lại lời gọi của lcm

exit:
	li $v0, 10	# Exit program	
	syscall

errorA:
	# Print error 
	li $v0, 4
	la $a0, error
	syscall	
	j inputA
errorB:
	# Print error 
	li $v0, 4
	la $a0, error
	syscall	
	j inputB