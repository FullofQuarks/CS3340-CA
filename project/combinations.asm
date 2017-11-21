# Name:		Combinations Calculations
# Description:	This function will calculate the two Combinations equations
#		Combinations with Replacement: (k + n - 1)!/(k!(n-1)!)
#		Combinations without Replacement: n!/ k!(n-k)! 
# Author(s):	Michael Sullivan; Nicholas Smith
# Date:		11.13.2017

.data

cwor:	.asciiz	"\nCombinations without replacement\n"
cwr:	.asciiz "\nCombinations with replacement\n"

.text

.globl Combinations
	
Combinations:
	
	#DEBUG DUMMY VALUES
	li	$s0,	1	#initial value of $s0
	li	$t1,	6	# n
	li	$t2,	2	# k
	#li 	$s1,	1	#combinations w/ Replacement
	li	$s1,	2 	#combinations w/o Replacement
	
	# Branch to Proper Equation
	beq	$s1,	1,	CombinationWithReplacement
	j	CombinationWithoutReplacement

CombinationWithReplacement: 
	# Notes:
	# (k + n - 1)!/(k!(n-1)!) = {(k+n-1)*(k+n-2)*(k+n-3)*...*n}/k! since n >= k 
	# take (k + n - 1) reducing by 1 each time until (k + n - 1 - x) = (n - 1)
	# then divide everything by k!

	# Print Selection Message
	la	$a0,	cwr
	li	$v0,	4
	syscall
	
	# Setup proper values fo $t4 and $t5
	subi	$t5,	$t1, 1		# n - 1
	add	$t4,	$t2,	$t5	# k + n - 1 
	
combinationWithReplacement_loop:	# Calculate: (k + n - 1)! / (n - 1)!

	beq	$t4, $t5, divideByKFactorial_prep
	mult	$s0, $t4
	mflo	$s0
	subi	$t4, $t4, 1
	j	combinationWithReplacement_loop
 
CombinationWithoutReplacement:	
	# Notes:
	# n!/ k!(n-k)! = n*(n-1)*(n-2)*...*(k+1) since n >= k
	# take n reducing by 1 each time until n = k
	# then divide everything by k!

	# Print Selection Message
	la	$a0,	cwor
	li	$v0,	4
	syscall
	
	sub	$t3,	$t1,	$t2
	
combinationWithoutReplacement_loop:	# Calculate n! / (n - k)!

	beq 	$t1, 	$t3,	divideByKFactorial_prep	# if n = k then exit loop
	mult	$s0,	$t1
	mflo	$s0				
	subi	$t1,	$t1,	1
	j 	combinationWithoutReplacement_loop	
	                            
divideByKFactorial_prep:		# Preparation for division
	
	#DEBUG
	#add	$a0,	$s0,	$zero
	#li	$v0,	1
	#syscall
	
	mtc1.d	$s0,	$f12	# Move numerator into f0 register for float processing 
	cvt.d.w	$f12,	$f12	# Convert to double float
		
	mtc1.d	$t2,	$f2	# Move k into f2 for float processing
	cvt.d.w	$f2,	$f2	# Convert to double float
		
	li	$t7,	1	# Load value of 1 into register
	mtc1.d	$t7,	$f4	# Move into f4 register for float processing
	cvt.d.w	$f4,	$f4	# Convert to double float
		
divideByKFactorial_loop: # Loop for calculation

	beq	$t2,	0,	combinationsPrintResults
	div.d	$f12,	$f12,	$f2	# Divide numerator by denominator
	sub.d	$f2,	$f2,	$f4	# Subtract k by 1
	subi	$t2,	$t2,	1	# Subtract index by 1 - This makes is easier for the comparison
	j	divideByKFactorial_loop
		
combinationsPrintResults:	# Output the results of the calculation
		
	li	$v0,	3	
	syscall
	jr	$ra	# Jump back to main program. 
