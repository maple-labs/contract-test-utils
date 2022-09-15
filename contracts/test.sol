// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.7;

import { DSTest } from "./DSTest.sol";

import { IERC20Like, Vm } from "./interfaces.sol";

import { console } from "./log.sol";

contract Address { }

contract TestUtils is DSTest {

    uint256 private constant RAY = 10 ** 27;

    Vm vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    bytes constant ARITHMETIC_ERROR = abi.encodeWithSignature("Panic(uint256)", 0x11);
    bytes constant ZERO_DIVISION    = abi.encodeWithSignature("Panic(uint256)", 0x12);

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

        emit log_named_uint("  Expected", y);
        emit log_named_uint("    Actual", x);

        fail();
    }

    // Verify equality within accuracy percentage (basis points)
    function assertWithinPercentage(uint256 x, uint256 y, uint256 percentage) internal {
        uint256 diff = getDiff(x, y);

        if (diff == 0) return;

        uint256 denominator = x == 0 ? y : x;

        if (((diff * RAY) / denominator) < percentage * RAY / 10_000) return;

        emit log_named_uint("Error: approx a == b not satisfied, accuracy digits", percentage);

        emit log_named_uint("  Expected", y);
        emit log_named_uint("    Actual", x);

        fail();
    }

    // Verify equality within difference
    function assertWithinDiff(uint256 x, uint256 y, uint256 expectedDiff) internal {
        if (getDiff(x, y) <= expectedDiff) return;

        emit log_named_uint("Error: approx a == b not satisfied, accuracy digits", expectedDiff);

        emit log_named_uint("  Expected", y);
        emit log_named_uint("    Actual", x);

        fail();
    }

    // Constrict values to a range, inclusive of min and max values.
    function constrictToRange(
        uint256 x,
        uint256 min,
        uint256 max
    ) internal pure returns (uint256 result) {
        require(max >= min, "MAX_LESS_THAN_MIN");

        if (min == max) return min;  // A range of 0 is effectively a single value.

        if (min == 0 && max == type(uint256).max) return x;  // The entire uint256 space is effectively x.

        return (x % ((max - min) + 1)) + min;  // Given the above exit conditions, `(max - min) + 1 <= type(uint256).max`.
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

    // Adapted from https://stackoverflow.com/questions/47129173/how-to-convert-uint-to-string-in-solidity
    function convertUintToString(uint256 input_) internal pure returns (string memory output_) {
        if (input_ == 0) return "0";

        uint256 j = input_;
        uint256 length;

        while (j != 0) {
            length++;
            j /= 10;
        }

        bytes memory output = new bytes(length);
        uint256 k = length;

        while (input_ != 0) {
            k = k - 1;

            uint8 temp = (48 + uint8(input_ - input_ / 10 * 10));
            bytes1 b1  = bytes1(temp);

            output[k] = b1;
            input_ /= 10;
        }

        return string(output);
    }

}

contract InvariantTest {

    struct FuzzSelector {
        address addr;
        bytes4[] selectors;
    }

    address[] private _excludedContracts;
    address[] private _excludedSenders;
    address[] private _targetedContracts;
    address[] private _targetedSenders;

    FuzzSelector[] internal _targetedSelectors;

    function excludeContract(address newExcludedContract_) internal {
        _excludedContracts.push(newExcludedContract_);
    }

    function excludeContracts() public view returns (address[] memory excludedContracts_) {
        require(_excludedContracts.length != uint256(0), "NO_EXCLUDED_CONTRACTS");
        excludedContracts_ = _excludedContracts;
    }

    function excludeSender(address newExcludedSender_) internal {
        _excludedSenders.push(newExcludedSender_);
    }

    function excludeSenders() public view returns (address[] memory excludedSenders_) {
        require(_excludedSenders.length != uint256(0), "NO_EXCLUDED_SENDERS");
        excludedSenders_ = _excludedSenders;
    }

    function targetContract(address newTargetedContract_) internal {
        _targetedContracts.push(newTargetedContract_);
    }

    function targetContracts() public view returns (address[] memory targetedContracts_) {
        require(_targetedContracts.length != uint256(0), "NO_TARGETED_CONTRACTS");
        targetedContracts_ = _targetedContracts;
    }

    function targetSelector(FuzzSelector memory newTargetedSelector_) internal {
        _targetedSelectors.push(newTargetedSelector_);
    }

    function targetSelectors() public view returns (FuzzSelector[] memory targetedSelectors_) {
        require(targetedSelectors_.length != uint256(0), "NO_TARGETED_SELECTORS");
        targetedSelectors_ = _targetedSelectors;
    }

    function targetSender(address newTargetedSender_) internal {
        _targetedSenders.push(newTargetedSender_);
    }

    function targetSenders() public view returns (address[] memory targetedSenders_) {
        require(_targetedSenders.length != uint256(0), "NO_TARGETED_SENDERS");
        targetedSenders_ = _targetedSenders;
    }

}
