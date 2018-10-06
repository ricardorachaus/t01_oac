.data 0x10000000

menu_text: .asciiz "Choose a option:\n1 - Read image\n2 - Save image\n3 - Blur effect\n4 - Edge Extractor\n5 - Thresholding\n6 - Exit\n\n>> "
invalid_option: .asciiz "\nOption selected is invalid! Try another.\n"
threshold_text: .asciiz "\nDigite um valor entre 0 e 255"

img_name: .asciiz "img.bmp"
type: .space 2
	.align 2
size: .space 6
	.align 2
width: .space 4
height: .space 4
trash: .space 30

open_error_msg: .asciiz "Error opening the file.\n"
read_error_msg: .asciiz "Error reading the file.\n"

debug_msg: .asciiz "Error!\n"
	
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
	
	# Read the image for type
	move $a0, $v0
	move $s0, $v0
	li $v0, 14
	la $a1, type
	la $a2, 2
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
	lw $s3, width
	lw $s4, height
	mul $t1, $s3, $s4
	mul $t1, $t1, 4
	
	# Allocate image size in the heap
	li $v0, 9
	move $a0, $t1
	syscall
	
	# Stores the heap address
	move $s1, $v0
	
	# Calculate heap size of information
	ld $t1, size
	addi $t1, $t1, -54 # Image size without header
	sd $t1, size
	
	# Allocate size of the information
	li $v0, 9
	move $a0, $t1
	syscall
	
	# Stores the information address
	move $s2, $v0

	j load_image_to_be_display

	j main

# Load the image by each pixel to be displayed.
load_image_to_be_display:
	# Handle the width data of the image
	move $t5, $s3
	mulu $t0, $s3, 3
	add $t1, $t0, $t0

	# Calculate the pixels in image
	mulu $t2, $s3, $s4
	mulu $t3, $t2, 4
	move $s5, $t3

	# Handle the height data of the image
	mulu $t2, $s3, $s4
	mulu $t3, $t2, 3
	move $t2, $s2
	addu $t2, $t3, $t2

	# Read what remains of the image
	li $v0, 14
	move $a0, $s0
	move $a2, $t3
	move $a1, $s2
	syscall

	move $t3, $s4 # Columns quantity
	move $t4, $s1
	subu $t2, $t2, $t0

	j read_column

# Change to 4 bytes and store image
read_column: 	beqz $t5, read_row
	jal read_pixel
	sw $t6, ($t4)
	addi $t4, $t4, 4
	addi $t2, $t2, 3
	addi $t5, $t5, -1
	j read_column
		
# Change to next row
read_row:
	beqz $t3, main
	sub $t2, $t2, $t1
	move $t5, $s3
	addi $t3, $t3, -1
	j read_column

# Read each pixel
read_pixel:
	move $t6, $zero
	lbu $t6, ($t2)
	lbu $t8, 1($t2)
	sll $t8, $t8, 8
	or $t6, $t6, $t8
	lbu $t8, 2($t2)
	sll $t8, $t8, 16
	or $t6, $t6, $t8
	jr $ra

save_img:
	j main

blur_effect:
	j main

edge_extractor:
	j main
	
thresholding:
	#Will read the image from $a0, which is $gp int this case, and will apply the invert colors filter.
	#The equation being used is:
	#		I = 0,2989*R + 0,5870*G + 0,1140*B		
	#	Use: $a0 and $a1 which are the image properties and data, respectively.		
	add $a0, $s1, $zero
	la $a1, 0x10008000
	#add $a1, $s2, $zero
	jal greyScale
	#j menuOptsScr
	#end invertColorsCall
	j main
	
greyScale:
	#	Register usage:
	#		t0: data info address backup
	#		t1: data address backup
	#		t2: screen iterative address beggining by 0x10008000
	#			t3(temporary): height of the image
	#			t4(temporary): width of the image
	#		t3: max number of iterations
	#		t4: iterative index
	#		t5: image byte
	

	add $t0, $a0, $zero
	add $t1, $a1, $zero
	

	la $t2, 0x10008000		#t2: screen start address (iterative)

	lw $t3, height			
	lw $t4, width			
	mul $t3, $t3, $t4

	li $t4, 1				#t4: iterative index

	loop_greyScale:
		beq $t3, $t4, end_loop_greyScale
		lbu $t5, 0($t2)
		mul $t5, $t5, 1140
		div $t5, $t5, 10000
		lbu $t6, 1($t2)	 
		mul $t6, $t6, 5870
		div $t6, $t6, 10000
		#sll $t6, $t6, 8
		add $t5, $t5, $t6
		lbu $t7, 2($t2)	
		mul $t7, $t7, 2989
		div $t7, $t7, 10000		
		#sll $t7, $t7, 16
		add $t5, $t5, $t7

		add $t6, $t5, $zero
		sll $t6, $t6, 8
		add $t7, $t5, $zero
		sll $t7, $t7, 16

		add $t5,$t5, $t6
		add $t5,$t5, $t7

		sw $t5, 0($t2)

		add $t2, $t2, 4
		add $t4, $t4, 1
		j loop_greyScale
	end_loop_greyScale:		
	#end	

	jr $ra

#end greyScale

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
	
# Print any integer stored in $a0
print_int:
	li $v0, 1
	syscall
	jr $ra

debug:
	li $v0, 4
	la $a0, debug_msg
	syscall
	jr $ra

# Exit the program
exit:
	li $v0, 10
	syscall
