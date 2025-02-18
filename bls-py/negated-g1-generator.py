# BLS12-381 field modulus (p)
p = 0x1a0111ea397fe69a4b1ba7b6434bacd764774b84f38512bf6730d2a0f6b0f6241eabfffeb153ffffb9feffffffffaaab

# Provided G1 generator coordinates (H1)
X = 0x17f1d3a73197d7942695638c4fa9ac0fc3688c4f9774b905a14e3a3f171bac586c55e83ff97a1aeffb3af00adb22c6bb
Y = 0x08b3f481e3aaa0f1a09e30ed741d8ae4fcf5e095d5d00af600db18cb2c04b3edd03cc744a2888ae40caa232946c5e7e1

# Negate Y: compute -Y mod p. (Since Y < p, this is just p - Y.)
Y_neg = (-Y) % p

def split_to_fp_parts(value: int):
    """
    Encode the given integer as 64-byte big-endian,
    then split into two 32-byte (256-bit) parts.
    
    These correspond to the fields 'a' (upper 32 bytes) and 'b' (lower 32 bytes)
    in the Solidity Fp struct.
    """
    encoded = value.to_bytes(64, byteorder="big")
    a = int.from_bytes(encoded[:32], byteorder="big")
    b = int.from_bytes(encoded[32:], byteorder="big")
    return a, b

# Split X and negated Y into their Fp struct parts.
X_a, X_b = split_to_fp_parts(X)
Y_neg_a, Y_neg_b = split_to_fp_parts(Y_neg)

print("Negated G1 Generator (using provided X and negated Y):\n")
print("X coordinate (Fp):")
print("  a =", X_a)
print("  b =", X_b)
print("\nY coordinate (Fp) (negated):")
print("  a =", Y_neg_a)
print("  b =", Y_neg_b)
