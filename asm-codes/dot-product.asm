# Dot Product Calculator
# Computes the dot product of two 4-element vectors
# Vector A stored at word addresses 0, 1, 2, 3
# Vector B stored at word addresses 4, 5, 6, 7
# Result stored in register $s6

# Initialize vector pointers
addi $s0, $0, 0      # $s0 = base address of Vector A (starts at word 0)
addi $s1, $0, 16      # $s1 = base address of Vector B (starts at word 4)

# Initialize loop control variables
addi $s2, $0, 4      # $s2 = loop limit (4 elements to process)
addi $s3, $0, 0      # $s3 = loop counter (current element index)
addi $s6, $0, 0      # $s6 = accumulator for dot product result

loop:
    # Load current elements from both vectors
    lw $s4, 0($s0)       # $s4 = A[i] (load from Vector A)
    lw $s5, 0($s1)       # $s5 = B[i] (load from Vector B)
    
    # Compute element-wise product
    mul $t0, $s4, $s5    # $t0 = A[i] * B[i]
    
    # Add to running sum
    add $s6, $s6, $t0    # $s6 += A[i] * B[i] (accumulate dot product)

    # Move to next elements
    addi $s0, $s0, 4     # Increment Vector A pointer to next word
    addi $s1, $s1, 4     # Increment Vector B pointer to next word
    addi $s3, $s3, 1     # Increment loop counter

    # Check if all elements processed
    beq $s3, $s2, exit   # If counter == 4, exit loop
    jmp loop             # Otherwise, continue with next iteration

exit:
    # Dot product result is now stored in $s6
    # Program ends here