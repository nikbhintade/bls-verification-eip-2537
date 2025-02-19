// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";

import {BLS} from "solady/src/utils/ext/ithaca/BLS.sol";

import {console} from "forge-std/console.sol";

import {BLSVerify} from "src/BLSVerify.sol";

contract BLSVerifyTest is Test {
    BLSVerify private blsVerify;

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

    function testContractVerifiesSignature() public view {
        string memory file = vm.readFile("./bls-py/points.json");
        Json memory data = abi.decode(vm.parseJson(file), (Json));
        assertTrue(blsVerify.verifySignature(abi.encodePacked(data.message), data.pubKey, data.signature));
    }

    function testContractVerifiesAggregatedSignature() public view {
        string memory file = vm.readFile("./bls-py/points_aggregated.json");

        bytes memory encodedPubKeys =
            vm.parseJsonTypeArray(file, ".pubKeys", "G1Point(bytes32 x_a,bytes32 x_b,bytes32 y_a,bytes32 y_b)");
        BLS.G1Point[] memory pubKeys = abi.decode(encodedPubKeys, (BLS.G1Point[]));

        string[] memory messages = vm.parseJsonStringArray(file, ".messages");
        bytes[] memory messagesInBytes = new bytes[](messages.length);

        for (uint256 i = 0; i < messages.length; i++) {
            messagesInBytes[i] = abi.encodePacked(messages[i]);
        }

        bytes memory encodedAggregatedSignature = vm.parseJsonType(
            file,
            ".aggregatedSignature",
            "G2Point(bytes32 x_c0_a,bytes32 x_c0_b,bytes32 x_c1_a,bytes32 x_c1_b,bytes32 y_c0_a,bytes32 y_c0_b,bytes32 y_c1_a,bytes32 y_c1_b)"
        );
        BLS.G2Point memory aggregatedSignature = abi.decode(encodedAggregatedSignature, (BLS.G2Point));

        assertTrue(blsVerify.verifyAggregate(messagesInBytes, pubKeys, aggregatedSignature));
    }
}
