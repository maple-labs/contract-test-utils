// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.7;

import { DSTest } from "./DSTest.sol";

import { IERC20Like, Vm } from "./interfaces.sol";

contract TestUtils is DSTest {

    uint256 private constant RAY = 10 ** 27;

    Vm vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

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

    // Constrict values to a range, inclusive of min and max values. Source: solmate
    function constrictToRange(
        uint256 x,
        uint256 min,
        uint256 max
    ) internal pure returns (uint256 result) {
        require(max >= min, "MAX_LESS_THAN_MIN");

        uint256 size = max - min;

        if (size == 0) return min;            // Using max would be equivalent as well.
        if (max != type(uint256).max) size++; // Make the max inclusive.

        // Ensure max is inclusive in cases where x != 0 and max is at uint max.
        if (max == type(uint256).max && x != 0) x--; // Accounted for later.

        if (x < min) x += size * (((min - x) / size) + 1);

        result = min + ((x - min) % size);

        // Account for decrementing x to make max inclusive.
        if (max == type(uint256).max && x != 0) result++;
    }

    // Manipulate mainnet ERC20 balance
    function erc20_mint(address token, uint256 slot, address account, uint256 amount) internal {
        uint256 balance = IERC20Like(token).balanceOf(account);

        vm.store(
            token,
            keccak256(abi.encode(account, slot)), // Mint tokens
            bytes32(balance + amount)
        );

        // TODO: Update totalSupply
    }

}

contract InvariantTest {

    address[] private _targetContracts;

    function addTargetContract(address newTargetContract_) internal {
        _targetContracts.push(newTargetContract_);
    }

    function targetContracts() public view returns (address[] memory targetContracts_) {
        require(_targetContracts.length != uint256(0), "NO_TARGET_CONTRACTS");
        return _targetContracts;
    }

}
