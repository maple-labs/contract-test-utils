// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.7;

import { DSTest } from "../modules/ds-test/src/test.sol";

interface IERC20Like {

    function balanceOf(address account) external view returns(uint256);

}

interface Hevm {

    // Sets block timestamp to `x`
    function warp(uint256 x) external view;

    // Sets slot `loc` of contract `c` to value `val`
    function store(address c, bytes32 loc, bytes32 val) external view;

    // Reads the slot `loc` of contract `c`
    function load(address c, bytes32 loc) external view returns (bytes32 val);

    // Generates address derived from private key `sk`
    function addr(uint256 sk) external view returns (address _addr);

    // Signs `digest` with private key `sk` (WARNING: this is insecure as it leaks the private key)
    function sign(uint256 sk, bytes32 digest) external view returns (uint8 v, bytes32 r, bytes32 s);

}

contract TestUtils is DSTest {

    uint256 private constant RAY = 10 ** 27;

    function getDiff(uint256 x, uint256 y) internal pure returns (uint256 diff) {
        diff = x > y ? x - y : y - x;
    }

    function assertIgnoringDecimals(uint256 x, uint256 y, uint256 decimalsToIgnore) internal {
        assertEq(getDiff(x, y) / (10 ** decimalsToIgnore), 0);
    }

    // Verify equality within accuracy decimals
    function assertWithinPrecision(uint256 x, uint256 y, uint256 accuracy) internal {
        uint256 diff = getDiff(x, y);
    
        if (diff == 0) return;

        uint256 denominator = x == 0 ? y : x;

        if (((diff * RAY) / denominator) < (RAY / 10 ** accuracy)) return;

        emit log_named_uint("Error: approx a == b not satisfied, accuracy digits", accuracy);

        emit log_named_uint("  Expected", x);
        emit log_named_uint("    Actual", y);

        fail();
    }

    // Verify equality within accuracy percentage (basis points)
    function assertWithinPercentage(uint256 x, uint256 y, uint256 percentage) internal {
        uint256 diff = getDiff(x, y);
    
        if (diff == 0) return;

        uint256 denominator = x == 0 ? y : x;

        if (((diff * RAY) / denominator) < percentage * RAY / 10_000) return;

        emit log_named_uint("Error: approx a == b not satisfied, accuracy digits", percentage);

        emit log_named_uint("  Expected", x);
        emit log_named_uint("    Actual", y);

        fail();
    }

    // Verify equality within difference
    function assertWithinDiff(uint256 x, uint256 y, uint256 expectedDiff) internal {
        if (getDiff(x, y) <= expectedDiff) return;

        emit log_named_uint("Error: approx a == b not satisfied, accuracy digits", expectedDiff);

        emit log_named_uint("  Expected", x);
        emit log_named_uint("    Actual", y);

        fail();
    }

    function constrictToRange(uint256 value, uint256 min, uint256 max) internal pure returns (uint256) {
        return (value % (max - min)) + min;
    }

}

contract StateManipulations {

    Hevm hevm = Hevm(address(bytes20(uint160(uint256(keccak256("hevm cheat code")))))); 

    // Manipulate mainnet ERC20 balance
    function erc20_mint(address token, uint256 slot, address account, uint256 amount) internal view {
        uint256 balance = IERC20Like(token).balanceOf(account);

        hevm.store(
            token,
            keccak256(abi.encode(account, slot)), // Mint tokens
            bytes32(balance + amount)
        );

        // TODO: Update totalSupply
    }

}

