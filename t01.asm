.data

menu_text: .asciiz "Choose a option:\n1 - Read image\n2 - Save image\n3 - Blur effect\n4 - Edge Extractor\n5 - Thresholding\n6 - Exit\n\n>> "
invalid_option: .asciiz "\nOption selected is invalid! Try another.\n"

img_name: .asciiz "img.bmp"
header: .space 54

open_error_msg: .asciiz "Error opening the file.\n"
read_error_msg: .asciiz "Error reading the file.\n"
	
.text

main:

	# Print the menu text to the screen
	la $a0, menu_text
	li $v0, 4
	syscall
	
	# Read the integer of the selected option
	li $v0, 5
	syscall
	
	# Go to option choosed
	move $t0, $v0
	beq $t0, 1, read_img
	beq $t0, 2, save_img
	beq $t0, 3, blur_effect
	beq $t0, 4, edge_extractor
	beq $t0, 5, thresholding
	beq $t0, 6, exit
	
	# If is choosen a invalid option, go back to menu
	la $a0, invalid_option
	li $v0, 4
	syscall
	j main
	
read_img:

	# Open the file
	li $v0, 13
	la $a0, img_name
	la $a1, 0
	la $a2, 0
	syscall
	blt $v0, $zero, open_file_error		# Check if there is a error opening.
	
	# Read the image
	move $a0, $v0
	li $v0, 14
	la $a1, header
	la $a2, 54
	syscall
	blt $v0, $zero, read_file_error		# Check if there is a error reading.
	
	# Store the width
	lw 		$s7, header + 18
	mul		$s7, $s7, 3
	
	# Store the height
	lw		$s4, header + 22
	# Store the size of the data
	lw		$s1, header + 34
	
	# Allocate memory in heap
	#li $v0, 9
	#move $a0, $s1
	#syscall
	
	j main

save_img:
	j main

blur_effect:
	j main

edge_extractor:
	j main
	
thresholding:
	j main

# Print message for error in opening file
open_file_error:
	la $a0, open_error_msg
	jal print_str
	j main
	
	
# Print message for error in reading file
read_file_error:
	la $a0, read_error_msg
	jal print_str
	j main
	
# Print any string stored in $a0
print_str:
	li $v0, 4
	syscall
	jr $ra

# Exit the program
exit:
	li $v0, 10
	syscall
