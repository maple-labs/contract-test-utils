// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.6.11;

import { DSTest }   from "../modules/ds-test/src/test.sol";

interface IERC20Like {

    function balanceOf(address account) external view returns(uint256);

}

interface Hevm {

    function warp(uint256) external;

    function store(address,bytes32,bytes32) external;

}

contract MapleTest is DSTest {

    Hevm hevm;

    uint256 constant USD = 10 ** 6;  // USDC precision decimals
    uint256 constant BTC = 10 ** 8;  // WBTC precision decimals
    uint256 constant WAD = 10 ** 18;
    uint256 constant RAY = 10 ** 27;

    uint256 constant MAX_UINT = uint256(-1);

    event Debug(string, uint256);
    event Debug(string, address);
    event Debug(string, bool);

    constructor() public {

        hevm = Hevm(address(bytes20(uint160(uint256(keccak256("hevm cheat code")))))); 

    }

    // Manipulate mainnet ERC20 balance
    function mint(address addr, uint256 slot, address account, uint256 amt) public {
        uint256 bal = IERC20Like(addr).balanceOf(account);

        hevm.store(
            addr,
            keccak256(abi.encode(account, slot)), // Mint tokens
            bytes32(bal + amt)
        );

        assertEq(IERC20Like(addr).balanceOf(account), bal + amt);  // Assert new balance
    }

    function getDiff(uint256 val0, uint256 val1) internal pure returns (uint256 diff) {
        diff = val0 > val1 ? val0 - val1 : val1 - val0;
    }

    function assertWithinPrecision(uint256 val0, uint256 val1, uint256 decimalsToIgnore) public {
        assertEq(getDiff(val0, val1) / (10 ** decimalsToIgnore), 0);
    }

    // Verify equality within accuracy decimals
    function withinPrecision(uint256 val0, uint256 val1, uint256 accuracy) public {
        uint256 diff = getDiff(val0, val1);
        if (diff == 0) return;

        uint256 denominator = val0 == 0 ? val1 : val0;
        bool check = ((diff * RAY) / denominator) < (RAY / 10 ** accuracy);

        if (check) return;

        emit log_named_uint("Error: approx a == b not satisfied, accuracy digits ", accuracy);
        emit log_named_uint("  Expected", val0);
        emit log_named_uint("    Actual", val1);
        fail();
    }

    // Verify equality within accuracy percentage (basis points)
    function withinPercentage(uint256 val0, uint256 val1, uint256 percentage) public {
        uint256 diff = getDiff(val0, val1);
        if (diff == 0) return;

        uint256 denominator = val0 == 0 ? val1 : val0;
        bool check = ((diff * RAY) / denominator) < percentage * RAY / 10_000;

        if (check) return;

        emit log_named_uint("Error: approx a == b not satisfied, accuracy digits ", percentage);
        emit log_named_uint("  Expected", val0);
        emit log_named_uint("    Actual", val1);
        fail();
    }

    // Verify equality within difference
    function withinDiff(uint256 val0, uint256 val1, uint256 expectedDiff) public {
        uint256 actualDiff = getDiff(val0, val1);
        bool check = actualDiff <= expectedDiff;

        if (check) return;

        emit log_named_uint("Error: approx a == b not satisfied, accuracy digits ", expectedDiff);
        emit log_named_uint("  Expected", val0);
        emit log_named_uint("    Actual", val1);
        fail();
    }

    function constrictToRange(uint256 val, uint256 min, uint256 max) public pure returns (uint256) {
        return constrictToRange(val, min, max, false);
    }

    function constrictToRange(uint256 val, uint256 min, uint256 max, bool nonZero) public pure returns (uint256) {
        if      (val == 0 && !nonZero) return 0;
        else if (max == min)           return max;
        else                           return val % (max - min) + min;
    }

    function toWad(uint256 amt) internal pure returns (uint256) {
        return (amt * WAD) / USD;
    }

    function toUsd(uint256 amt) internal pure returns (uint256) {
        return (amt * USD) / WAD;
    }

}

