from py_ecc.bls import G2Basic as bls
import random
import json

from bls_2537.data_structures import G1Point, G2Point
from bls_2537.serialization import serialize_g1, serialize_g2


# -------------------------------
# Main Execution
# -------------------------------

def main():
    """
    Demonstrates BLS key generation, signing, and serialization.

    - Generates a private key (sk).
    - Computes the corresponding public key (pk) and converts it to a G1Point.
    - Signs a message using the private key and converts the signature to a G2Point.
    - Serializes and stores both points in a JSON file.
    """
    sk = random.randint(0, 10**30)  # Example secret key
    pk = bls.SkToPk(sk)  # Derive public key
    g1_point = G1Point.from_pubkey(pk)  # Convert public key to G1Point
    
    message = "Testing BLS Signature with EIP-2537 Precompile".encode()
    signature = bls.Sign(sk, message)  # Generate BLS signature
    g2_point = G2Point.from_signature(signature)  # Convert signature to G2Point

    data = {
        "message": message.decode(),
        "pubKey": serialize_g1(g1_point),
        "signature": serialize_g2(g2_point)
    }
    
    # Save serialized points to a JSON file
    with open("points.json", "w") as f:
        json.dump(data, f, indent=4)
    
    print(json.dumps(data, indent=4))  # Print serialized data

if __name__ == "__main__":
    main()
