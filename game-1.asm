##################################################################### 
# 
# CSCB58 Winter 2022 Assembly Final Project 
# University of Toronto, Scarborough 
# 
# Student: Name, Student Number, UTorID, official email 
# 
# Bitmap Display Configuration: 
# - Unit width in pixels: 4 (update this as needed)  
# - Unit height in pixels: 4 (update this as needed) 
# - Display width in pixels: 256 (update this as needed) 
# - Display height in pixels: 256 (update this as needed) 
# - Base Address for Display: 0x10008000 ($gp) 
# 
# Which milestones have been reached in this submission? 
# (See the assignment handout for descriptions of the milestones) 
# - Milestone 1/2/3 (choose the one the applies) 
# MILESTONE 3 WAS REACHED
# 
# Which approved features have been implemented for milestone 3? 
# (See the assignment handout for the list of additional features) 
# 1. FAIL CONDITION
# 2. Win condition
# 3. Moving Objects
# 4. Moving Platforms
# 5. Disappearing Platforms
# 6. Different Levels
# ... (add more if necessary) 
# 
# Link to video demonstration for final submission: 
# - (insert YouTube / MyMedia / other URL here). Make sure we can view it! 
# https://www.youtube.com/watch?v=oC4LuCXsdPw
# Are you OK with us sharing the video with people outside course staff? 
# - yes / no / yes, and please share this project github link as well! 
# yes
# Any additional information that the TA needs to know: 
# - (write here, if any) 
# WAIT 10 SECONDS IN LEVEL 2 FOR THE PLATFORM TO DISAPPEAR
##################################################################### 


.data
xVel:		.word	0		# x velocity start 0 1 right -1 left
yVel:		.word	0		# y velocity start 0 1 ddown -1 up
xPos:		.word	0	# x position
yPos:		.word	58		# y position
jump:		.word 	0	#set jump to False
platform1x:	.word 	9
platform1y:	.word 	57
platform1len:	.word	6
acceleration:	.word 	1
platform2x: 	.word	18
platform2y:	.word 	53
platform2len:	.word	16
platform3x:	.word	35
platform3y:	.word	53
platform3len:	.word	8
platform3vel:	.word	1
enemyx:		.word 	19
enemyy:		.word 	50
enemyvel:	.word	1

enemy2x:	.word	55
enemy2y:	.word	59


lavax:		.word 	8
lavay:		.word	62
lavalen:	.word 	42

goalx:		.word	58
goaly:		.word	62

lvl2_plat_x:	.word	8
lvl2_plat_y:	.word 	57
lvl2_plat_len:	.word	42
lvl2_plat_vis:	.word	1
lvl2_plat_counter:	.word	0


.eqv  BASE_ADDRESS  0x10008000 
.eqv	BROWN    0x964b00
.eqv RED 0xff0000
.eqv ORANGE	0xff8c00
.eqv YELLOW	0xffff00
.eqv GROUND_LOCATION 15872
.eqv	WHITE	0xffffff
.eqv	BLACK	0x000000
.eqv	GREEN	0x00ff00
STATIONARY_PLATFORM_LOCATIONS: .word 


.text
INIT_LEVEL1:
	li $t0, 0
	sw $t0, xPos
	li $t0, 59
	sw $t0, yPos
LEVEL1_LOOP:

	addi	$v0, $zero, 32	
	addi	$a0, $zero, 66
	syscall
	
	#CHECK_FOR_ENEMY2_COLLISION
	lw $t0, yPos
	
	bge $t0, 56, CHECK_FOR_ENEMY2_COLLISION
AFTER_CHECK_FOR_ENEMY2_COLLISION:
	#CHECK IF FALLING
	lw $t0, yVel
	bgt $t0, 0, CHECK_FOR_COLLISIONS
	
AFTER_STOP_GRAVITY:

	
	#READ KEYPRESS
	li $t9, 0xffff0000  
	lw $t8, 0($t9) 
	beq $t8, 1, keypress_happened 
AFTER_CHECK_KEYPRESS:
AFTER_MOVE:
	
	### Sleep for 66 ms so frame rate is about 15
	#CALL DRAW_GROUND
	li $a0, GROUND_LOCATION #load base address into a0
	addi $a0, $a0, BASE_ADDRESS
	li $a1, 0x964b00 #load 
	jal DRAW_GROUND

	
	
	#call DRAW_SKY
	li $a0, BASE_ADDRESS
	li $a1, 0x008080
	jal DRAW_SKY

 	#move the character x
 	lw $t0, xVel
 	lw $t1, xPos
 	add $t1, $t1, $t0
 	sw $t1, xPos
 	#move the character y
	lw $t0, yVel
	addi $t0, $t0, 1
	sw $t0, yVel
	
	lw $t1, yPos
	add $t1, $t1, $t0
	sw $t1, yPos
	
	#call DRAW_CHARACTER
	#LOAD CHARACTER LOCATION IN A0
	lw $a0, yPos
	mul $a0, $a0, 256
	
	addi $a0, $a0, BASE_ADDRESS
	lw $t0, xPos
	mul $t0, $t0, 4
	add $a0, $a0, $t0
	#LOAD RED INTO A1
	li $a1, 0xff0000 #load red into a1
	jal DRAW_CHARACTER
	
	#call DRAW_PLATFORM on platform1
	lw $a0, platform1y
	mul $a0, $a0, 256
	
	addi $a0, $a0, BASE_ADDRESS
	lw $t0, platform1x
	mul $t0, $t0, 4
	add $a0, $a0, $t0
	lw $a1, platform1len
	li $a2, 0x00ff00
	jal DRAW_PLATFORM
	
	#draw platform2
	lw $a0, platform2y
	mul $a0, $a0, 256
	
	addi $a0, $a0, BASE_ADDRESS
	lw $t0, platform2x
	mul $t0, $t0, 4
	add $a0, $a0, $t0
	lw $a1, platform2len
	li $a2, 0x00ff00
	jal DRAW_PLATFORM
	#reset x velocity
	li $t0, 0
	sw $t0, xVel
	lw $t0,yPos
	
	#move platofrm3
	lw $t0, platform3x
	beq $t0, 34, FLIP_PLATFORM3_VEL
	beq $t0, 56, FLIP_PLATFORM3_VEL
AFTER_FLIP_PLATFORM3_VEL:
	lw $t0, platform3x
	lw $t1, platform3vel
	add $t0, $t0, $t1
	sw $t0, platform3x
	
	#draw platform3
	lw $a0, platform3y
	mul $a0, $a0, 256
	
	addi $a0, $a0, BASE_ADDRESS
	lw $t0, platform3x
	mul $t0, $t0, 4
	add $a0, $a0, $t0
	lw $a1, platform3len
	li $a2, 0x00ff00
	jal DRAW_PLATFORM
	
	
	#move enemy
	lw $t0, enemyx
	beq $t0, 18, FLIP_ENEMY_VEL
	beq $t0, 30, FLIP_ENEMY_VEL
AFTER_FLIP_ENEMY_VEL:
	lw $t0, enemyx
	lw $t1, enemyvel
	add $t0, $t0, $t1
	sw $t0, enemyx
	
	
	#draw enemy
	lw $a0, enemyy
	mul $a0, $a0, 256
	
	addi $a0, $a0, BASE_ADDRESS
	lw $t0, enemyx
	mul $t0, $t0, 4
	add $a0, $a0, $t0
	#LOAD RED INTO A1
	li $a1, 0x0000ff #load red into a1
	jal DRAW_ENEMY
	
	#move enemy2
	
	#draw enemy
	lw $a0, enemy2y
	mul $a0, $a0, 256
	
	addi $a0, $a0, BASE_ADDRESS
	lw $t0, enemy2x
	mul $t0, $t0, 4
	add $a0, $a0, $t0
	#LOAD RED INTO A1
	li $a1, 0x0000ff #load red into a1
	jal DRAW_ENEMY
	
	
	#DRAW_LAVA
	#DRAW_FIRST_ROW_OF_LAVA
	lw $a0, lavay
	mul $a0, $a0, 256
	
	addi $a0, $a0, BASE_ADDRESS
	lw $t0, lavax
	mul $t0, $t0, 4
	add $a0, $a0, $t0
	lw $a1, lavalen
	li $a2, ORANGE
	jal DRAW_PLATFORM
	#DRAW SECOND ROW OF LAVA
	lw $a0, lavay
	addi $a0, $a0, 1
	mul $a0, $a0, 256
	
	addi $a0, $a0, BASE_ADDRESS
	lw $t0, lavax
	mul $t0, $t0, 4
	add $a0, $a0, $t0
	lw $a1, lavalen
	li $a2, ORANGE
	jal DRAW_PLATFORM
	
	lw $a0, lavay
	addi $a0, $a0, 1
	mul $a0, $a0, 256
	
	addi $a0, $a0, BASE_ADDRESS
	lw $t0, lavax
	addi $t0, $t0, 1
	mul $t0, $t0, 4
	add $a0, $a0, $t0
	lw $a1, lavalen
	addi $a1, $a1, -2
	li $a2, YELLOW
	jal DRAW_PLATFORM
	
	#DRAW_GOAL_DESTINATION
	lw $a0, goaly
	mul $a0, $a0, 256
	
	addi $a0, $a0, BASE_ADDRESS
	lw $t0, goalx
	mul $t0, $t0, 4
	add $a0, $a0, $t0
	#LOAD RED INTO A1
	li $a1, WHITE #load red into a1
	li $a2, BLACK
	jal DRAW_GOAL
	
	#RELOOP
	j LEVEL1_LOOP

CHECK_FOR_ENEMY2_COLLISION:
	lw $t0, xPos
	lw $t1, enemy2x
	addi $t1, $t1, -1
	beq $t0, $t1, END
	addi $t1, $t1, 1
	beq $t0, $t1, END
	addi $t1, $t1, 1
	beq $t0, $t1, END
	addi $t1, $t1, 1
	beq $t0, $t1, END
	j AFTER_CHECK_FOR_ENEMY2_COLLISION
#CHECK ON TOP ENEMY
CHECK_ON_TOP_ENEMY:
	lw $t0, xPos
	lw $t1, enemyx
	addi $t1, $t1, -1
	beq $t0, $t1, END
	addi $t1, $t1, 1
	beq $t0, $t1, END
	addi $t1, $t1, 1
	beq $t0, $t1, END
	addi $t1, $t1, 1
	beq $t0, $t1, END
	j AFTER_CHECK_ON_TOP_ENEMY
	
#FLIP_ENEMY_VEL
FLIP_ENEMY_VEL:
	lw $t0, enemyvel
	mul $t0, $t0, -1
	sw $t0, enemyvel
	j AFTER_FLIP_ENEMY_VEL
	
#FLIP_PLATFORM3_VEL
FLIP_PLATFORM3_VEL:
	lw $t0, platform3vel
	mul $t0, $t0, -1
	sw $t0, platform3vel
	j AFTER_FLIP_PLATFORM3_VEL
STOP_AT_FLOOR:
	li $t0,0
	sw $t0, yVel
	li $t0, 58
	sw $t0, yPos
	j CHECK_FOR_LAVA
AFTER_CHECK_FOR_LAVA:
	j CHECK_FOR_WIN
AFTER_CHECK_FOR_WIN:
	j AFTER_STOP_GRAVITY

CHECK_FOR_WIN:
	lw $t0, xPos
	lw $t1, goalx
	beq $t0, $t1, INIT_LEVEL2
	addi $t1, $t1, 2
	beq $t0, $t1, INIT_LEVEL2
	addi $t1, $t1, 2
	beq $t0, $t1, INIT_LEVEL2
	j AFTER_CHECK_FOR_WIN
	
CHECK_FOR_LAVA:
	lw $t0, xPos
	lw $t1, lavax
	beq $t0, $t1, END
	addi $t1, $t1, 2
	beq $t0, $t1, END
	addi $t1, $t1, 2
	beq $t0, $t1, END
	addi $t1, $t1, 2
	beq $t0, $t1, END
	addi $t1, $t1, 2
	beq $t0, $t1, END
	addi $t1, $t1, 2
	beq $t0, $t1, END
	addi $t1, $t1, 2
	beq $t0, $t1, END
	addi $t1, $t1, 2
	beq $t0, $t1, END
	addi $t1, $t1, 2
	beq $t0, $t1, END
	addi $t1, $t1, 2
	beq $t0, $t1, END
	addi $t1, $t1, 2
	beq $t0, $t1, END
	addi $t1, $t1, 2
	beq $t0, $t1, END
	addi $t1, $t1, 2
	beq $t0, $t1, END
	addi $t1, $t1, 2
	beq $t0, $t1, END
	addi $t1, $t1, 2
	beq $t0, $t1, END
	addi $t1, $t1, 2
	beq $t0, $t1, END
	addi $t1, $t1, 2
	beq $t0, $t1, END
	addi $t1, $t1, 2
	beq $t0, $t1, END
	addi $t1, $t1, 2
	beq $t0, $t1, END
	addi $t1, $t1, 2
	beq $t0, $t1, END
	addi $t1, $t1, 2
	beq $t0, $t1, END

	j AFTER_CHECK_FOR_LAVA
keypress_happened:
	lw $t3, 0xffff0004		# get keypress from keyboard input
	beq $t3, 100, CHECK_RIGHT
	beq $t3, 97, CHECK_LEFT
	beq $t3, 119, CHECK_JUMP
	beq $t3, 112, INIT_LEVEL1
	j AFTER_CHECK_KEYPRESS

#CHECK RIGHT
CHECK_RIGHT:
	lw $t0, xPos
	blt $t0, 62, MOVE_RIGHT
	j AFTER_MOVE
	
#MOVE RIGHT
MOVE_RIGHT:
	li $t0, 2
	sw $t0, xVel
	j AFTER_MOVE
#CHECK_LEFT
CHECK_LEFT:
	lw $t0, xPos
	bgt $t0, 0, MOVE_LEFT
	j AFTER_MOVE
#MOVE LEFT
MOVE_LEFT:
	li $t0, -2
	sw $t0, xVel
	j AFTER_MOVE

CHECK_JUMP:
	lw $t0, yPos
	beq $t0, 58, JUMP
	beq $t0, 53, CHECK_FOR_PLATFORM1_JUMP
	beq $t0, 49, CHECK_FOR_PLATFORM2AND3_JUMP
	j AFTER_MOVE
#CHECK_UP
JUMP:
	li $t0, -5
	sw $t0, yVel
	j AFTER_MOVE


#MAKE_JUMP_TRUE

END:
	li $t0, BASE_ADDRESS
	addi $t1, $t0, 16384
	li $t2, RED
	
end_screen_loop:
	
	beq $t0, $t1, TERMINATE
	sw $t2, 0($t0)
	addi $t0, $t0, 4
	j end_screen_loop
	
WIN:

	li $t0, BASE_ADDRESS
	addi $t1, $t0, 16384
	li $t2, GREEN
	
win_screen_loop:
	
	beq $t0, $t1, TERMINATE
	sw $t2, 0($t0)
	addi $t0, $t0, 4
	j win_screen_loop
	
TERMINATE:
	li $v0, 10
	syscall
#CHECK_FOR_PLATFORM1
#declaration of the DRAW_BACKGROUND function
DRAW_GROUND:
	addi $a2, $a0, 768
draw_background_loop:
	beq $a0, $a2, end_background_loop
	sw $a1, 0($a0)
	addi $a0, $a0, 4
	j draw_background_loop

end_background_loop:
	jr $ra
#declaration of DRAW_SKY
DRAW_SKY:
	addi $a2, $a0, 15872
draw_sky_loop:
	beq $a0, $a2, end_draw_sky_loop
	sw $a1, 0($a0)
	addi $a0, $a0, 4
	j draw_sky_loop
	
end_draw_sky_loop:
	jr $ra
#declaratin of the DRAW_CHARACTER function
DRAW_CHARACTER:
	sw $a1, 0($a0)
	sw $a1, 4($a0)
	sw $a1, 256($a0)
	sw $a1, 260($a0)
	sw $a1, 512($a0)
	sw $a1, 516($a0)
	
	jr $ra

#DRAW_PLATFORM
DRAW_PLATFORM:
	#location in a0
	#length in a1
	#color in a2
	mul $t0, $a1, 4
	add $t0, $a0, $t0
DRAW_PLATFORM_LOOP:
	beq $t0, $a0, END_DRAWING_PLATFORM_LOOP
	sw $a2, 0($a0)
	addi $a0, $a0, 4
	j DRAW_PLATFORM_LOOP
	
END_DRAWING_PLATFORM_LOOP:
	jr $ra
	
CHECK_FOR_COLLISIONS:
	lw $t0, yPos
	bge $t0, 57, STOP_AT_FLOOR
	bge $t0, 53, CHECK_FOR_PLATFORM1
AFTER_CHECK_PLATFORM1:
	bge $t0, 49, CHECK_FOR_PLATFORM2AND3
AFTER_CHECK_PLATFORM2AND3:
	bge $t0, 47, CHECK_ON_TOP_ENEMY
AFTER_CHECK_ON_TOP_ENEMY:
	j AFTER_STOP_GRAVITY
	
CHECK_FOR_PLATFORM1:
	lw $t0, xPos
	beq $t0, 8, STOP_AT_PLATFORM1
	beq $t0, 10, STOP_AT_PLATFORM1
	beq $t0, 12, STOP_AT_PLATFORM1
	beq $t0, 14, STOP_AT_PLATFORM1
	j AFTER_CHECK_PLATFORM1
	
CHECK_FOR_PLATFORM2AND3:
	lw $t0, xPos
	beq $t0, 18, STOP_AT_PLATFORM2
	beq $t0, 20, STOP_AT_PLATFORM2
	beq $t0, 22, STOP_AT_PLATFORM2
	beq $t0, 24, STOP_AT_PLATFORM2
	beq $t0, 26, STOP_AT_PLATFORM2
	beq $t0, 28, STOP_AT_PLATFORM2
	beq $t0, 30, STOP_AT_PLATFORM2
	beq $t0, 32, STOP_AT_PLATFORM2
	
	lw $t1, platform3x
	addi $t1, $t1, -1
	beq $t0, $t1, STOP_AT_PLATFORM2
	addi $t1, $t1, 1
	beq $t0, $t1, STOP_AT_PLATFORM2
	addi $t1, $t1, 1
	beq $t0, $t1, STOP_AT_PLATFORM2
	addi $t1, $t1, 1
	beq $t0, $t1, STOP_AT_PLATFORM2
	addi $t1, $t1, 1
	beq $t0, $t1, STOP_AT_PLATFORM2
	addi $t1, $t1, 1
	beq $t0, $t1, STOP_AT_PLATFORM2
	addi $t1, $t1, 1
	beq $t0, $t1, STOP_AT_PLATFORM2
	addi $t1, $t1, 1
	beq $t0, $t1, STOP_AT_PLATFORM2
	addi $t1, $t1, 1
	beq $t0, $t1, STOP_AT_PLATFORM2
	
	j AFTER_CHECK_PLATFORM2AND3

STOP_AT_PLATFORM1:
	li $t0,0
	sw $t0, yVel
	li $t0, 53
	sw $t0, yPos
	j AFTER_CHECK_PLATFORM1
	
STOP_AT_PLATFORM2:
	li $t0,0
	sw $t0, yVel
	li $t0, 49
	sw $t0, yPos
	
	#check for collision with enemy
	
	j AFTER_CHECK_PLATFORM2AND3

CHECK_FOR_PLATFORM1_JUMP:
	lw $t0, xPos
	beq $t0, 8, JUMP
	beq $t0, 10, JUMP
	beq $t0, 12,JUMP
	beq $t0, 14, JUMP
	j AFTER_MOVE
	
CHECK_FOR_PLATFORM2AND3_JUMP:
	lw $t0, xPos
	beq $t0, 18, JUMP
	beq $t0, 20, JUMP
	beq $t0, 22, JUMP
	beq $t0, 24, JUMP
	beq $t0, 26, JUMP
	beq $t0, 28, JUMP
	beq $t0, 30, JUMP
	beq $t0, 32, JUMP
	
	lw $t1, platform3x
	addi $t1, $t1, -1
	beq $t0, $t1, JUMP
	addi $t1, $t1, 1
	beq $t0, $t1, JUMP
	addi $t1, $t1, 1
	beq $t0, $t1, JUMP
	addi $t1, $t1, 1
	beq $t0, $t1, JUMP
	addi $t1, $t1, 1
	beq $t0, $t1, JUMP
	addi $t1, $t1, 1
	beq $t0, $t1, JUMP
	addi $t1, $t1, 1
	beq $t0, $t1, JUMP
	addi $t1, $t1, 1
	beq $t0, $t1, JUMP
	addi $t1, $t1, 1
	beq $t0, $t1, JUMP
	j AFTER_MOVE
	
#DRAW_ENEMY
DRAW_ENEMY:
	#location in a0
	#color in a1
	sw $a1, 0($a0)
	sw $a1, 8($a0)
	sw $a1, 260($a0)
	sw $a1, 512($a0)
	sw $a1, 520($a0)
	
	jr $ra
	
#DRAW_GOAL
DRAW_GOAL:
	#location in a0
	#white in a1
	#black in a2
	sw $a1, 0($a0)
	sw $a2, 4($a0)
	sw $a1, 8($a0)
	sw $a2, 12($a0)
	sw $a1, 16($a0)
	sw $a2, 20($a0)
	
	sw $a2, 256($a0)
	sw $a1, 260($a0)
	sw $a2, 264($a0)
	sw $a1, 268($a0)
	sw $a2, 272($a0)
	sw $a1, 276($a0)
	
	jr $ra


#LEVEL 2
#LEVEL 2
#LEVEL 2
#LEVEL 2
#LEVEL 2
#LEVEL 2





INIT_LEVEL2:
	li $t0, 0
	sw $t0, xPos
	sw $t0, xVel
	sw $t0, lvl2_plat_counter
	
	sw $t1, yVel
	li $t0, 1
	sw $t0, lvl2_plat_vis
	li $t0, 59
	sw $t0, yPos
	
	
	
	j LEVEL_2_LOOP

SWITCH_VIS:
	li $t0, 0
	sw $t0, lvl2_plat_counter
 
	lw $t0, lvl2_plat_vis
	li $t1, 1
	mul $t0, $t0, -1
	add $t1, $t0, $t1
	sw $t1, lvl2_plat_vis
	j AFTER_SWITCH_VIS
LEVEL_2_LOOP:
	lw $t0, lvl2_plat_counter
	addi $t0, $t0, 1
	sw $t0, lvl2_plat_counter
	beq $t0, 100, SWITCH_VIS
AFTER_SWITCH_VIS:
	addi	$v0, $zero, 32	# syscall sleep
	addi	$a0, $zero, 100	# 66 ms
	syscall
	
	#if falling check for collisions
	lw $t0, yVel
	bgt $t0, 0, check_for_collisions2
	
	#after_check_collision
after_collisions:
	#READ KEYPRESS
	li $t9, 0xffff0000  
	lw $t8, 0($t9)
	beq $t8, 1, keypress_happened_level2
after_check_keypress2:
AFTER_MOVE_2:
	#CALL DRAW_GROUND
	li $a0, GROUND_LOCATION #load base address into a0
	addi $a0, $a0, BASE_ADDRESS
	li $a1, BLACK #load 
	jal DRAW_GROUND

	#call DRAW_SKY
	li $a0, BASE_ADDRESS
	li $a1, 0x808080
	jal DRAW_SKY
	
	#DRAW_LAVA
	#DRAW_FIRST_ROW_OF_LAVA
	lw $a0, lavay
	mul $a0, $a0, 256
	
	addi $a0, $a0, BASE_ADDRESS
	lw $t0, lavax
	mul $t0, $t0, 4
	add $a0, $a0, $t0
	lw $a1, lavalen
	li $a2, ORANGE
	jal DRAW_PLATFORM
	#DRAW SECOND ROW OF LAVA
	lw $a0, lavay
	addi $a0, $a0, 1
	mul $a0, $a0, 256
	
	addi $a0, $a0, BASE_ADDRESS
	lw $t0, lavax
	mul $t0, $t0, 4
	add $a0, $a0, $t0
	lw $a1, lavalen
	li $a2, ORANGE
	jal DRAW_PLATFORM
	
	lw $a0, lavay
	addi $a0, $a0, 1
	mul $a0, $a0, 256
	
	addi $a0, $a0, BASE_ADDRESS
	lw $t0, lavax
	addi $t0, $t0, 1
	mul $t0, $t0, 4
	add $a0, $a0, $t0
	lw $a1, lavalen
	addi $a1, $a1, -2
	li $a2, YELLOW
	jal DRAW_PLATFORM
 	#move the character x
 	lw $t0, xVel
 	lw $t1, xPos
 	add $t1, $t1, $t0
 	sw $t1, xPos
 	#move the character y
	lw $t0, yVel
	addi $t0, $t0, 1
	sw $t0, yVel
	
	lw $t1, yPos
	add $t1, $t1, $t0
	sw $t1, yPos
	#call DRAW_CHARACTER
	#LOAD CHARACTER LOCATION IN A0
	lw $a0, yPos
	mul $a0, $a0, 256
	
	addi $a0, $a0, BASE_ADDRESS
	lw $t0, xPos
	mul $t0, $t0, 4
	add $a0, $a0, $t0
	#LOAD RED INTO A1
	li $a1, 0xff0000 #load red into a1
	jal DRAW_CHARACTER
	
	li $t0, 0
	sw $t0, xVel
	
	#DRAW_GOAL_DESTINATION
	lw $a0, goaly
	mul $a0, $a0, 256
	
	addi $a0, $a0, BASE_ADDRESS
	lw $t0, goalx
	mul $t0, $t0, 4
	add $a0, $a0, $t0
	#LOAD RED INTO A1
	li $a1, WHITE #load red into a1
	li $a2, BLACK
	jal DRAW_GOAL
	
		#call DRAW_PLATFORM on platform1
	lw $t0, lvl2_plat_vis
	beq $t0, 1, DRAW_PLAT
AFTER_DRAW_PLAT:
	j LEVEL_2_LOOP

DRAW_PLAT:
	lw $a0, lvl2_plat_y
	mul $a0, $a0, 256
	
	addi $a0, $a0, BASE_ADDRESS
	lw $t0, lvl2_plat_x
	mul $t0, $t0, 4
	add $a0, $a0, $t0
	lw $a1, lvl2_plat_len
	li $a2, BLACK
	jal DRAW_PLATFORM
	j AFTER_DRAW_PLAT
keypress_happened_level2:
	lw $t3, 0xffff0004		# get keypress from keyboard input
	beq $t3, 100, CHECK_RIGHT2
	beq $t3, 97, CHECK_LEFT2
	beq $t3, 119, CHECK_JUMP2
	beq $t3, 112, INIT_LEVEL1
	j after_check_keypress2
	
CHECK_RIGHT2:
	lw $t0, xPos
	blt $t0, 62, MOVE_RIGHT2
	j AFTER_MOVE_2
	
MOVE_RIGHT2:
	li $t0, 2
	sw $t0, xVel
	j AFTER_MOVE_2

CHECK_LEFT2:
	lw $t0, xPos
	bgt $t0, 0, MOVE_LEFT2
	j AFTER_MOVE_2
	
MOVE_LEFT2:
	li $t0, -2
	sw $t0, xVel
	j AFTER_MOVE_2

CHECK_JUMP2:
	lw $t0, yPos
	beq $t0, 58, JUMP2
	beq $t0, 53, CHECK_FOR_PLATFORM_JUMP
AFTER_JUMP2:
	

	j AFTER_MOVE_2

CHECK_FOR_PLATFORM_JUMP:
	lw $t0, lvl2_plat_vis
	beq $t0, 1, JUMP2
	j AFTER_JUMP2

JUMP2:
	li $t0, -5
	sw $t0, yVel
	j AFTER_JUMP2
check_for_collisions2:
	lw $t0, yPos
	bge $t0, 58, stop_at_rock
after_check_for_lava2:
	bge $t0, 53, check_for_platform_visible
after_stop_at_plat:
	bge $t0, 57, check_for_win2
AFTER_CHECK_FOR_WIN2:
	j after_collisions

check_for_win2:
	lw $t0, xPos
	lw $t1, goalx
	beq $t0, $t1, WIN
	addi $t1, $t1, 2
	beq $t0, $t1, WIN
	addi $t1, $t1, 2
	beq $t0, $t1, WIN
	j AFTER_CHECK_FOR_WIN2

check_for_platform_visible:
	lw $t0, lvl2_plat_vis
	beq $t0, 1, check_for_platform
	j after_stop_at_plat
	
check_for_platform:
	lw $t0, xPos
	lw $t1, lvl2_plat_x
	beq $t0, $t1, stop_at_plat
	addi $t1, $t1, 2
	beq $t0, $t1, stop_at_plat
	addi $t1, $t1, 2
	beq $t0, $t1, stop_at_plat
	addi $t1, $t1, 2
	beq $t0, $t1, stop_at_plat
	addi $t1, $t1, 2
	beq $t0, $t1, stop_at_plat
	addi $t1, $t1, 2
	beq $t0, $t1, stop_at_plat
	addi $t1, $t1, 2
	beq $t0, $t1, stop_at_plat
	addi $t1, $t1, 2
	beq $t0, $t1, stop_at_plat
	addi $t1, $t1, 2
	beq $t0, $t1, stop_at_plat
	addi $t1, $t1, 2
	beq $t0, $t1, stop_at_plat
	addi $t1, $t1, 2
	beq $t0, $t1, stop_at_plat
	addi $t1, $t1, 2
	beq $t0, $t1, stop_at_plat
	addi $t1, $t1, 2
	beq $t0, $t1, stop_at_plat
	addi $t1, $t1, 2
	beq $t0, $t1, stop_at_plat
	addi $t1, $t1, 2
	beq $t0, $t1, stop_at_plat
	addi $t1, $t1, 2
	beq $t0, $t1, stop_at_plat
	addi $t1, $t1, 2
	beq $t0, $t1, stop_at_plat
	addi $t1, $t1, 2
	beq $t0, $t1, stop_at_plat
	addi $t1, $t1, 2
	beq $t0, $t1, stop_at_plat
	addi $t1, $t1, 2
	beq $t0, $t1, stop_at_plat
	addi $t1, $t1, 2
	beq $t0, $t1, stop_at_plat
	j after_stop_at_plat
	
stop_at_plat:
	li $t0,0
	sw $t0, yVel
	li $t0, 53
	sw $t0, yPos
	j after_stop_at_plat
stop_at_rock:
	li $t0,0
	sw $t0, yVel
	li $t0, 58
	sw $t0, yPos
	j CHECK_FOR_LAVA2

CHECK_FOR_LAVA2:
	lw $t0, xPos
	lw $t1, lavax
	beq $t0, $t1, END
	addi $t1, $t1, 2
	beq $t0, $t1, END
	addi $t1, $t1, 2
	beq $t0, $t1, END
	addi $t1, $t1, 2
	beq $t0, $t1, END
	addi $t1, $t1, 2
	beq $t0, $t1, END
	addi $t1, $t1, 2
	beq $t0, $t1, END
	addi $t1, $t1, 2
	beq $t0, $t1, END
	addi $t1, $t1, 2
	beq $t0, $t1, END
	addi $t1, $t1, 2
	beq $t0, $t1, END
	addi $t1, $t1, 2
	beq $t0, $t1, END
	addi $t1, $t1, 2
	beq $t0, $t1, END
	addi $t1, $t1, 2
	beq $t0, $t1, END
	addi $t1, $t1, 2
	beq $t0, $t1, END
	addi $t1, $t1, 2
	beq $t0, $t1, END
	addi $t1, $t1, 2
	beq $t0, $t1, END
	addi $t1, $t1, 2
	beq $t0, $t1, END
	addi $t1, $t1, 2
	beq $t0, $t1, END
	addi $t1, $t1, 2
	beq $t0, $t1, END
	addi $t1, $t1, 2
	beq $t0, $t1, END
	addi $t1, $t1, 2
	beq $t0, $t1, END
	addi $t1, $t1, 2
	beq $t0, $t1, END

	j after_check_for_lava2
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
