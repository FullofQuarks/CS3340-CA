# Name:		CS 3340 - Computer Architecture Project
# Description:	This program will calculate various Statistics equations:
#		Combinations with Replacement
#		Combinations without Replacement
#		Permutations with Replacement
#		Permutations without Replacement
#		Binomial Probability Density Function
# Author(s):	Michael Sullivan; Nicholas Smith
# Date:		11.19.2017
	
	.data 

prompt_equationSelection:		.asciiz "\nEnter your choice: "
prompt_n:				.asciiz "Please enter a n greater than or equal to 10: "
prompt_k:				.asciiz "Please enter a k greater than or equal to 10: "
prompt_numberOfTrials:			.asciiz "Please enter the total number of trials: "
prompt_numberOfSuccesses:		.asciiz "Please enter the number of successful trials sought: "
prompt_probabiltySuccess:		.asciiz "Please enter the probabilty of success: "

msg_equationSelection:			.asciiz "\nSelect an equation by entering the number fo the equation below:\n"
msg_combinationsWithReplacement:	.asciiz "1) Combinations with replacement\n"
msg_combinationsWithoutReplacement:	.asciiz "2) Combinations without replacement\n"
msg_permutationsWithReplacement:	.asciiz "3) Permutations with replacement\n"
msg_permutationsWithoutReplacement:	.asciiz "4) Permutations without replacement\n"
msg_binomialPDF:			.asciiz "5) Binomial PDF\n"
msg_exit:				.asciiz	"0) Exit\n\n"
msg_invalidSelection:			.asciiz "\nInvalid Entry!\n"
msg_error_overflow:			.asciiz "\nValue over 10. Please enter a value under 10\n"
msg_error_nLessThanK:			.asciiz "\nYou have selected a value of k that is greater than n. K must be less than or equal to n.\n"

input_equationSelection:		.word	0
input_n:				.word	0
input_k:				.word	0
input_numberOfTrials:			.word	0
input_numberOfSuccesses:		.word	0
input_probabilityOfSuccess:		.double	0.0

	.text

.globl main

main:
	#DEBUG DUMMY VALUES
	#li	$s0,	1	#initial value of $s0
	#li	$t1,	5	# n
	#li	$t2,	3	# k
	#li 	$s1,	1	#combinations w/ Replacement
	#li	$s1,	2 	#combinations w/o Replacement
	#li 	$s1,	3	#permutations w/ Replacement
	#li	$s1,	4 	#permutations w/o Replacement

displayMenu:	# Display menu options for each equation available and prompt for user input
	
	la	$a0,	msg_equationSelection	
	li	$v0,	4
	syscall
	
	la	$a0,	msg_combinationsWithReplacement
	li	$v0,	4
	syscall
	
	la	$a0,	msg_combinationsWithoutReplacement
	li	$v0,	4
	syscall
	
	la	$a0,	msg_permutationsWithReplacement
	li	$v0,	4
	syscall
	
	la	$a0,	msg_permutationsWithoutReplacement
	li	$v0,	4
	syscall
	
	la	$a0,	msg_binomialPDF
	li	$v0,	4
	syscall
	
	la	$a0,	msg_exit
	li	$v0,	4
	syscall

selectEquation:	# Ask for choice and process. 

	la	$a0, 	prompt_equationSelection	#Prompt for input
	li	$v0, 	4
	syscall
	
	li	$v0, 	5	# Get selection
	syscall	
	
	# integer check 1st - NICK we need to immediately check if the user input an invalid number here. 
	
	add	$s1,	$zero,	$v0		# Move selection to register $s1	
	
	beq	$s1,	0,	exit		# 1st check if the user is trying to exit
	beq	$s1,	5,	Binomial_prep	# Next check if the binomial equation is selected
	
selectCombinatorics_n:	#Prompt and save n value
	
	la	$a0, prompt_n
	li	$v0, 4
	syscall
	
	li	$v0, 5
	syscall			#If the user doesn't enter an integer, the error will occur here! - EXPLAIN please
	sw	$v0, input_n	# Store the input into input_n variable
	
	# If the input is greater than 10, then display error message; Else move on to k input
	blt	$v0,	11,	selectCombinatorics_k	
	la	$a0,	msg_error_overflow
	li	$v0,	4
	syscall
	j	selectCombinatorics_n

selectCombinatorics_k: #Prompt and save k value
	
	la	$a0, prompt_k
	li	$v0, 4
	syscall
	
	li	$v0, 5
	syscall
	sw	$v0, input_k
	
	# If the input is greater than 10, then display error message; Else move on to k > n check
	blt	$v0,	11,	compareCombinatoricValues	
	la	$a0,	msg_error_overflow
	li	$v0,	4
	syscall
	j	selectCombinatorics_k
	
compareCombinatoricValues: # Compare n and k values
	
	lw	$t1,	input_n
	lw	$t2,	input_k	
	
	beq	$t1,	$t2,	returnValueOfOne	#if n = k then return 1
	blt	$t2,	$t1,	Combinatorics_prep	# valid values of n & k, begin processing with these values		
	la	$a0,	msg_error_overflow
	li	$v0,	4
	syscall
	j	selectCombinatorics_n
	
	blt	$s1,	3,	Combinations_prep
	j	Permutations_prep
	
	# Navigate to proper menus
	
	beq	$s1,	5,	Binomial_prep
	blt	$s1,	3,	Combinations_prep	
	j	Permutations_prep

returnValueOfOne:
	#NICK WE NEED TO ADD THIS HERE.


Combinatorics_prep:

	addi	$s0,	$s0,	1
	beq	$s1,	1,	Combinations_prep
	beq	$s1,	2,	Combinations_prep
	beq	$s1,	3,	Permutations_prep
	beq	$s1,	4,	Permutations_prep
	#insert invalid selection here	
	
Binomial_prep:

	jal 	Binomial
	j	displayMenu	
	
Combinations_prep:
	
	jal	Combinations
	j 	displayMenu
	
Permutations_prep:

	jal	Permutations
	j 	displayMenu
	
exit:
	li	$v0,	10
	syscall
