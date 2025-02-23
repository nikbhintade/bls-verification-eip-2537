// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";

import {BLS} from "solady/src/utils/ext/ithaca/BLS.sol";

import {console} from "forge-std/console.sol";

import {BLSVerify} from "src/BLSVerify.sol";

contract BLSVerifyTest is Test {
    BLSVerify private blsVerify;

    function G1_GENERATOR() internal pure returns (BLS.G1Point memory) {
        return BLS.G1Point(
            bytes32(uint256(31827880280837800241567138048534752271)),
            bytes32(uint256(88385725958748408079899006800036250932223001591707578097800747617502997169851)),
            bytes32(uint256(11568204302792691131076548377920244452)),
            bytes32(uint256(114417265404584670498511149331300188430316142484413708742216858159411894806497))
        );
    }

    function NEGATED_G1_GENERATOR() internal pure returns (BLS.G1Point memory) {
        return BLS.G1Point(
            bytes32(uint256(31827880280837800241567138048534752271)),
            bytes32(uint256(88385725958748408079899006800036250932223001591707578097800747617502997169851)),
            bytes32(uint256(22997279242622214937712647648895181298)),
            bytes32(uint256(46816884707101390882112958134453447585552332943769894357249934112654335001290))
        );
    }

    function setUp() public {
        blsVerify = new BLSVerify();
    }

    struct G1Point {
        bytes32 x_a;
        bytes32 x_b;
        bytes32 y_a;
        bytes32 y_b;
    }

    struct Json {
        string message;
        BLS.G1Point pubKey;
        BLS.G2Point signature;
    }

    struct AggregatedJson {
        BLS.G2Point aggregatedSignature;
        BLS.G1Point[] pubKeys;
        string[] messages;
    }

    struct Apple {
        string color;
        uint8 sourness;
        uint8 sweetness;
    }

    struct FruitStall {
        Apple[] apples;
        string name;
    }

    function testContractVerifiesSignature() public {
        bytes32 privateKey = bytes32(vm.randomUint());

        BLS.G1Point[] memory g1Points = new BLS.G1Point[](1);
        bytes32[] memory scalars = new bytes32[](1);

        g1Points[0] = G1_GENERATOR();
        scalars[0] = privateKey;

        BLS.G1Point memory publicKey = BLS.msm(g1Points, scalars);

        bytes memory message = "testing BLSVerify verifySignatrue";

        BLS.G2Point[] memory g2Points = new BLS.G2Point[](1);
        g2Points[0] = BLS.hashToG2(message);

        BLS.G2Point memory signature = BLS.msm(g2Points, scalars);

        assertTrue(blsVerify.verifySignature(message, publicKey, signature));
        assertTrue(blsVerify.verifySignature(g2Points[0], publicKey, signature));
    }

    function testContractVerifiesAggregatedSignature() public {
        uint8 iterations = 5;

        bytes32[] memory privateKeys = new bytes32[](iterations);
        BLS.G1Point[] memory pubKeys = new BLS.G1Point[](iterations);
        bytes[] memory messages = new bytes[](iterations);
        BLS.G2Point[] memory signatures = new BLS.G2Point[](iterations);

        bytes memory message = "testing BLSVerify verifySignatrue";

        for (uint8 i = 0; i < iterations; i++) {
            privateKeys[i] = bytes32(vm.randomUint());

            BLS.G1Point[] memory g1Points = new BLS.G1Point[](1);
            bytes32[] memory scalars = new bytes32[](1);

            g1Points[0] = G1_GENERATOR();
            scalars[0] = privateKeys[i];

            BLS.G1Point memory publicKey = BLS.msm(g1Points, scalars);
            pubKeys[i] = publicKey;

            BLS.G2Point[] memory g2Points = new BLS.G2Point[](1);
            g2Points[0] = BLS.hashToG2(message);

            messages[i] = message;

            BLS.G2Point memory signature = BLS.msm(g2Points, scalars);
            signatures[i] = signature;
        }

        BLS.G2Point memory aggregatedSignature = signatures[0];
        for (uint8 i = 1; i < iterations; i++) {
            aggregatedSignature = BLS.add(aggregatedSignature, signatures[i]);
        }

        assertTrue(blsVerify.verifyAggregate(messages, pubKeys, aggregatedSignature));
    }

    /// @dev This test is not working.

    function testAggregatedKeysWithAggMessage() public {
        uint8 iterations = 5;

        bytes32[] memory privateKeys = new bytes32[](iterations);
        BLS.G1Point[] memory pubKeys = new BLS.G1Point[](iterations);
        bytes[] memory messages = new bytes[](iterations);
        BLS.G2Point[] memory signatures = new BLS.G2Point[](iterations);

        bytes memory message = "testing BLSVerify verifySignatrue";

        for (uint8 i = 0; i < iterations; i++) {
            privateKeys[i] = bytes32(vm.randomUint());

            BLS.G1Point[] memory g1Points = new BLS.G1Point[](1);
            bytes32[] memory scalars = new bytes32[](1);

            g1Points[0] = G1_GENERATOR();
            scalars[0] = privateKeys[i];

            BLS.G1Point memory publicKey = BLS.msm(g1Points, scalars);
            pubKeys[i] = publicKey;

            BLS.G2Point[] memory g2Points = new BLS.G2Point[](1);
            g2Points[0] = BLS.hashToG2(message);

            messages[i] = message;

            BLS.G2Point memory signature = BLS.msm(g2Points, scalars);
            signatures[i] = signature;
        }

        BLS.G1Point memory aggregatedPubKey = pubKeys[0];
        
        BLS.G2Point memory aggregatedSignature = signatures[0];
        BLS.G2Point memory aggregatedMessage = signatures[0];
        for (uint8 i = 1; i < iterations; i++) {
            aggregatedPubKey = BLS.add(aggregatedPubKey, pubKeys[i]);
            
            aggregatedSignature = BLS.add(aggregatedSignature, signatures[i]);
            aggregatedMessage = BLS.add(aggregatedMessage, signatures[i]);
        }

        assertTrue(blsVerify.verifySignature(aggregatedMessage, aggregatedPubKey, aggregatedSignature));
    }

    // function testContractVerifiesAggSigGeneratedWithSingleMessage() public view {
    //     string memory file = vm.readFile("./bls-py/single_message_aggregate.json");

    //     bytes memory encodedPubKeys = vm.parseJsonTypeArray()
    // }
}
