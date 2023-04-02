#                         ICS 51, Lab #4
#
#      IMPORTANT NOTES:
#
#      Write your assembly code only in the marked blocks.
#
#      DO NOT change anything outside the marked blocks.
#
###############################################################
#                           Text Section
.text

###############################################################
###############################################################
#                       PART 1 (Image Thresholding)
#a0: input buffer address
#a1: output buffer address
#a2: image dimension (Image will be square sized, i.e., number of pixels = a2*a2)
#a3: threshold value 
###############################################################
threshold:
############################## Part 1: your code begins here ###
li $t1, 0xFF # maximum value
li $t2, 0x00 # minimum value
li $t3, -1 # i

threshold_outer_loop:
addi $t3, $t3, 1 # ++i
beq $t3, $a2, exit_threshold_outer_loop
li $t4, 0 # j

	threshold_inner_loop:
	beq $t4, $a2, threshold_outer_loop
	mul $t5, $t3, $a2 # row_index * num_of_columns
	add $t5, $t5, $t4 # offset = $t5 + col_index
	addi $t4, $t4, 1 # ++j
	add $t7, $a0, $t5 # get elemAddr
	lbu $t6, 0($t7) # get elem
	add $t8, $a1, $t5
	blt $t6, $a3, if_pixel_ble_thresold
	sb $t1, ($t8)
	j threshold_inner_loop
	if_pixel_ble_thresold:
	sb $t2, 0($t8)
	j threshold_inner_loop

exit_threshold_outer_loop:
move $v0, $a1
############################## Part 1: your code ends here ###
jr $ra

###############################################################
###############################################################
#                           PART 2 (Matrix Transform)
#a0: input buffer address
#a1: output buffer address
#a2: transform matrix address
#a3: image dimension  (Image will be square sized, i.e., number of pixels = a3*a3)
###############################################################
transform:
############################### Part 2: your code begins here ##
li $t1, -1 # i
transform_outer_loop:
addi $t1, $t1, 1 # ++i
bge $t1, $a3, exit_transform_outer_loop
li $t2, 0 # j	
	transform_inner_loop:
	bge $t2, $a3, transform_outer_loop
	# How to get target_element_addr in 2D Array?
	# 1. offset = row_index * num_of_columns + col_index
	# 2. offset_by_element_size_in_bytes = offset * element_size_in_bytes
	# 3. target_element_addr = base_addr + offset_by_element_size_in_bytes
###############################################################
	# Get y0 -> row_index of input buffer:
	# y0 = (M10 * col_index) + (M11 * row_index) + M12
	# 	1. get M10 * col_index:
	# 		1. offset = 1 * 3 + 0 = 3
	#		2. offset_by_word = 3 * 4 = 12
	lw $t3, 12($a2) # M10
	mul $t3, $t3, $t2 # M10 * col_index
	# |
	# V
	# 	2. get M11 * row_index
	# 		1. offset = 1 * 3 + 1 = 4 
	#		2. offset_by_word = 4 * 4 = 16
	lw $t4, 16($a2) # M11
	mul $t4, $t4, $t1 # M11 * row_index
	
	# |
	# V
	#	3. get M12:
	#		1. offset = 1 * 3 + 2 = 5
	#		2. offset_by_word = 5 * 4 = 20
	lw $t5, 20($a2) # M12
	# |
	# V
	#	4. (M10 * col_index) + (M11 * row_index):
	add $t6, $t3, $t4
	# |
	# V
	#	5. And then + M12:
	add $t6, $t6, $t5 # y0
	bge $t6, $a3, set_output_elem_zero # if y0 >= total_rows
	blt $t6, $zero, set_output_elem_zero # if y0 < 0
###############################################################
	# Get x0 -> col_index of input buffer:
	# x0 = (M00 * col_index) + (M01 * row_index) + M02
	# 	1. get M00 * col_index:
	# 		1. offset = 0 * 3 + 0 = 0
	#		2. offset_by_word = 0 * 4 = 0
	lw $t3, 0($a2) # M00
	mul $t3, $t3, $t2 # M00 * col_index
	# |
	# V
	# 	2. get M01 * row_index
	# 		1. offset = 0 * 3 + 1 = 1
	#		2. offset_by_word = 1 * 4 = 4
	lw $t4, 4($a2) # M01
	mul $t4, $t4, $t1 # M01 * row_index
	# |
	# V
	#	3. get M02:
	#		1. offset = 0 * 3 + 2 = 2
	#		2. offset_by_word = 2 * 4 = 8
	lw $t5, 8($a2)
	# |
	# V
	#	4. (M00 * col_index) + (M01 * row_index):
	add $t7, $t3, $t4
	# |
	# V
	#	5. And then +M02:
	add $t7, $t7, $t5 # x0
	bge $t7, $a3, set_output_elem_zero # if x0 >= total_rows
	blt $t7, $zero, set_output_elem_zero # if x0 < 0
###############################################################
	# Get (y0, x0) elem in intput buffer:
	mul $t3, $t6, $a3
	add $t3, $t3, $t7
	add $t4, $a0, $t3
	lbu $t3, 0($t4)
	j add_elem_to_input_buffer
	
	set_output_elem_zero:
	li $t3, 0
	
	add_elem_to_input_buffer:
	# Get (i, j) address in output buffer:
	mul $t4, $t1, $a3
	add $t4, $t4, $t2
	add $t4, $a1, $t4
	sb $t3, 0($t4)
	addi $t2, $t2, 1 # ++j
	j transform_inner_loop
	
exit_transform_outer_loop:
move $v0, $a1
############################### Part 2: your code ends here  ##
jr $ra
###############################################################
