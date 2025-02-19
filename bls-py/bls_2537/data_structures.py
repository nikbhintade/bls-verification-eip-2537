from dataclasses import dataclass
from py_ecc.bls import g2_primitives

# -------------------------------
# Data Structures for BLS Points
# -------------------------------

@dataclass
class Fp:
    """Represents a finite field element Fp split into two 32-byte parts."""
    a: int  # Upper 32 bytes
    b: int  # Lower 32 bytes
    
    @classmethod
    def split_base(cls, x: int) -> "Fp":
        """
        Splits a 64-byte integer into two 32-byte integers.
        
        Args:
            x (int): The 64-byte integer to be split.
        
        Returns:
            Fp: An instance containing the upper and lower 32-byte parts.
        """
        b = x.to_bytes(64, "big")
        return cls(int.from_bytes(b[:32], "big"), int.from_bytes(b[32:], "big"))

@dataclass
class Fp2:
    """Represents an extension field element Fp2, composed of two Fp elements."""
    c0: Fp  # First coefficient
    c1: Fp  # Second coefficient
    
    @classmethod
    def split_extension(cls, coordinate) -> "Fp2":
        """
        Splits an Fp2 coordinate into two Fp elements.

        Args:
            coordinate: The Fp2 coordinate containing two coefficients.
        
        Returns:
            Fp2: An instance containing the split coefficients.
        """
        sig_c0, sig_c1 = map(int, coordinate.coeffs)  # Extract integers
        return cls(Fp.split_base(sig_c0), Fp.split_base(sig_c1))

@dataclass
class G1Point:
    """Represents a point in the G1 group of the BLS12-381 curve."""
    x: Fp  # x coordinate
    y: Fp  # y coordinate
    
    @classmethod
    def from_pubkey(cls, pubkey) -> "G1Point":
        """
        Converts a BLS public key to a G1Point.

        Args:
            pubkey: The BLS public key in compressed form.
        
        Returns:
            G1Point: The corresponding G1 point (x, y).
        """
        uncompressed_pubkey = g2_primitives.pubkey_to_G1(pubkey)

        # Extract only x and y coordinates, ignoring the z coordinate
        pk_x, pk_y, *_ = map(int, uncompressed_pubkey)

        return cls(Fp.split_base(pk_x), Fp.split_base(pk_y))
    
    def __str__(self):
        """Returns a formatted string representation of the G1 point."""
        return f"G1Point(\n  x: ({self.x.a}, {self.x.b}),\n  y: ({self.y.a}, {self.y.b})\n)"

@dataclass
class G2Point:
    """Represents a point in the G2 group of the BLS12-381 curve."""
    x: Fp2  # x coordinate
    y: Fp2  # y coordinate
    
    @classmethod
    def from_signature(cls, signature) -> "G2Point":
        """
        Converts a BLS signature to a G2Point.

        Args:
            signature: The BLS signature in compressed form.
        
        Returns:
            G2Point: The corresponding G2 point (x, y).
        """
        uncompressed_signature = g2_primitives.signature_to_G2(signature)
        sig_x, sig_y, *_ = uncompressed_signature
        return cls(Fp2.split_extension(sig_x), Fp2.split_extension(sig_y))
    
    def __str__(self):
        """Returns a formatted string representation of the G2 point."""
        return (
            f"G2Point(\n"
            f"  x: (\n"
            f"    c0: ({self.x.c0.a}, {self.x.c0.b}),\n"
            f"    c1: ({self.x.c1.a}, {self.x.c1.b})\n"
            f"  ),\n"
            f"  y: (\n"
            f"    c0: ({self.y.c0.a}, {self.y.c0.b}),\n"
            f"    c1: ({self.y.c1.a}, {self.y.c1.b})\n"
            f"  )\n"
            f")"
        )
