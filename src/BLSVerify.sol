// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {BLS} from "solady/src/utils/ext/ithaca/BLS.sol";

/**
 * @title BLSVerify
 * @notice A contract for verifying BLS signatures using the EIP-2537 precompile.
 *
 * @dev This contract follows the BLS signature verification rule:
 *          e(pubKey, H(m)) · e(-G1, signature) == 1
 *
 *      - The contract assumes the provided BLS signature is negated (σ' = -σ).
 *      - The message is mapped to a point in G2 using `BLS.hashToG2`.
 *      - The pairing check is performed using the precompile via `BLS.pairing`.
 *
 *      The contract stores the negated generator (-G1) as `NEGATED_G1_GENERATOR`,
 *      which is derived from the standard G1 generator in EIP-2537. You can generate
 *      the same constant using the `negated-g1-generator.py` script.
 *
 *      The pairing operation verifies whether the given signature was indeed
 *      generated by the corresponding private key.
 */
contract BLSVerify {
    using BLS for *;

    /// @notice The negated generator point in G1 (-G1), derived from EIP-2537's standard G1 generator.
    BLS.G1Point NEGATED_G1_GENERATOR = BLS.G1Point(
        bytes32(uint256(31827880280837800241567138048534752271)),
        bytes32(uint256(88385725958748408079899006800036250932223001591707578097800747617502997169851)),
        bytes32(uint256(22997279242622214937712647648895181298)),
        bytes32(uint256(46816884707101390882112958134453447585552332943769894357249934112654335001290))
    );

    /**
     * @notice Verifies a single BLS signature against a given message and public key.
     * @param message The signed message (byte array).
     * @param pubKey The signer's public key (a point in G1).
     * @param signature The BLS signature (a point in G2).
     * @return True if the signature is valid, false otherwise.
     */
    function verifySignature(bytes memory message, BLS.G1Point memory pubKey, BLS.G2Point memory signature)
        public
        view
        returns (bool)
    {
        // Compute H(m): map the message to a point in G2.
        BLS.G2Point memory hm = BLS.hashToG2(message);

        // Prepare input arrays for the pairing check.
        BLS.G1Point[] memory g1Points = new BLS.G1Point[](2);
        BLS.G2Point[] memory g2Points = new BLS.G2Point[](2);

        g1Points[0] = NEGATED_G1_GENERATOR; // -G1
        g1Points[1] = pubKey; // Public key

        g2Points[0] = signature; // Signature
        g2Points[1] = hm; // H(m)

        // The pairing precompile (via BLS.pairing) returns true if the product equals one.
        return BLS.pairing(g1Points, g2Points);
    }

    function verifySignature(BLS.G2Point memory message, BLS.G1Point memory pubKey, BLS.G2Point memory signature)
        public
        view
        returns (bool)
    {
        // Compute H(m): map the message to a point in G2.
        // BLS.G2Point memory hm = BLS.hashToG2(message);

        // Prepare input arrays for the pairing check.
        BLS.G1Point[] memory g1Points = new BLS.G1Point[](2);
        BLS.G2Point[] memory g2Points = new BLS.G2Point[](2);

        g1Points[0] = NEGATED_G1_GENERATOR; // -G1
        g1Points[1] = pubKey; // Public key

        g2Points[0] = signature; // Signature
        g2Points[1] = message; // H(m)

        // The pairing precompile (via BLS.pairing) returns true if the product equals one.
        return BLS.pairing(g1Points, g2Points);
    }

    function verifyAggregate(
        bytes[] memory messages,
        BLS.G1Point[] memory pubKeys,
        BLS.G2Point memory aggregatedSignature
    ) public view returns (bool) {
        require(messages.length == pubKeys.length, "Mismatched Array Length");

        BLS.G1Point[] memory g1Points = new BLS.G1Point[](messages.length + 1);
        BLS.G2Point[] memory g2Points = new BLS.G2Point[](messages.length + 1);

        for (uint256 i = 0; i < messages.length; i++) {
            g1Points[i] = pubKeys[i];
            g2Points[i] = BLS.hashToG2(messages[i]);
        }
        g1Points[messages.length] = NEGATED_G1_GENERATOR;
        g2Points[messages.length] = aggregatedSignature;

        return BLS.pairing(g1Points, g2Points);
    }
}
