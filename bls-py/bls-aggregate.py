from py_ecc.bls import G2Basic as bls
import random
import json
import string

from bls_2537.data_structures import G1Point, G2Point
from bls_2537.serialization import serialize_g1, serialize_g2

def generate_random_message_array(num_strings, min_length=40, max_length=50):
    characters = string.ascii_letters + string.digits
    random_strings = []
    for _ in range(num_strings):
        length = random.randint(min_length, max_length)
        random_str = ''.join(random.choices(characters, k=length))
        random_strings.append(random_str)
    return random_strings

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
    
    # Number of random integers you want to generate
    wallet_count = 5

    # Generate an array of random integers in the range [0, 10**30]
    sks = [random.randint(0, 10**30) for _ in range(wallet_count)]
    messages = generate_random_message_array(wallet_count)
    
    pubKeys = []
    pks = []
    signatures = []
    
    for sk, msg in zip(sks, messages):
        pk = bls.SkToPk(sk)
        g1_point = G1Point.from_pubkey(pk)
        pks.append(pk)
        pubKeys.append(serialize_g1(g1_point))
        
        message_encoded = msg.encode()
        sig = bls.Sign(sk, message_encoded)
        signatures.append(sig)
    
    aggregated_signature = bls.Aggregate(signatures)
    serialized_aggregated_signature = serialize_g2(G2Point.from_signature(aggregated_signature))

    data = {
        "aggregatedSignature": serialized_aggregated_signature,
        "pubKeys": pubKeys,
        "messages": messages
    }
    
    # Save serialized data to a JSON file
    with open("points_aggregated.json", "w") as f:
        json.dump(data, f, indent=4)
    
    print(json.dumps(data, indent=4))

if __name__ == "__main__":
    main()
