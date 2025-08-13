# MIPS Test Program - Tests all instructions with chained results
# Final register values will verify correct execution

# Register conventions used:
# $t0 - Primary accumulator for test chain
# $t1-$t9 - Temporary values and secondary accumulators
# $s0-$s1 - Constants
# $v0 - Final result register

# Initialize registers with test patterns
addi $zero, $zero, 0    # Ensure $zero is 0 (should be no-op)
addi $t0, $zero, 5      # Starting value = 5
addi $s0, $zero, 10     # Constant = 10
addi $s1, $zero, 3      # Constant = 3

# Test arithmetic operations - building up values
add  $t0, $t0, $s0      # $t0 = 5 + 10 = 15
sub  $t0, $t0, $s1      # $t0 = 15 - 3 = 12
addi $t1, $zero, 4      # $t1 = 4
mul  $t0, $t0, $t1      # $t0 = 12 * 4 = 48

# Test logical operations
addi $t1, $zero, 0xFF   # $t1 = 255 (0xFF)
and  $t0, $t0, $t1      # $t0 = 48 & 255 = 48 (unchanged)
addi $t1, $zero, 0xF0   # $t1 = 240 (0xF0)
or   $t0, $t0, $t1      # $t0 = 48 | 240 = 240 + 48 - 48 = 240 (0xF0)
addi $t1, $zero, 0x33   # $t1 = 51 (0x33)
xor  $t0, $t0, $t1      # $t0 = 0xF0 ^ 0x33 = 0xC3 (195)

# Test shift operations
sll  $t0, $t0, 2        # $t0 = 0xC3 << 2 = 0x30C (780)
addi $t1, $zero, 3      # $t1 = 3
srlv $t0, $t0, $t1      # $t0 = 0x30C >> 3 = 0x61 (97)
sll  $t0, $t0, 8        # $t0 = 0x61 << 8 = 0x6100 (24,832)
srl  $t0, $t0, 4        # $t0 = 0x6100 >> 4 = 0x610 (1,552)
sra  $t0, $t0, 1        # $t0 = 0x610 >> 1 = 0x308 (776)

# Test rotate operations
addi $t1, $zero, 0xAA   # $t1 = 0xAA (170)
or   $t0, $t0, $t1      # $t0 = 0x308 | 0xAA = 0x3AE (942)
rol  $t0, $t0, 4        # $t0 = rotate_left(0x3AE, 4) = 0x3AE0 (15,072)
addi $t1, $zero, 8      # $t1 = 8
rolv $t0, $t0, $t1      # $t0 = rotate_left(0x3AE0, 8) = 0xE03A (57,402)
ror  $t0, $t0, 12       # $t0 = rotate_right(0xE03A, 12) = 0xAE03 (44,547)

# Test memory operations
addi $t1, $zero, 16     # $t1 = 16 (memory address offset)
sw   $t0, 0($t1)        # Store $t0 to memory address 16
addi $t0, $zero, 0      # Clear $t0 to 0
lw   $t0, 0($t1)        # Load from memory back into $t0, should restore value

# Test encrypt/decrypt
addi $t1, $zero, 0      # Clear $t1
enc  $t1, $t0, $zero    # Encrypt $t0 into $t1
dec  $t0, $t1, $zero    # Decrypt $t1 back into $t0, should restore value

# Test branch operations
addi $t2, $zero, 1      # $t2 = 1
beq  $zero, $zero, skip # This should branch (always true)
addi $t0, $zero, 0      # Should be skipped - would clear $t0
skip:
addi $t3, $t0, 0        # Copy $t0 to $t3

# Store final result - if everything worked, this value should be predictable
add  $v0, $t0, $zero    # Final result in $v0 = 0x3AA ******AHHHH*******

# End with infinite loop
loop:
beq  $zero, $zero, loop # Infinite loop to end program