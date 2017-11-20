# Name:		Binomial Probability Density Function Calculations
# Description:	This function will calculate the binomial probability density function for certian input parameters. 
#		Binomial PDF Equation: (n! / (x! (n - x)!)) * p^x * (1 - p)^(n - x)
# Author(s):	Michael Sullivan; Nicholas Smith
# Date:		11.15.2017

.data

bpdf:	.asciiz	"Binomial Probabilty Density Fucntion\n"

prompt_numberOfTrials:			.asciiz "Please enter the total number of trials: "
prompt_numberOfSuccesses:		.asciiz "Please enter the number of successful trials sought: "
prompt_probabiltySuccess:		.asciiz "Please enter the probabilty of success: "

input_numberOfTrials:			.word	0
input_numberOfSuccesses:		.word	0
input_probabilityOfSuccess:		.double	0.0
combans:				.word   0

.text

.globl Binomial
	
Binomial:

	add	$s7,	$ra,	$zero	#save address for loop back
	
	# 1st part is get value of (n! / (x! (n - x)!))
	
	#DEBUG DUMMY VALUES
	#li	$s0,	1	#initial value of $s0
	#li	$t1,	5	# n
	#li	$t2,	3	# k

	#Prompt for number of trials
	li	$v0, 4
	la	$a0, prompt_numberOfTrials
	syscall
	
	li	$v0, 5
	syscall
	add	$t0, $zero, $v0
	sw	$t0, input_numberOfTrials
	
	#Prompt for probability
	li	$v0, 4
	la	$a0, prompt_probabiltySuccess
	syscall
	
	li	$v0, 7
	syscall
	mov.d	$f2, $f0
	swc1	$f2, input_probabilityOfSuccess
	
	#Prompt for probability to calculate
	li	$v0, 4
	la	$a0, prompt_numberOfSuccesses
	syscall
	
	li	$v0, 5
	syscall
	add	$t2, $zero, $v0
	sw	$t2, input_numberOfSuccesses
	
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
	
	mov.d	$f12,	$f16
	
	# go back to main menu
	# load back the original address
	li	$v0,	3	
		syscall
	jr	$s7
	
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
	lw	$t1, input_numberOfTrials
	lw	$t2, input_numberOfSuccesses
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
