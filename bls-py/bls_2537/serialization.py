from .data_structures import G1Point, G2Point

# -------------------------------
# Serialization Helpers
# -------------------------------

def serialize_g1(g1: G1Point, to_int: bool = False):
    """
    Serializes a G1 point into a JSON-compatible dictionary.

    Args:
        g1 (G1Point): The G1 point to serialize.
        to_int (bool): If True, converts values to integers instead of hex strings.
    
    Returns:
        dict: A dictionary representation of the G1 point.
    """
    if to_int:
        return {
            "x_a": int.from_bytes(g1.x.a.to_bytes(32, 'big'), 'big'),
            "x_b": int.from_bytes(g1.x.b.to_bytes(32, 'big'), 'big'),
            "y_a": int.from_bytes(g1.y.a.to_bytes(32, 'big'), 'big'),
            "y_b": int.from_bytes(g1.y.b.to_bytes(32, 'big'), 'big')
        }
    
    return {
        "x_a": f"0x{g1.x.a:064x}",
        "x_b": f"0x{g1.x.b:064x}",
        "y_a": f"0x{g1.y.a:064x}",
        "y_b": f"0x{g1.y.b:064x}"
    }

def serialize_g2(g2: G2Point, to_int: bool = False):
    """
    Serializes a G2 point into a JSON-compatible dictionary.

    Args:
        g2 (G2Point): The G2 point to serialize.
        to_int (bool): If True, converts values to integers instead of hex strings.
    
    Returns:
        dict: A dictionary representation of the G2 point.
    """
    if to_int:
        return {
            "x_c0_a": int.from_bytes(g2.x.c0.a.to_bytes(32, 'big'), 'big'),
            "x_c0_b": int.from_bytes(g2.x.c0.b.to_bytes(32, 'big'), 'big'),
            "x_c1_a": int.from_bytes(g2.x.c1.a.to_bytes(32, 'big'), 'big'),
            "x_c1_b": int.from_bytes(g2.x.c1.b.to_bytes(32, 'big'), 'big'),
            "y_c0_a": int.from_bytes(g2.y.c0.a.to_bytes(32, 'big'), 'big'),
            "y_c0_b": int.from_bytes(g2.y.c0.b.to_bytes(32, 'big'), 'big'),
            "y_c1_a": int.from_bytes(g2.y.c1.a.to_bytes(32, 'big'), 'big'),
            "y_c1_b": int.from_bytes(g2.y.c1.b.to_bytes(32, 'big'), 'big')
        }
    
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
