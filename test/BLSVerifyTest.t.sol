// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * Public Key (G1):
 *   x_a: 000000000000000000000000000000000904a2fe47c19c1356627e664ebd7154
 *   x_b: 9b7d58398c5591f472b1c988405c2fa1641e9364226db1ec48918d122127ca85
 *   y_a: 000000000000000000000000000000000dda7a9fa55fba1605e3f79bc4505fd6
 *   y_b: c3f793140d50cdeb8cfa9324c0db6e7b1e759667173e7e8a9dac92a0569976d1
 *
 * Negated Signature (G2):
 *   x_c0_a: 0000000000000000000000000000000007bc3460f3f42e284124654b9c394ba3
 *   x_c0_b: 79e8eea0e8e8defdb6f6e218c8b5c8c2c61d17771f02a316976621769447d754
 *   x_c1_a: 00000000000000000000000000000000124b979496ff0184a55fef6c6750659f
 *   x_c1_b: a23cde40bfbba86bd20abac090213d055a1db24f3673702a1d1b6496d6f225be
 *   y_c0_a: 0000000000000000000000000000000011276648dbef077ebfa9af752e92ff6d
 *   y_c0_b: 10d65ae338db6d9d37e929d8f625c45013b8810711eaca09fe0921ae6805827f
 *   y_c1_a: 0000000000000000000000000000000016d3d4308be18dd24f0d371a12ba9c3a
 *   y_c1_b: 74195fcf4c0a6b9c1e4db67f1ba46d6915ba02644c14808bbbba2d3fe39b8394
 */
import {Test} from "forge-std/Test.sol";

import {BLS} from "solady/src/utils/ext/ithaca/BLS.sol";

import {BLSVerify} from "src/BLSVerify.sol";

contract BLSVerifyTest is Test {
    BLSVerify private blsVerify;

    function setUp() public {
        blsVerify = new BLSVerify();
    }

    function testContractVerifiesSignature() public view {
        string memory json = vm.readFile("./bls-py/points.json");
        BLS.G1Point memory pubKey = abi.decode(vm.parseJson(json, ".G1"), (BLS.G1Point));
        BLS.G2Point memory signature = abi.decode(vm.parseJson(json, ".G2"), (BLS.G2Point));

        bytes memory message = abi.decode(vm.parseJson(json, ".Message"), (bytes));

        assertTrue(blsVerify.verifySignature(message, pubKey, signature));
    }
}
