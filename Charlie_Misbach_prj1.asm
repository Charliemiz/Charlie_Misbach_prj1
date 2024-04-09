# Name: Charlie Misbach
# Student ID: 26157996
# All memory structures are placed after the

# .data assembler directive
.data
# change these array values (and sizes) to test your program
size: .word 12
arr1: .word 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24
arr2: .word 1, 3, 5, 7, 9, 11, 13, 15, 17, 19, 21, 23
output: .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
bufferedarr: .word 1, 3, 5, 7, 9, 11, 13, 15, 17, 19, 21, 23, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
# Declare main as a global function
.globl main
# All program code is placed after the
# .text assembler directive
.text
# The label 'main' represents the starting point
# Main function starts here
main:
    	la $t7, size               # Load the address of 'size' into $t7
    	lw $a3, 0($t7)             # Load the 'size' into $a3
    
    	# Prepare and call the merge function
    	la $a0, arr1               # Load base address of arr1
    	la $a1, arr2               # Load base address of arr2
    	la $a2, output             # Load base address of output
    	jal merge                  # Call merge function
    
    	move $s4, $v0       # Move the count of elements to $t5 for later use
    	li $t0, 0           # Initialize index i for the loop
    
print_loop:
    	bge $t0, $s4, call_merge2    # Exit loop if index >= count
    	sll $t3, $t0, 2       # Calculate offset
    	add $t3, $a2, $t3     # Get address of output[i]
    	lw $a0, 0($t3)        # Load output[i] to $a0
    	li $v0, 1             # syscall to print int
    	syscall
    	# Print a space or newline
    	li $a0, ' '           # ASCII for space
    	li $v0, 11            # syscall to print char
    	syscall
    	addi $t0, $t0, 1      # Increment index
    	j print_loop          # Loop back
    
# Jump here to call merge2
call_merge2:
    	li $v0, 11            # syscall service for printing a character
    	li $a0, 10            # ASCII value for newline ('\n')
    	syscall
    	# Prepare and call the merge2 function
    	la $a0, arr1                # Load base address of arr1
    	la $a1, bufferedarr         # Load base address of bufferedarr
    	jal merge2                  # Call merge2 function

    	# Reset $a0 for printing bufferedarr
    	la $a1, bufferedarr
    	li $t0, 0                   # Reset index i for loop
    	sll $s4, $a3, 1             # Size * 2 for total elements in bufferedarr

    	# Printing loop for bufferedarr array
print_bufferedarr_loop:
        bge $t0, $s4, exit   # Jump to exit if end of array reached
        sll $t3, $t0, 2
        add $t3, $a1, $t3
        lw $a0, 0($t3)
        li $v0, 1
        syscall                    # Print integer
        li $a0, ' '                # Print a space
        li $v0, 11
        syscall
        addi $t0, $t0, 1
        j print_bufferedarr_loop
    
# Exit program
exit:
    	li $v0, 10            # Exit program
    	syscall

merge:	
	# $a0 = address of arr1, $a1 = address of arr2, $a2 = address of output, $a3 = size
	# Initialize loop counters: $t0 for arr1 index, $t1 for arr2 index, $t2 for output index
	
    	addi $sp, $sp, -4           # Make space on the stack for $ra 
    	sw $ra, 0($sp)              # Save $ra
    	
    	move $s0, $a0                # Move arr1 address to $s0
    	move $s1, $a1                # Move arr2 address to $s1
    	move $s2, $a2                # Move output array address to $s2

	li $t0, 0  		# arr1 index i
	li $t1, 0  		# arr2 index j
	li $t2, 0  		# output index cnt
	lw $a3, size 		# Load the size into $a3 for comparison
	
	
	merge_loop:
	bge $t0, $a3, handle_remaining_arr2 # jump if we've processed all arr1 elements, process rest of arr2
    	bge $t1, $a3, handle_remaining_arr1 # jump if we've processed all arr2 elements, process rest of arr1
	
	# Load in arr1 and arr2
	sll $t3, $t0, 2 	# Multiply i * 4
	add $t4, $t3, $s0 	# address of arr1[i] stored in $t4
	sll $t3, $t1, 2		# Multiply j * 4
	add $t5, $t3, $s1	# address of arr2[j] stored in $t5
	
    	# Compare arr1[i] and arr2[j]
    	lw $a0, 0($t4)	  # load address of arr1[i] into argument 0 for compare func
    	lw $a1, 0($t5)     # load address of arr2[j] into argument 1 for compare func
    	jal compare       # Call compare function
    	
    	# load int into $t6 to compare with BEQ
    	li $t6, -1
    	beq $v0, $t6, less_than  # If arr1[i] < arr2[j]
    	
    	li $t6, 1
    	beq $v0, $t6, greater_than_or_equal_to  # If arr1[i] > arr2[j]
    	
    	li $t6, 0
    	beq $v0, $t6, greater_than_or_equal_to  # If arr1[i] == arr2[j]
    	
less_than:
	#  Calculate address of output[cnt]
	sll $t3, $t2, 2 	# Multiply cnt * 4
	add $t3, $s2, $t3	# address of output[cnt]
	sw $a0, 0($t3)		# Store value of arr1[i] in output[cnt]
	
	# Increment i and cnt
    	addi $t0, $t0, 1     # Increment i
    	addi $t2, $t2, 1     # Increment cnt

    	j merge_loop         # Jump back to the start of the loop to process next elements
	
greater_than_or_equal_to:
    	sll $t3, $t2, 2 	# Multiply cnt by 4 for byte offset
	add $t3, $s2, $t3	# Add offset to base address of output
    	
    	sw $a1, 0($t3)       	# Store value of arr2[j] in output[cnt]
    	
    	# Increment j and cnt
    	addi $t1, $t1, 1	# Increment j
    	addi $t2, $t2, 1	# Increment cnt
    	
    	j merge_loop		# Jump back to the start of the loop to process next elements
	
handle_remaining_arr1:
	# Check if there are remaining elements in arr1 before proceeding
	# if there aren't, jump to arr2 handling
    	bge $t0, $a3, handle_remaining_arr2  # If i >= size, all elements in arr1 are processed; proceed to arr2
    	
    	# Calculate address of output[cnt] for arr1[i]
    	sll $t3, $t2, 2          # Multiply cnt by 4 for byte offset
    	add $t3, $s2, $t3        # Add offset to base address of output
	
    	# Load arr1[i] and store in output[cnt]
    	sll $t4, $t0, 2          # Calculate offset for arr1[i]
    	add $t4, $s0, $t4        # Calculate address of arr1[i]
    	lw $t5, 0($t4)           # Load arr1[i] into $t5
    	sw $t5, 0($t3)           # Store arr1[i] into output[cnt]

    	# Increment i and cnt
    	addi $t0, $t0, 1         # Increment i
    	addi $t2, $t2, 1         # Increment cnt

    	j handle_remaining_arr1  # Loop back to check and copy remaining elements in arr1

handle_remaining_arr2:
    	# Check if there are remaining elements in arr2, if so proceed, else jump end
    	bge $t1, $a3, end_merge  # If j >= size, all elements in arr2 are processed; we are done, so jump to end of merge
    	
    	# Calculate address of output[cnt] for arr2[j]
    	sll $t3, $t2, 2          # Multiply cnt by 4 for byte offset
    	add $t3, $s2, $t3        # Add offset to base address of output

    	# Load arr2[j] and store in output[cnt]
    	sll $t4, $t1, 2          # Calculate offset for arr2[j]
    	add $t4, $s1, $t4        # Calculate address of arr2[j]
    	lw $t5, 0($t4)           # Load arr2[j] into $t5
    	sw $t5, 0($t3)           # Store arr2[j] into output[cnt]

   	# Increment j and cnt
    	addi $t1, $t1, 1         # Increment j
    	addi $t2, $t2, 1         # Increment cnt
    	
    	j handle_remaining_arr2  # Loop back to check and copy remaining elements in arr2
    	
end_merge:
    	move $v0, $t2           # Move cnt (total number of elements copied to output) to $v0 for return
    	lw $ra, 0($sp)
    	addi $sp, $sp, 4
    	jr $ra                  # Return from the function
    	
# merge2 function starts here
merge2:
    	addi $sp, $sp, -4                # Make space on the stack for $ra 
    	sw $ra, 0($sp)                   # Save $ra
    
    	move $s0, $a0                    # Move arr1 address to $s0
    	move $s1, $a1                    # Move bufferedarr address to $s1
    	lw $t6, 0($t7)                   # Load size into $t6

    	addi $t0, $t6, -1                # i = size - 1
    	addi $t1, $t6, -1                # j = size - 1
    	sll $t7, $t6, 1                  # t7 = size * 2
    	addi $t2, $t7, -1                # k = (size * 2) - 1

merge2_loop:
    	blt $t1, 0, check_remaining_arr1   # If j < 0, jump to check if any elements are in arr1

    	# Check if i is valid
    	blt $t0, 0, copy_bufferedArr     # If i < 0, if so skip comparing and directly copy bufferedArr[j] to bufferedArr[k]

    	# Calculate addresses for arr1[i] and bufferedArr[j]
    	sll $t3, $t0, 2
    	add $t4, $s0, $t3                # Address of arr1[i]
    	sll $t3, $t1, 2
    	add $t5, $s1, $t3                # Address of bufferedArr[j]

    	# Load values to compare
    	lw $a0, 0($t4)                   # Load arr1[i]
    	lw $a1, 0($t5)                   # Load bufferedArr[j]
	
    	jal compare                      # Compare arr1[i] and bufferedArr[j]

    	# If arr1[i] > bufferedArr[j], copy arr1[i] to bufferedArr[k]
    	blez $v0, copy_bufferedArr
    	sll $t3, $t2, 2
    	add $t3, $s1, $t3                # Address of bufferedArr[k]
    	sw $a0, 0($t3)                   # Store arr1[i] in bufferedArr[k]
    	addi $t0, $t0, -1                # Decrement i

    	j decrement_k                    # Go to decrement k and loop back

copy_bufferedArr:
    	# Copy bufferedArr[j] to bufferedArr[k]
    	sll $t3, $t2, 2
    	add $t3, $s1, $t3                # Address of bufferedArr[k]
    	sw $a1, 0($t3)                   # Store bufferedArr[j] in bufferedArr[k]
    	addi $t1, $t1, -1                # Decrement j

decrement_k:
    	addi $t2, $t2, -1                # Decrement k
    	j merge2_loop                    # Loop back

check_remaining_arr1:
    	blt $t0, 0, end_merge2       # If i < 0, all elements from arr1 are copied, end the loop
	
    	# Calculate address for the remaining arr1[i]
    	sll $t3, $t0, 2
    	add $t4, $s0, $t3            # Address of arr1[i]

    	# Copy remaining arr1[i] to bufferedArr[k]
    	sll $t3, $t2, 2
    	add $t3, $s1, $t3            # Address of bufferedArr[k]
    	lw $t6, 0($t4)               # Load arr1[i]
    	sw $t6, 0($t3)               # Store arr1[i] into bufferedArr[k]

    	addi $t0, $t0, -1            # Decrement i
    	addi $t2, $t2, -1            # Decrement k
    	j check_remaining_arr1       # Continue checking for remaining arr1 elements

end_merge2:
    	lw $ra, 0($sp)                   # Restore $ra
    	addi $sp, $sp, 4                 # Restore the stack pointer
    	jr $ra                           # Return from the function         
    	

# compare function starts here
compare:
    	bgt $a0, $a1, num1_greater    # If num1 > num2, go to num1_greater
    	blt $a0, $a1, num1_less       # If num1 < num2, go to num1_less
	
	li $v0, 0    # Set return value to 0 because nums are equal
	jr $ra       # Return   
	  
num1_less:
	li $v0, -1   # Set return value to -1 because num1 < num2
	jr $ra       # Return

num1_greater:
	li $v0, 1    # Set return value to 1 because num1 > num2
	jr $ra       # Return
