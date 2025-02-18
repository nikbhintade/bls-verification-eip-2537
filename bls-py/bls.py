from py_ecc.bls import G2Basic as bls
from py_ecc.bls import g2_primitives

from web3 import Web3

import random
import json
from dataclasses import dataclass

@dataclass
class Fp:
    a: int # Upper 32 bytes
    b: int # Lower 32 bytes
    
    @classmethod
    def split_base(cls, x: int) -> "Fp":
        b = x.to_bytes(64, "big")
        return cls(int.from_bytes(b[:32], "big"), int.from_bytes(b[32:], "big"))

@dataclass
class Fp2:
    c0: Fp # First coefficient
    c1: Fp # Second coefficient
    
    @classmethod
    def split_extension(cls, coordinate) -> "Fp2":
        sig_c0, sig_c1 = map(int, coordinate.coeffs)  # Directly extract integers
        return cls(Fp.split_base(sig_c0), Fp.split_base(sig_c1))
    
@dataclass
class G1Point:
    x: Fp # x coordinate
    y: Fp # y coordinate
    
    @classmethod
    def from_pubkey(cls, pubkey) -> "G1Point":
        """Converts a BLSPubkey to a G1Point."""
        uncompressed_pubkey = g2_primitives.pubkey_to_G1(pubkey)

        # Extract only x and y, ignoring z
        pk_x, pk_y, *_ = map(int, uncompressed_pubkey)  # Ensure values are integers

        return cls(Fp.split_base(pk_x), Fp.split_base(pk_y))
    
    def __str__(self):
        return f"G1Point(\n  x: ({self.x.a}, {self.x.b}),\n  y: ({self.y.a}, {self.y.b})\n)"

    
@dataclass
class G2Point:
    x: Fp2 # x coordinate
    y: Fp2 # y coordinate
    
    @classmethod
    def from_signature(cls, signature):
        uncompressed_signature = g2_primitives.signature_to_G2(signature)
        sig_x, sig_y, *_ = uncompressed_signature
        return cls(Fp2.split_extension(sig_x), Fp2.split_extension(sig_y))
    
    def __str__(self):
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
    
def serialize_g1(g1: G1Point):
    return {
        "x_a": f"0x{g1.x.a:064x}",
        "x_b": f"0x{g1.x.b:064x}",
        "y_a": f"0x{g1.y.a:064x}",
        "y_b": f"0x{g1.y.b:064x}"
    }

def serialize_g2(g2: G2Point):
    return {
        "x_c0_a": f"0x{g2.x.c0.a:064x}",
        "x_c0_b": f"0x{g2.x.c0.b:064x}",
        "x_c1_a": f"0x{g2.x.c1.a:064x}",
        "x_c1_b": f"0x{g2.x.c1.b:064x}",
        "y_c0_a": f"0x{g2.y.c0.a:064x}",
        "y_c0_b": f"0x{g2.y.c0.b:064x}",
        "y_c1_a": f"0x{g2.y.c1.a:064x}",
        "y_c1_b": f"0x{g2.y.c1.b:064x}"
    }

def main():
    sk = 123234593450989435767234
    pk = bls.SkToPk(sk)
    g1_point = G1Point.from_pubkey(pk)
    
    message = "Verifiying BLS Signature with EIP-2537 Precompile".encode()
    signature = bls.Sign(sk, message)
    g2_point = G2Point.from_signature(signature)

    data = {
        "G1": serialize_g1(g1_point),
        "G2": serialize_g2(g2_point),
        "Message": message.decode()
    }
    
    with open("points.json", "w") as f:
        json.dump(data, f, indent=4)
    
    print(json.dumps(data, indent=4))
    

if __name__ == "__main__":
    main()
