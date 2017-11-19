                .data
counter: .word 0
words:  .word 0
top:        .word 249
buffer:  .space 250
                .align 2
prompt:               .asciiz    "Enter a phrase"
                .align 2
phrase: .asciiz "\n"
end1:    .asciiz "There are "
end2:    .asciiz " characters in "
end3:    .asciiz " words (including spaces)."
exited:  .asciiz "Character Counter has been terminated. Goodbye!"
                .text
                
main:
                li              $s6, -1                   #character count
                li              $s2, 0                    #space count
                addi       $s3, $zero, ' '      #space character
                addi       $s4, $zero, '\0'#end of string character, null terminator
                lw           $s5, top                #largest space for characters
                
                li              $v0, 54                  #service call for dialog prompt
                la             $a0, prompt       #three arguments for the service call
                la             $a1, buffer
                addi       $a2, $zero, 500
                syscall
                
                la             $s0, buffer          #text stored in buffer, moved to $s0 register
                jal           count                    #call count function
                j               exit                        #proceed to exit
                
count:   
                li              $s1, 5                    #arbitrary setting s1 to an integer
                addi       $sp, $sp, -4         #adjusting the stack
                sw          $s1, ($sp)            #push on to stack
                li              $s1, 0
                lb            $t0, ($s0)
                beq        $s4, $t0, return
                addi       $s6, $s6, 1
                beq        $t0, $s3, addword
                addi       $s0, $s0, 1           #this is to prove that the stack worked
                lw           $s1, ($sp)            #pop from stack on to $s1
                addi       $sp, $sp, 4           #adjust stack to "delete" what was popped
                j count
return:  
                add        $v0, $s6, $zero
                add        $v1, $s2, $zero
                jr             $ra

addword:
                addi       $s2, $s2, 1
                addi       $s0, $s0, 1
                j               count


exit:
                li              $t1, -1
                beq        $t1, $v0, hard_exit
                #We've really only counted spaces, so add 1
                sw          $v0, counter
                addi       $v1, $v1, 1
                sw          $v1, words
                
                #Print the results!
                
                #Here's the phrase
                la             $a0, buffer
                li              $v0, 4
                syscall
                #There are
                la             $a0, end1
                li              $v0, 4
                syscall
                li              $v0, 1
                lw           $a0, counter
                syscall
                #characters
                la             $a0, end2
                li              $v0, 4
                syscall
                #spaces
                li              $v0, 1
                lw           $a0, words
                syscall
                la             $a0, end3
                li              $v0, 4
                syscall
                
                #Check to see if the user canceled, or pressed enter        
                la             $t0, buffer
                li              $s1, 0
                
                #Clear the buffer!
                #Loops through the entire buffer area, and places 0 at each bit
rmbuf:  
                lw           $s2, top
                beq        $s1, $s2, main    #if the buffer area is clean, return to main
                sb           $s4, ($t0)
                addi       $t0, $t0, 1
                addi       $s1, $s1, 1
                j               rmbuf
                
                #Exit gracefully
hard_exit:
                li              $v0, 59
                la             $a0, exited
                la             $a1, phrase
                syscall
                li $v0, 10
                syscall  
