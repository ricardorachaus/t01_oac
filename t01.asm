.data
	menu_text: .asciiz "Choose a option:\n1 - Read image\n2 - Save image\n3 - Blur effect\n4 - Edge Extractor\n5 - Thresholding\n6 - Exit\n\n>> "
	invalid_option: .asciiz "\nOption selected is invalid! Try another.\n"
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

save_img:

blur_effect:

edge_extractor:

thresholding:

exit:
	li $v0, 10
	syscall