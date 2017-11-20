                .data
prompt_eq:	.asciiz "Select an equation by entering the number below:\n"
#p2:       .asciiz "Menu Options:\n"
choice_1:	.asciiz    "1) Combinations without replacement\n"
choice_2:	.asciiz "2) Combinations with replacement\n"
choice_3:	.asciiz "3) Permutations without replacement\n"
choice_4:	.asciiz "4) Combinations with replacement\n"
choice_5:	.asciiz "5) Binomial PDF\n"
choice_error:	.asciiz "You did not enter any of the given choices! Try again.\n\n"
choice_exit:	.asciiz "0) Exit\n"
choice_prompt:	.asciiz "\nEnter your choice: "
prompt_n:	.asciiz "Please enter a n value at or below 10: "
prompt_k:	.asciiz "Please enter a k value at or below 10: "
prompt_nk_over:	.asciiz "That value is over 10! Going back to menu.\n"
comb3:		.asciiz "\nThe combination answer is: "
input_n:	.word    0
input_k:	.word    0
choice:		.word    0
combans:	.word    0

# Binomial Function Variables
prompt_num:	.asciiz "Please enter the number of trials: "
prompt_pro:	.asciiz "Please enter the probability of each trial: "
prompt_success:	.asciiz "Please enter the probability to calculate: "
trials:		.word 0
tprobability:	.double 0
float_start:	.double 1.0
zero:		.double 0
calculate:	.word 0

                .text
	
menu:	la	$a0, prompt_eq
	li	$v0, 4
	syscall
	
	la	$a0, choice_1
	li	$v0, 4
	syscall
	
	la	$a0, choice_2
	li	$v0, 4
	syscall
	
	la	$a0, choice_3
	li	$v0, 4
	syscall
	
	la	$a0, choice_4
	li	$v0, 4
	syscall
	
	la	$a0, choice_5
	li	$v0, 4
	syscall
	
	la	$a0, choice_exit
	li	$v0, 4
	syscall
	
	#Prompt for input
	la	$a0, choice_prompt
	li	$v0, 4
	syscall
	
	li	$v0, 5
	syscall
	
	add	$t3, $zero, $v0
	
	#First check if the user is trying to exit
	beq	$t3, 0, exit
	
	# Next check if the user is trying to run a function that
	# doesn't need n or k
	beq	$t3, 5, binomial
	
	#Prompt for n
	la	$a0, prompt_n
	li	$v0, 4
	syscall
	
	li	$v0, 5
	syscall	#If the user doesn't enter an integer, the error will occur here!
	sw	$v0, input_n
	sge	$t0, $v0, 11  #error checking if n is over 10
	beq	$t0, 1, nk_over
	
	#Prompt for k
	la	$a0, prompt_k
	li	$v0, 4
	syscall
	
	li	$v0, 5
	syscall
	sw	$v0, input_k
	sge	$t0, $v0, 11  #error checking if k is over 10
	beq	$t0, 1, nk_over

	beq	$t3, 1, combination_wo_replacement_loop_numerator
	beq	$t3, 2, combination_w_replacement_loop
	beq	$t3, 3, permutation_wo_replacement_loop
	beq	$t3, 4, permutation_w_replacement_loop
	
	#If the user didn't choose anything listed.
	la	$a0, choice_error
	li	$v0, 4
	syscall
	j	menu
        
        #If the user entered n or k greater than 10
nk_over:
	la	$a0, prompt_nk_over
	li	$v0, 4
	syscall
	j	menu
                #####if n = k output 1
                
                # load the values of n &k, we only have to do this once no matter what the equation is. will cut back on lines. 
                lw	$t1, input_n                                
                lw	$t2, input_k

permutation_w_replacement_loop:
                # Calculate the combination
                # Equation: (k + n - 1)!/(k!(n-1)!)
                # (k + n - 1)!/(k!(n-1)!) = {(k+n-1)*(k+n-2)*(k+n-3)*...*n}/k! since n >= k 
                # look for t so that  k - t = n
                # take (k + n - 1) reducing by 1 each time until (k + n - 1 - x) = (n - 1)
                # then divide everything by k!
                
                # let t4 = k + n - 1
                #let $t5 = n - 1
                beq	$t4, $t5, permutation_w_replacement_loop
                multu	$s0, $t4
                mflo	$s0
                subiu	$t4, $t4, 1
                j	permutation_w_replacement_loop

combination_w_replacement_loop: #need to find cap in 32 unsigned for n & k
                # Calculate the permutataion
                # Equation: n^k
                beq	$t2, 0, output_result
                multu	$t1, $t1
                subiu	$t2, $t2, 1
                j	combination_w_replacement_loop

permutation_wo_replacement_loop:     
                # Calculation the permutation loop
                # Equation: n!/(n-k)!
                # n!/(n-k)! = n*(n-1)*(n-2)*...*(k+1) since n >= k 
                
                beq	$t1, $t2, output_result    # if n = k then exit loop
                multu	$s0, $t1
                #multu $s1,        $t1          #since we are checking the t value prior to the calculation we can safely guarentee that the hi register doesnt overflow
                mflo	$s0                         
                #mfhi    $s1                         
                subiu	$t1, $t1, 1
                j	permutation_wo_replacement_loop

combination_wo_replacement_loop_numerator:             
                # Calculation the numerator of the combination loop
                # Equation: n!/(n-k)!
                # n!/(n-k)! = n*(n-1)*(n-2)*...*(k+1) since n >= k 
                
                beq	$t1, $t2, combination_wo_replacement_loop_divide        # if n = k then exit loop
                multu	$s0, $t1
                #multu $s1,        $t1          #since we are checking the t value prior to the calculation we can safely guarentee that the hi register doesnt overflow
                mflo	$s0                         
                #mfhi    $s1                         
                subi	$t1, $t1, 1
                j	combination_wo_replacement_loop_numerator

combination_wo_replacement_loop_divide:       
                # Calculation of the combination loop
                # Equation: n!/(k!(n-k)!)
                # repeat permutation loop to get numerator of equation; Then loop through a k factorial divide.
                
                beq	$t2, 0, output_result    # if n = k then exit loop
                divu	$s0, $t2          #refresh on division - floating points?
                #divu     $s1,        $t2          #since we are checking the t value prior to the calculation we can safely guarentee that the hi register doesnt overflow        
                subi	$t2, $t2, 1
                j	combination_wo_replacement_loop_divide

output_result:
	j	menu

binomial:
#Prompt for number of trials
	li	$v0, 4
	la	$a0, prompt_num
	syscall
	
	li	$v0, 5
	syscall
	add	$t0, $zero, $v0
	sw	$t0, trials
	
	#Prompt for probability
	li	$v0, 4
	la	$a0, prompt_pro
	syscall
	
	li	$v0, 7
	syscall
	mov.d	$f2, $f0
	swc1	$f2, tprobability
	
	#Prompt for probability to calculate
	li	$v0, 4
	la	$a0, prompt_success
	syscall
	
	li	$v0, 5
	syscall
	add	$t2, $zero, $v0
	sw	$t2, calculate
	
	# Begin function: tprobability^(successes)
	# t0 = number of trials
	# t1 = temporary double integral value
	# f2 = tprobability, probability of a trial being a success
	# f4 = probability number to calculate, moved to coproc1
	# t2 = Probability number to calculate
	# t3 = loop counter
	
	# s0 = first part result
	# f8 = temp result
	# f10 = pi^(probability to calculate)
	# f12 = (1-pi)^(trials - probability to calculate)
	# f14 = combination answer
	# f16 = s1 * s2 * s3
	jal	power
	mov.d	$f10, $f8
	sub	$t2, $t0, $t2
	li	$t1, 1
	mtc1.d	$t1, $f0
	cvt.d.w	$f0, $f0
	sub.d	$f2, $f0, $f2
	jal	power
	mov.d	$f12, $f8
	add	$s2, $zero, $s0
	jal	combinations
	mtc1.d	$s0, $f14
	cvt.d.w	$f14, $f14
	mul.d	$f16, $f10, $f12
	mul.d	$f16, $f16, $f14
	j	menu
	
power:
	addi	$sp, $sp, -4
	sw	$ra, ($sp)
	li	$t3, 0	#this is our counter
	li	$t1, 1	# we need to set f8 to 1 again
	mtc1.d	$t1, $f8 #move this double into coproc1
	cvt.d.w	$f8, $f8 #convert this to a double
	
power_loop:
	beq	$t2, $t3, power_loop_end
	mul.d	$f8, $f2, $f8
	addi	$t3, $t3, 1
	j	power_loop
	
power_loop_end:
	lw	$ra, ($sp)
	addi	$sp, $sp, 4
	jr	$ra
	
combinations:
	# n!/(k!(n-k)!)
	# Need n!, k!, and (n-k)!
	# $s1 = n! 
	# #s2 = k!
	# $s3 = (n-k)!
	# $s4 = k! * (n-k)!
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)
	lw	$t1, trials
	lw	$t2, calculate
	li	$t3, 1
	
	# Compute n-k
	sub	$s3, $t1, $t2
	
	# Run factorial for n
	jal	factorial
	add	$s1, $s0, $zero
	
	# Run factorial for k
	add	$t1, $t2, $zero
	jal	factorial
	add	$s2, $s0, $zero
	
	# Run factorial for (n-k)!
	add	$t1, $s3, $zero
	jal	factorial
	add	$s3, $s0, $zero
	
	# Compute n! * (n-k)!
	mult	$s2, $s3
	mflo	$s4
	
	# Compute n! / (n! * (n-k)!)
	div	$s1, $s4
	mflo	$s0
	
	#Let's save our answer
	sw	$s0, combans
	
	lw	$ra, ($sp)
	addi	$sp, $zero, 4
	jr	$ra
	
factorial:
	addi	$sp, $sp, -4
	sw	$ra, ($sp)
	li	$s0, 1
	beq	$t1, 0, factorial_zero
	
	# t1 = n
	# t3 = 1, loop ends
	# t4 = n - 1
	# t5 = mult holder
	# s0 = result holder
fstart:
	beq	$t1, $t3, fend	# is n == 1?
	mult	$s0, $t1
	mflo	$s0
	subi	$t1, $t1, 1
	j	fstart
	
	
fend:
	lw	$ra, ($sp)
	addi	$sp, $sp, 4
	jr	$ra
factorial_zero:
	addi	$t1, $zero, 1
	lw	$ra, ($sp)
	addi	$sp, $sp, 4
	jr	$ra

exit:
	li	$v0, 10
	syscall

# Trap handler in the standard MIPS32 kernel text segment
	.ktext 0x80000180
	move $k0,$v0   # Save $v0 value
	move $k1,$a0   # Save $a0 value
	la   $a0, msg  # address of string to print
	li   $v0, 4    # Print String service
	syscall
	move $v0,$k0   # Restore $v0
	move $a0,$k1   # Restore $a0
 	#mfc0 $k0,$14   # Coprocessor 0 register $14 has address of trapping instruction
	#addi $k0,$k0,88 # Add 88 (4*22 instructions) to point to next instruction
 	#mtc0 $k0,$14   # Store new address back into $14
 	la	$k0, menu
 	mtc0	$k0, $14
 	eret           # Error return; set PC to value in $14
	.kdata	
msg:	.asciiz "\nYou didn't even enter a number! "
