.data

menu_text: .asciiz "Choose a option:\n1 - Read image\n2 - Save image\n3 - Blur effect\n4 - Edge Extractor\n5 - Thresholding\n6 - Exit\n\n>> "
invalid_option: .asciiz "\nOption selected is invalid! Try another.\n"

img_name: .asciiz "img.bmp"
header: .space 54
size: .space 5
width: .space 4
height: .space 4
trash: .space 30

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
	
	# Get image size
	li $v0, 14
	la $a1, size
	li $a2, 4
	syscall
	
	# Trash to be ignored from header
	li $v0, 14
	la $a1, trash
	li $a2, 12
	syscall
	
	# Get image width
	li $v0, 14
	la $a1, width
	li $a2, 4
	syscall
	
	# Get image height
	li $v0, 14
	la $a1, height
	li $a2, 4
	syscall
	
	# Trash to be ignored
	li $v0, 14
	la $a1, trash
	li $a2, 28
	syscall
	
	# Calculate image size by width x height
	# lw $s3, width
	# lw $s4, height
	# mul $t1, $s3, $s4
	# mul $t1, $t1, 4
	
	# # Allocate image size in the heap
	# li $v0, 9
	# move $a0, $t1
	# syscall
	
	# # Stores the heap address
	# move $s1, $v0
	
	# # Calculate heap size of information
	# ld $t1, size
	# addi $t1, $t1, -54 # Image size without header
	# sd $t1, size
	
	# # Allocate size of the information
	# li $v0, 9
	# move $a0, $t1
	# syscall
	
	# # Stores the information addres
	# move $s2, $v0

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
