# Name:		Permutation Calculations
# Description:	This function will calculate the two Permutations equations
#		Permutations with Replacement: n^k
#		Permutations without Replacement: n! / (n - k)! 
# Author(s):	Michael Sullivan; Nicholas Smith
# Date:		11.13.2017

.data

pwr:	.asciiz "Permutations with replacement\n"
pwor:	.asciiz	"Permutations without replacement\n"

.text

.globl Permutations
	
Permutations:
	
	li	$s0,	1	#initial value of $s0
	
	#DEBUG DUMMY VALUES	
	#li	$t1,	5	# n
	#li	$t2,	3	# k
	#li 	$s1,	3	#permutations w/ Replacement
	#li	$s1,	4 	#permutations w/o Replacement
	
	# Branch to Proper Equation
	beq	$s1,	3,	PermutationWithReplacement
	j	PermutationWithoutReplacement

PermutationWithReplacement:

	# Print Selection Message
	la	$a0,	pwr
	li	$v0,	4
	syscall

permutationWithReplacement_loop:	# Calculate: n^k

	beq	$t2, 0, permutationsPrintResults
	mult	$s0, $t1
	mflo	$s0
	subi	$t2, $t2, 1
	j	permutationWithReplacement_loop
 
PermutationWithoutReplacement:	
	# Notes:
	# n!/(n-k)! = n*(n-1)*(n-2)*...*(k+1) since n >= k
	# take n reducing by 1 each time until n = k

	# Print Selection Message
	la	$a0,	pwor
	li	$v0,	4
	syscall

permutationWithoutReplacement_loop:	# Calculate n! / (n - k)!

	blt 	$t1, 	$t2,	permutationsPrintResults	# if n = k then exit loop
	mult	$s0,	$t1
	mflo	$s0				
	subi	$t1,	$t1,	1
	j 	permutationWithoutReplacement_loop	
		
permutationsPrintResults:	# Output the results of the calculation
		
	add	$a0,	$s0,	$zero
	li	$v0,	1	
	syscall
	jr	$ra	# Jump back to main program. 	
