# Filename:	    peg_puzzle.asm
# Author:	    Tousif Chowdhury 
# Description	    Plays the game of peg solitaire. Takes user input 
#		    to pick a piece, and then where to move it to 
#		    Player plays until there is no other moves to make 

#################################
####### Constants ###############
#################################
PRINT_INT = 1 
PRINT_STRING = 4 
READ_INT = 5 
END_PROGRAM = 10 
PRINT_CHAR = 11 

    .data
    .globl main 
    .align 0 
					
board_array: 
	.ascii "  XXX    XXX  XXXXXXXXXX XXXXXXXXXX  XXX    XXX  "

forbiden_piece:
	.asciiz "_"

peg_pieces: 
	.asciiz "X"

empty_piece: 
	.asciiz " "

real_empty_space:
	.ascii " "

new_line: 
	.asciiz "\n"

welcome_banner:
	.ascii "   ************************\n
	.ascii "   **     Peg Puzzle     **\n"
	.asciiz "   ************************\n"

board_top_row: 
	.asciiz	    "    0  1  2  3  4  5  6   \n"

top_wall:
	.asciiz	    "        +---------+\n"

begin_row_0:		    
	.asciiz	    "0       |"

begin_row_1: 
	.asciiz	    "1 +-----+"

begin_row_2:
	.asciiz	    "2 |"

begin_row_3:
	.asciiz	    "3 |"

begin_row_4:
	.asciiz	    "4 |"

begin_row_5:
	.asciiz	    "5 +-----+"

begin_row_6:
	.asciiz	    "6       |"

end_row:
	.asciiz	    "|\n"

end_wall_row:
    	.asciiz	    "+-----+\n"

player_quit_message:
	.asciiz "Player quit."

enter_peg_to_move_location: 
	.asciiz "Enter the location of the peg to move (RC, -1 to quit): "

enter_location_to_move_peg:
	.asciiz "Enter the location where the peg is moving to (RC, -1 to quit): "

illegal_not_on_board:
	.asciiz "Illegal location.\n"

illegal_no_peg:
	.asciiz "Illegal move, no peg at source location.\n"

illegal_move_occupied:
	.asciiz "Illegal move, destination location is occupied.\n"

illegal_move_jump_only_one_peg:
	.asciiz "Illegal move, can only jump over one peg, re-enter move.\n"

illegal_move_no_middle_peg:
	.asciiz "Illegal move, no peg, being jumped over, re-enter move.\n"
you_have:
	.asciiz "\nYou left "
pegs_on_board_left:
	.asciiz " pegs on the board.\n"
no_more_legal_moves:
	.asciiz "There are no more legal moves."

    .text 

#
# Name:		    MAIN PROGRAM
# Description:	    Main logic for the program
#		    
#		    Prints the banners, asks user for inputs,
#		    loops and plays game until game is over
main: 
	li     $v0, PRINT_STRING  
	la     $a0, welcome_banner
	syscall	    
 
	jal    print_whole_board

	li     $v0, PRINT_STRING
	la     $a0, new_line
	syscall

	jal    play_game	

	li     $v0, END_PROGRAM 
	syscall

#
# Name:		    Player Quit Game 
# Description	    Function that ends the game and displays 
#		    number of pegs left on board 
#
player_quit_game:
	addi   $sp, $sp, -4
	sw     $ra, 0($sp)

	li     $v0, PRINT_STRING 
	la     $a0, player_quit_message
	syscall 
	
	jal    print_number_of_pegs

	li     $v0, END_PROGRAM 
	syscall

	lw     $ra, 0($sp)
	addi   $sp, $sp, -4 
	jr     $ra 

print_number_of_pegs:
    	addi   $sp, $sp, -4
	sw     $ra, 0($sp) 
	
	li     $v0, PRINT_STRING
	la     $a0, you_have
	syscall	    

	jal    count_board
	move   $a0, $v0
	li     $v0, PRINT_INT
	syscall

    	li     $v0, PRINT_STRING
	la     $a0, pegs_on_board_left
	syscall	    

	lw     $ra, 0($sp)
	addi   $sp, $sp, 4 
	jr     $ra 

#
# Name:		    Play Games   
# Description:	    Function to play the game 
#
play_game:
	addi   $sp, $sp, -16
	sw     $ra, 12($sp)
	sw     $s2, 8($sp)
	sw     $s1, 4($sp)
	sw     $s0, 0($sp)

get_input:
	jal    user_inputs_peg_location	     #get user inputs
	move   $s0, $v0
	jal    user_inputs_destination
	move   $s1, $v0
remove_logic:
	move   $a0, $s0
	move   $a1, $s1
	jal    valid_move_remove	     #remove the piece
	move   $s2, $v0
	bne    $s2, $zero, print	     #if valid remove, print board
	j      get_input		     #else jump back to input
	
print:
	jal    print_whole_board
	jal    count_moves_left
	beq    $v0, $zero, game_over 
	j      get_input

game_over:
	jal    game_is_over 
	j      demo_done
demo_done:
	lw     $s0, 0($sp)
	lw     $s1, 4($sp)
	lw     $s2, 8($sp)
	lw     $ra, 12($sp)
	addi   $sp, $sp, 16
	jr     $ra 

#
# Name:		    Game Is Over 
# Description:	    Function that prints proper messages when no
#		    more legal moves are left 
game_is_over:
    	addi   $sp, $sp, -4
	sw     $ra, 0($sp)

	li     $v0, PRINT_STRING
	la     $a0, no_more_legal_moves	     #Prints message 
	syscall

	jal    print_number_of_pegs

	lw     $ra, 0($sp)
	addi   $sp, $sp, 4
	jr     $ra 

#
# Name:		    count_board 
# Description:	    Helper function to count number of pieces 
#		    Returns:
#		    $v0 - number of pieces left 
count_board:
	addi   $sp, $sp, -24		     #save stack 
	sw     $ra, 20($sp) 
	sw     $s4, 16($sp)
	sw     $s3, 12($sp)
	sw     $s2, 8($sp)
	sw     $s1, 4($sp)
	sw     $s0, 0($sp)
	
	la     $s0, board_array		     #array
	li     $s1, 0			     #counter = 0 
	li     $s2, 49
	li     $t0, 88			     #peg piece 

count_pieces:
	beq    $s2, $zero, count_loop_done
	lb     $s3, 0($s0)		     #char at first index 
	bne    $s3, $t0, next_move	     #if not space, increment counter 
	addi   $s1, $s1, 1		     #increment counter 

next_move:
	addi   $s0, $s0, 1		     #go to next char 
	addi   $s2, $s2, -1		     #decrement counter 
	j      count_pieces 

count_loop_done:
	move   $v0, $s1 

	lw     $s0, 0($sp)
	lw     $s1, 4($sp)
	lw     $s2, 8($sp)
	lw     $s3, 12($sp)
	lw     $s4, 16($sp)
	lw     $ra, 20($sp)
	addi   $sp, $sp, 24
	jr     $ra

#	
# Name:		    User Input   
# Description:	    Prompt the user for input    
#		    Returns:
#		    $v0 - row
#		    $v1 - col	     
#
user_inputs_peg_location:
	addi   $sp, $sp, -24 
	sw     $ra, 20($sp) 
	sw     $s4, 16($sp)
	sw     $s3, 12($sp)
	sw     $s2, 8($sp)
	sw     $s1, 4($sp)
	sw     $s0, 0($sp)

input_peg:
	li     $v0, PRINT_STRING 
	la     $a0, enter_peg_to_move_location
	syscall

	li     $v0, READ_INT			  #reads in the integer 
	syscall 

	move   $s0, $v0				  #s0 holds the input now 
	li     $s4, -1 	
    
	beq    $s0, $s4, player_quit_game	  #if s0 = -1 quit 

	move   $a0, $s0
	jal    divide_to_get_rc			  #get two values 
	
	move   $a0, $v0
	move   $a1, $v1	 
	jal    is_move_on_board			  #check for on board

	move   $s3, $v0		
	beq    $s3, $zero, input_off_the_board	  

	move   $a0, $s0
	jal    divide_to_get_rc

	move   $a0, $v0
	move   $a1, $v1
	jal    check_if_piece 

	move   $s3, $v0				  #s3 is a 1 or 0
	li     $s1, 1				  #s1 is a 1 

	bne    $s3, $s1, is_a_space		  #check if it is a valid space, 1 or 0 
	move   $v0, $s0				  #return a valid piece to move if 1
	j      user_peg_input_done		  #finish function 

input_off_the_board:
	jal    print_not_on_board_error		  #print not on board error 
	j      input_peg

is_a_space:
	jal    print_is_a_space_error		  #if its a 0 print error, not a piece 
	j      input_peg			  #ask for input again 

user_peg_input_done:
	lw     $s0, 0($sp)
	lw     $s1, 4($sp)
	lw     $s2, 8($sp)
	lw     $s3, 12($sp)
	lw     $s4, 16($sp)
	lw     $ra, 20($sp)
	addi   $sp, $sp, 24
	jr     $ra 

#
# Name:		    User Destination    
# Description:	    Take input and manipulates it 
#		    Returns:     
#		    $v0 - row
#		    $v1 - col	     
#
user_inputs_destination:
	addi   $sp, $sp, -24  
	sw     $ra, 20($sp) 
	sw     $s4, 16($sp)
	sw     $s3, 12($sp)
	sw     $s2, 8($sp)
	sw     $s1, 4($sp)
	sw     $s0, 0($sp)

destination_spot:
	li     $v0, PRINT_STRING 
	la     $a0, enter_location_to_move_peg
	syscall

	li     $v0, READ_INT			       #reads in the integer 
	syscall 

	move   $s0, $v0				       #s0 holds the input now 
	li     $s4, -1 	 
    
	beq    $s0, $s4, player_quit_game	       #if s0 < -1 quit 

	move   $a0, $s0
	jal    divide_to_get_rc

	move   $a0, $v0
	move   $a1, $v1
	jal    is_move_on_board

	move   $s3, $v0		
	beq    $s3, $zero, destination_off_the_board

	move   $a0, $s0
	jal    divide_to_get_rc

	move   $a0, $v0
	move   $a1, $v1
	jal    check_if_piece 

	move   $s3, $v0				       #s3 is a 1 or 0
	li     $s1, 1				       #s1 is a 1 

	beq    $s3, $s1, is_not_space		       #check if it is a valid space, 1 or 0 
	move   $v0, $s0				       #return a valid piece to move if 1
	j      user_inputs_destination_end	       #finish function 

destination_off_the_board:
	jal    print_not_on_board_error
	j      destination_spot

is_not_space:
	jal    print_move_occupied_error	       #if its a 0 print error, not a piece 
	j      destination_spot			       #ask for input again

user_inputs_destination_end:
	lw     $s0, 0($sp)
	lw     $s1, 4($sp)
	lw     $s2, 8($sp)
	lw     $s3, 12($sp)
	lw     $s4, 16($sp)
	lw     $ra, 20($sp)
	addi   $sp, $sp, 24
	jr     $ra 

#
# Name:			 Is Move On Board 
# Description:		 Function to check if a move is on the board.
#			 0, if not on board, 1 if it is 
#			 Parameters:
#			 $a0 - row 
#			 $a1 - col   
#			 Returns
#			 $v0 - 0 or 1 
#
is_move_on_board:
	addi   $sp, $sp, -24		     #save stack 
	sw     $ra, 20($sp) 
	sw     $s4, 16($sp)
	sw     $s3, 12($sp)
	sw     $s2, 8($sp)
	sw     $s1, 4($sp)
	sw     $s0, 0($sp)
	
	move   $s0, $a0			     #s1 is row 
	move   $s1, $a1			     #s2 is col
	
	li     $s3, 5
    
	slti   $s2, $s0, 0		     #if row < 0, $s2 = 1 
	bne    $s2, $zero, not_on_board	     #if s2 != zero, not on board

	slti   $s2, $s1, 0		     #if col<0, $s2 =1
	bne    $s2, $zero, not_on_board	     #if $s2 != zero, not_on_board

	slti   $s2, $s0, 7		     #if row > 7, $s2 = 0
	beq    $s2, $zero, not_on_board	     #if s2 == zero, not on board

	slti   $s2, $s1, 7		     #if col>0, $s2 = 0 
	beq    $s2, $zero, not_on_board	     #if $s2 == zero, not_on_board

top_left:
					     #if r<2 and col < 2  return 0 
	slti   $t0, $s0, 2		     #if row < 2 $t0 =1 
	slti   $t1, $s1, 2
	beq    $t0, $zero, top_right	     #if either is broken, move to next check
	beq    $t1, $zero, top_right	      
	j      not_on_board		     #passes both check, its not on board

top_right:
					     #if r< 2 and col>=5  return 0 	
	slti   $t0, $s0, 2		     #if row < 2 $t0 =1
	slti   $t1, $s1, 5		     #if col > 4, $t1 = 0 
	beq    $t0, $zero, bottom_left	     #if either is broken go to next check  
	bne    $t1, $zero, bottom_left
	j      not_on_board		     #passes both checks, must be bad 

bottom_left:
					     #if r>=5 and col < 2 return 0
	slti   $t0, $s0, 5		     #$t0 will have 0 if greater than 	     
	slti   $t1, $s1, 2		     #t1 will have 1 if less than 
	bne    $t0, $zero, bottom_right 
	beq    $t1, $zero, bottom_right  
	j      not_on_board
bottom_right:
					     #if r>=5 and col > =5 return 0 
	slti   $t0, $s0, 5		     #t0 = 0     
	slti   $t1, $s1, 5		     #t1 = 0
	bne    $t0, $zero, on_board 
	bne    $t1, $zero, on_board  
	j      not_on_board

not_on_board:
	li     $v0, 0 
	j      is_move_on_board_done
on_board:
	li     $v0, 1 
	j      is_move_on_board_done

is_move_on_board_done: 
    	lw     $s0, 0($sp)
	lw     $s1, 4($sp)
	lw     $s2, 8($sp)
	lw     $s3, 12($sp)
	lw     $s4, 16($sp)
	lw     $ra, 20($sp)
	addi   $sp, $sp, 24
	jr     $ra 

#
# Name:		    Divide 
# Description:	    Function that takes in number and divides them 
#		    Parameters:
#		    $a0 - number
#		    Returns:
#		    $v0 - row 
#		    $v1 - col        
#
divide_to_get_rc:
     	addi   $sp, $sp, -16		#save stack 
	sw     $ra, 12($sp) 
	sw     $s2, 8($sp)
	sw     $s1, 4($sp)
	sw     $s0, 0($sp)

	move   $s0, $a0 
	div    $s1, $s0, 10		#divide input by 10 lo= division hi= modulo    
	mfhi   $s2
	
	move   $v0, $s1 
	move   $v1, $s2 

    	lw     $s0, 0($sp)
	lw     $s1, 4($sp)
	lw     $s2, 8($sp)
	lw     $ra, 12($sp)
	addi   $sp, $sp, 16
	jr     $ra 
#
# Name:		    Print Space Error
# Description:	    Function that Prints Space Error
#
print_is_a_space_error:
	addi   $sp, $sp, -4
	sw     $ra, 0($sp)

	li     $v0, PRINT_STRING 
	la     $a0, illegal_no_peg 
	syscall
	
	lw     $ra, 0($sp)
	addi   $sp, $sp, 4
	jr     $ra 

#
# Name:		    Print Not On Board Error
# Description:	    Function that Prints Not On Board Error
#
print_not_on_board_error:
	addi   $sp, $sp, -4
	sw     $ra, 0($sp)

	li     $v0, PRINT_STRING 
	la     $a0, illegal_not_on_board 
	syscall
	
	lw     $ra, 0($sp)
	addi   $sp, $sp, 4
	jr     $ra 

#
# Name:		    Print Error
# Description:	    Function that Move Occupied Error
#
print_move_occupied_error:
	addi   $sp, $sp, -4
	sw     $ra, 0($sp)

	li     $v0, PRINT_STRING 
	la     $a0, illegal_move_occupied 
	syscall
	
	lw     $ra, 0($sp)
	addi   $sp, $sp, 4
	jr     $ra 

#
# Name:		    Check If Piece 
# Description:	    Function to check if input row col is X or not 
#		    Parameter:  
#		    a0 - row
#		    a1 - col		     
#		    Return: 
#		    v0 - 1 if good, 0 if bad	     
#
check_if_piece: 
    	addi   $sp, $sp, -24		#save stack 
	sw     $ra, 20($sp) 
	sw     $s4, 16($sp)
	sw     $s3, 12($sp)
	sw     $s2, 8($sp)
	sw     $s1, 4($sp)
	sw     $s0, 0($sp)

	move   $s0, $a0			#move row from a0 to s0 
	move   $s1, $a1			#move col from a1 to s1 

	move   $s0, $a0			#move row from a0 to s0 
	move   $s1, $a1			#move col from a1 to s1 
	move   $a0, $s0		   
	move   $a1, $s1			

	jal    get_from_array
	move   $s2, $v0			#get the value and store it in s2 
	li     $s3, 88			#hold peg peice 

	bne    $s2, $s3, not_a_piece	#if value in s2 is not a piece goto not_a_piece 
	li     $v0, 1			#else put 1 in $v0, cause it is a piece 
	j      check_if_piece_done	#finish function

not_a_piece: 
	li     $v0, 0			#it is not a piece, so load a 0
	j      check_if_piece_done	#finish function 

check_if_piece_done:
    	lw     $s0, 0($sp)
	lw     $s1, 4($sp)
	lw     $s2, 8($sp)
	lw     $s3, 12($sp)
	lw     $s4, 16($sp)
	lw     $ra, 20($sp)
	addi   $sp, $sp, 24
	jr     $ra 

#
# Name:		    Get value from array
#		    a0 - row
#		    a1 - column	   
#		    v0 - value at the array 
#
get_from_array:
    	addi   $sp, $sp, -24		#save stack 
	sw     $ra, 20($sp) 
	sw     $s4, 16($sp)
	sw     $s3, 12($sp)
	sw     $s2, 8($sp)
	sw     $s1, 4($sp)
	sw     $s0, 0($sp)
    
	move   $s2, $a0			#get row and put in s2
	move   $s3, $a1			#get col and put in s3 

	la     $s1, board_array		#put board in $s1 
    
	li     $s0, 7			#load row size
	mul    $s0, $s0, $s2		#multply rowsize by row  
	add    $s0, $s0, $s3		#add col s0 = index at the array 
    
	add    $s0, $s1, $s0		#add length of array and index
    
	lb     $v0, 0($s0)		#value at row, column

get_from_array_done:
	lw     $s0, 0($sp)
	lw     $s1, 4($sp)
	lw     $s2, 8($sp)
	lw     $s3, 12($sp)
	lw     $s4, 16($sp)
	lw     $ra, 20($sp)
	addi   $sp, $sp, 24
	jr     $ra 

#
# Name:		    Add Space 
# Description	    Function to remove a piece on the board 
#		    Parameter:
#		    a0 - row
#		    a1 - col  
#
remove_piece_from_board: 
	addi   $sp, $sp, -24		#save stack 
	sw     $ra, 20($sp) 
	sw     $s4, 16($sp)
	sw     $s3, 12($sp)
	sw     $s2, 8($sp)
	sw     $s1, 4($sp)
	sw     $s0, 0($sp)
	 
	move   $s2, $a0			#get row and put in s2
	move   $s3, $a1			#get col and put in s3 

	la     $s1, board_array		#put board in $s1 
    
	li     $s0, 7			#load row size
	mul    $s0, $s0, $s2		#multply rowsize by row  
	add    $s0, $s0, $s3		#add col s0 = index at the array 
    
	add    $s0, $s1, $s0		#add length of array and index
    
	lb     $s4, 0($s0)		#value at row, column

	addi   $s4,$s4, -56		#makes the value into a space
	sb     $s4, ($s0)

	lw     $s0, 0($sp)
	lw     $s1, 4($sp)
	lw     $s2, 8($sp)
	lw     $s3, 12($sp)
	lw     $s4, 16($sp)
	lw     $ra, 20($sp)
	addi   $sp, $sp, 24
	jr     $ra 

# Name:		    Add Piece
# Description:	    Function to add a piece on a blank spot
#		    Parameters:
#		    a0 - row
#		    a1 - col 
#
add_piece_to_board: 
	addi   $sp, $sp, -24 #save stack 
	sw     $ra, 20($sp) 
	sw     $s4, 16($sp)
	sw     $s3, 12($sp)
	sw     $s2, 8($sp)
	sw     $s1, 4($sp)
	sw     $s0, 0($sp)
	 
	move   $s2, $a0			#get row and put in s2
	move   $s3, $a1			#get col and put in s3 

	la     $s1, board_array		#put board in $s1 
    
	li     $s0, 7			#load row size
	mul    $s0, $s0, $s2		#multply rowsize by row  
	add    $s0, $s0, $s3		#add col s0 = index at the array 
    
	add    $s0, $s1, $s0		#add length of array and index
    
	lb     $s4, 0($s0)		#value at row, column

	addi   $s4,$s4, 56		#makes the value into a space
	sb     $s4, ($s0)

	lw     $s0, 0($sp)
	lw     $s1, 4($sp)
	lw     $s2, 8($sp)
	lw     $s3, 12($sp)
	lw     $s4, 16($sp)
	lw     $ra, 20($sp)
	addi   $sp, $sp, 24
	jr     $ra 

# Name:		    Count Moves
# Description:	    Function loops thru board. And check each coor
#		    $v0 - number of available moves  
#
count_moves_left:
	addi   $sp, $sp, -36			  #save stack 
	sw     $ra, 32($sp) 
	sw     $s7, 28($sp)
	sw     $s6, 24($sp)
	sw     $s5, 20($sp)
	sw     $s4, 16($sp)
	sw     $s3, 12($sp)
	sw     $s2, 8($sp)
	sw     $s1, 4($sp)
	sw     $s0, 0($sp)
	
	li     $s0, 0
	li     $s1, 66
	li     $s2, 0				  #counter 
	
go_thru_board_coor_loop:
	beq    $s0, $s1, count_moves_left_done 

	move   $a0, $s0 
	jal    divide_to_get_rc
	move   $a0, $v0
	move   $a1, $v1 
	jal    does_coor_have_move		  #0 is coordinate has no moves , 1 if it does 
	bne    $v0, $zero, add_counter
	addi   $s0, $s0, 1
	j      go_thru_board_coor_loop
add_counter: 
	addi   $s2, $s2, 1 
	addi   $s0, $s0, 1 
	j      go_thru_board_coor_loop
	
count_moves_left_done: 
	move   $v0, $s2 
	
	lw     $s0, 0($sp)
	lw     $s1, 4($sp)
	lw     $s2, 8($sp)
	lw     $s3, 12($sp)
	lw     $s4, 16($sp)
    	lw     $s5, 20($sp)
	lw     $s6, 24($sp)
	lw     $s7, 28($sp)
	lw     $ra, 32($sp)
	addi   $sp, $sp, 36
	jr     $ra 

#
# Name:		    Does Coor Have Move 
# Description:	    Function takes in coordinates              
#		    sees if the coordinate has any valid moves 
#		    Parameters:
#		    a0 - row 
#		    a1- col
#		    Return:
#		    v0- 0 if no valid moves 
#
does_coor_have_move:
	addi   $sp, $sp, -36 #save stack 
	sw     $ra, 32($sp) 
	sw     $s7, 28($sp)
	sw     $s6, 24($sp)
	sw     $s5, 20($sp)
	sw     $s4, 16($sp)
	sw     $s3, 12($sp)
	sw     $s2, 8($sp)
	sw     $s1, 4($sp)
	sw     $s0, 0($sp)

	move   $s1, $a0
	move   $s2, $a1 
	jal    check_if_piece 			  #if its a space return 0
	beq    $v0, $zero, fail_all_checks
	
valid_left_moves:
	move   $s3, $s1				  #s3 = same row 
	addi   $s4, $s2, -1			  #s5 = hold the value to the left of peg 
	
	move   $s5, $s1
	addi   $s6, $s2, -2			  #get piece two units left of peg

	move   $a0, $s3
	move   $a1, $s4
	jal    is_move_on_board			  #check if piece to the left is on board or not 
	beq    $v0, $zero, valid_right_moves	  #if off board, check other moves
	
	move   $a0, $s5
	move   $a1, $s6
	jal    is_move_on_board			  #check if piece 2 units is on board or not 
	beq    $v0, $zero, valid_right_moves 
	
    	move   $a0, $s3
	move   $a1, $s4
	jal    check_if_piece		      
	beq    $v0, $zero, valid_right_moves	  #if left piece is x and 2nd piece is space, its valid 
	
	move   $a0, $s5				  
	move   $a1, $s6
	jal    check_if_piece		      
	bne    $v0, $zero, valid_right_moves 

	j      has_valid_move 

valid_right_moves: 
	move   $s3, $s1				  #s3 = same row 
	addi   $s4, $s2, +1			  #s5 = hold the value to the right of peg 
	
	move   $s5, $s1
	addi   $s6, $s2, +2			  #get piece two units right of peg

	move   $a0, $s3
	move   $a1, $s4
	jal    is_move_on_board			  #check if piece to the right is on board or not 
	beq    $v0, $zero, valid_up_moves	  #if off board, check other moves
	
	move   $a0, $s5
	move   $a1, $s6
	jal    is_move_on_board			  #check if piece 2 units is on board or not 
	beq    $v0, $zero, valid_up_moves 
	
	#if right piece is x and 2nd piece is space, its valid 
    	move   $a0, $s3
	move   $a1, $s4
	jal    check_if_piece		      
	beq    $v0, $zero, valid_up_moves	     
	
	move   $a0, $s5				  
	move   $a1, $s6
	jal    check_if_piece		      
	bne    $v0, $zero, valid_up_moves 

	j      has_valid_move 

valid_up_moves:
	addi   $s3, $s1, -1 
	move   $s4, $s2 

	addi   $s5, $s1, -2
	move   $s6, $s2

    	move   $a0, $s3
	move   $a1, $s4
	jal    is_move_on_board			  #check if piece to the right is on board or not 
	beq    $v0, $zero, valid_down_moves	  #if off board, check other moves
	
	move   $a0, $s5
	move   $a1, $s6
	jal    is_move_on_board			  #check if piece 2 units is on board or not 
	beq    $v0, $zero, valid_down_moves 
	
	#if up piece is x and 2nd piece is space, its valid 
    	move   $a0, $s3
	move   $a1, $s4
	jal    check_if_piece		      
	beq    $v0, $zero, valid_down_moves	     
	
	move   $a0, $s5				  
	move   $a1, $s6
	jal    check_if_piece		      
	bne    $v0, $zero, valid_down_moves 

	j      has_valid_move 

valid_down_moves: 
	addi   $s3, $s1, +1 
	move   $s4, $s2 

	addi   $s5, $s1, +2
	move   $s6, $s2

    	move   $a0, $s3
	move   $a1, $s4
	jal    is_move_on_board			  #check if piece to the right is on board or not 
	beq    $v0, $zero, fail_all_checks	  #if off board, check other moves
	
	move   $a0, $s5
	move   $a1, $s6
	jal    is_move_on_board			  #check if piece 2 units is on board or not 
	beq    $v0, $zero, fail_all_checks 
	
	#if up piece is x and 2nd piece is space, its valid 
    	move   $a0, $s3
	move   $a1, $s4
	jal    check_if_piece		      
	beq    $v0, $zero, fail_all_checks	     
	
	move   $a0, $s5				  
	move   $a1, $s6
	jal    check_if_piece		      
	bne    $v0, $zero, fail_all_checks

	j      has_valid_move 

fail_all_checks:
	li     $v0, 0
	j      does_coor_have_move_done

has_valid_move:
	li     $v0, 1 
	j      does_coor_have_move_done

does_coor_have_move_done:
	lw     $s0, 0($sp)
	lw     $s1, 4($sp)
	lw     $s2, 8($sp)
	lw     $s3, 12($sp)
	lw     $s4, 16($sp)
    	lw     $s5, 20($sp)
	lw     $s6, 24($sp)
	lw     $s7, 28($sp)
	lw     $ra, 32($sp)
	addi   $sp, $sp, 36
	jr     $ra 

#
# Name:		    Remove Logic
# Description:	    Function to take in a peg input and a destination
#		    and do proper game logic and remove piece 
#		    and add a piece.
#		    Paramter:
#		    a0 - input 
#		    a1 - destination 
#		    Return
#		    v0 - 0 if bad move, 1 if good move  
#
valid_move_remove:
	addi   $sp, $sp, -36 
	sw     $ra, 32($sp) 
	sw     $s7, 28($sp)
	sw     $s6, 24($sp)
	sw     $s5, 20($sp)
	sw     $s4, 16($sp)
	sw     $s3, 12($sp)
	sw     $s2, 8($sp)
	sw     $s1, 4($sp)
	sw     $s0, 0($sp)

	move   $s0, $a0	 
	move   $a0, $s0 
	jal    divide_to_get_rc
	move   $s0, $v0				  #s0 holds the row of input peg
	move   $s1, $v1				  #s1 holds the col of the input peg

	move   $a0, $a1 
	jal    divide_to_get_rc 
	move   $s2, $v0				  #s2 holds the destination row
	move   $s3, $v1				  #s3 holds the desitination col 
	
check_up:
	bne    $s1, $s3, check_right

	li     $t0, 2 
	sub    $s7, $s0, $s2			  #s7 has to be 2, ir - cr 
	bne    $s7, $t0, check_down	
	addi   $s4, $s0, -1			  #inputrow -1 to get top piace 
	move   $s5, $s1				  #same col will be used 

	move   $a0, $s4
	move   $a1, $s5 
	jal    check_if_piece			  #see if r,c is a piece or not 
	move   $s6, $v0				  #value at middle of input and dest

	beq    $s6, $zero, cant_jump_space	  #if $s6 =0, its not a piece, its space 
	j      jump_good			  #do jump manipulation if it passes all checks 

check_down:
	li     $t0, 2 
	sub    $s7, $s2, $s0			  #s7 = cr-ir 
	bne    $s7, $t0, check_right	
	addi   $s4, $s0, 1			  #inputrow +1 to get bottom (middle row) 
	move   $s5, $s1				  #same col will be used 

	move   $a0, $s4
	move   $a1, $s5 
	jal    check_if_piece			  #see if r,c is a piece or not 
	move   $s6, $v0				  #value at middle of input and dest

	beq    $s6, $zero, cant_jump_space	  #if $s6 =0, its not a piece, its space 
	j      jump_good			  #do jump manipulation if it passes all checks

check_right:
	bne    $s0, $s2, cant_jump	
	li     $t0, 2 
	sub    $s7, $s3, $s1			  #s7 = dc-ic
						  # if s7 is not 2 there are more pieces in between 
	bne    $s7, $t0, check_left	
	move   $s4, $s0				  #input row is the same 
	addi   $s5, $s1, 1			  #input col + 1 

	move   $a0, $s4
	move   $a1, $s5 
	jal    check_if_piece			  #see if r,c is a piece or not 
	move   $s6, $v0				  #value at middle of input and dest

	beq    $s6, $zero, cant_jump_space	  #if $s6 =0, its not a piece, its space 
	j      jump_good			  #do jump manipulation if it passes all checks

check_left: 
	bne    $s0, $s2, cant_jump		  #fails all other tests 
	li     $t0, 2 
	sub    $s7, $s1, $s3			  #s7 = dc-ic
	bne    $s7, $t0, cant_jump		  # if s7 is not 2 there are more pieces in between 

	move   $s4, $s0				  #input row is the same 
	addi   $s5, $s1, -1			  #input col - 1 = mid col 

	move   $a0, $s4
	move   $a1, $s5			
	jal    check_if_piece			  #see if r,c is a piece or not 
	move   $s6, $v0				  #value at middle of input and dest

	beq    $s6, $zero, cant_jump_space	  #if $s6 =0, its not a piece, its space 
	j      jump_good			  #do jump manipulation if it passes all checks

cant_jump: 
	la     $a0, illegal_move_jump_only_one_peg
	li     $v0, PRINT_STRING
	syscall 

	li     $v0, 0 
	j      valid_move_remove_done 

cant_jump_space:
	la     $a0, illegal_move_no_middle_peg
	li     $v0, PRINT_STRING 
	syscall	    
	li     $v0, 0 
	j      valid_move_remove_done 

jump_good:
	move   $a0, $s0				  #remove input peg
	move   $a1, $s1 
	jal    remove_piece_from_board

	move   $a0, $s2				  #make piece into an X
	move   $a1, $s3 
	jal    add_piece_to_board

	move   $a0, $s4				  #remove middle peg 
	move   $a1, $s5
	jal    remove_piece_from_board 
	li     $v0, 1
	j      valid_move_remove_done 

valid_move_remove_done:
	lw     $s0, 0($sp)
	lw     $s1, 4($sp)
	lw     $s2, 8($sp)
	lw     $s3, 12($sp)
	lw     $s4, 16($sp)
    	lw     $s5, 20($sp)
	lw     $s6, 24($sp)
	lw     $s7, 28($sp)
	lw     $ra, 32($sp)
	addi   $sp, $sp, 36
	jr     $ra 

#
# Name:		    Print Desired Size of Board  
# Description:	    Helper function that takes in a row, col, size
#		    Will print desired length from board
#		    Parameter:
#		    a0 - row
#		    a1 - col
#		    a2 - size   
#
print_desired_size: 
	addi   $sp, $sp, -24			  #save stack 
	sw     $ra, 20($sp) 
	sw     $s4, 16($sp)
	sw     $s3, 12($sp)
	sw     $s2, 8($sp)
	sw     $s1, 4($sp)
	sw     $s0, 0($sp)

						  #s3 will hold char from array 
	move   $s0, $a0				  #get the row 
	move   $s1, $a1				  #get col into s1
	move   $s2, $a2				  #get size into s2 
board_loop_size:
	beq    $zero, $s2, end_print_desired	  #if s2 == zero go to end

	move   $a0, $s0
	move   $a1, $s1
	jal    get_from_array			  #a0 and a1 is already the row and col 
	move   $s3, $v0				  #v0 holds the value at row col from array 
    
	li     $v0, PRINT_STRING		  #print the space before the char 
	la     $a0, empty_piece 
	syscall 

	li     $v0, PRINT_CHAR			  #system call code for print char
	move   $a0, $s3				  #print the char at the row col
	syscall 

	li     $v0, PRINT_STRING		  #print the space after the char
	la     $a0, empty_piece 
	syscall 

	addi   $s1, $s1, 1			  #increment column
	move   $a0, $s0 
	move   $a1, $s1
	addi   $s2, $s2, -1			  #decrement size 
	j      board_loop_size			  #jump to begin of the loop 

end_print_desired:
	lw     $s0, 0($sp)
	lw     $s1, 4($sp)
	lw     $s2, 8($sp)
	lw     $s3, 12($sp)
	lw     $s4, 16($sp)
	lw     $ra, 20($sp)
	addi   $sp, $sp, 24
	jr     $ra 

#
# Name:		    Print Board 
# Description:	    Prints the whole board 
#
print_whole_board:
	addi   $sp, $sp, -8		#save stack 
	sw     $ra, 4($sp) 
	sw     $s0, 0($sp)

	li     $v0, PRINT_STRING 
	la     $a0, new_line
	syscall

	li     $v0, PRINT_STRING 
	la     $a0, board_top_row 
	syscall

	li     $v0, PRINT_STRING 
	la     $a0, top_wall
	syscall 

	li     $v0, PRINT_STRING 
	la     $a0, begin_row_0
	syscall
	
	li     $a0, 0			#set the row to send in 
	li     $a1, 2			#set the coloumn to send in 
	li     $a2, 3			#set the size to loop till 
	jal    print_desired_size	#print desired length  

	li     $v0, PRINT_STRING
	la     $a0, end_row
	syscall

	li     $v0, PRINT_STRING 
	la     $a0, begin_row_1 
	syscall

	li     $a0, 1 
	li     $a1, 2
	li     $a2, 3 
	jal    print_desired_size
	
	li     $v0, PRINT_STRING
	la     $a0, end_wall_row
	syscall

	li     $v0, PRINT_STRING 
	la     $a0, begin_row_2 
	syscall 

	li     $a0, 2
	li     $a1, 0
	li     $a2, 7
	jal    print_desired_size

	li     $v0, PRINT_STRING 
	la     $a0, end_row 
	syscall

	li     $v0, PRINT_STRING 
	la     $a0, begin_row_3 
	syscall 

	li     $a0, 3
	li     $a1, 0
	li     $a2, 7
	jal    print_desired_size

	li     $v0, PRINT_STRING 
	la     $a0, end_row 
	syscall

	li     $v0, PRINT_STRING 
	la     $a0, begin_row_4 
	syscall 

	li     $a0, 4
	li     $a1, 0
	li     $a2, 7
	jal    print_desired_size

	li     $v0, PRINT_STRING 
	la     $a0, end_row 
	syscall

	li     $v0, PRINT_STRING 
	la     $a0, begin_row_5 
	syscall 

	li     $a0, 5
	li     $a1, 2
	li     $a2, 3
	jal    print_desired_size

	li     $v0, PRINT_STRING 
	la     $a0, end_wall_row 
	syscall

	li     $v0, PRINT_STRING 
	la     $a0, begin_row_6
	syscall
	
	li     $a0, 6			#set the row to send in 
	li     $a1, 2			#set the coloumn to send in 
	li     $a2, 3			#set the size to loop till 
	jal    print_desired_size	#print desired length  

	li     $v0, PRINT_STRING
	la     $a0, end_row
	syscall
	
	li     $v0, PRINT_STRING 
	la     $a0, top_wall
	syscall

    	lw     $s0, 0($sp)
	lw     $ra, 4($sp)
	addi   $sp, $sp, 8
	jr     $ra 
