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

interface ForgeVm {
    // Set block.timestamp (newTimestamp)
    function warp(uint256) external;
    // Set block.height (newHeight)
    function roll(uint256) external;
    // Set block.basefee (newBasefee)
    function fee(uint256) external;
    // Loads a storage slot from an address (who, slot)
    function load(address,bytes32) external returns (bytes32);
    // Stores a value to an address' storage slot, (who, slot, value)
    function store(address,bytes32,bytes32) external;
    // Signs data, (privateKey, digest) => (v, r, s)
    function sign(uint256,bytes32) external returns (uint8,bytes32,bytes32);
    // Gets address for a given private key, (privateKey) => (address)
    function addr(uint256) external returns (address);
    // Performs a foreign function call via terminal, (stringInputs) => (result)
    function ffi(string[] calldata) external returns (bytes memory);
    // Sets the *next* call's msg.sender to be the input address
    function prank(address) external;
    // Sets all subsequent calls' msg.sender to be the input address until `stopPrank` is called
    function startPrank(address) external;
    // Sets the *next* call's msg.sender to be the input address, and the tx.origin to be the second input
    function prank(address,address) external;
    // Sets all subsequent calls' msg.sender to be the input address until `stopPrank` is called, and the tx.origin to be the second input
    function startPrank(address,address) external;
    // Resets subsequent calls' msg.sender to be `address(this)`
    function stopPrank() external;
    // Sets an address' balance, (who, newBalance)
    function deal(address, uint256) external;
    // Sets an address' code, (who, newCode)
    function etch(address, bytes calldata) external;
    // Expects an error on next call
    function expectRevert(bytes calldata) external;
    function expectRevert(bytes4) external;
    // Record all storage reads and writes
    function record() external;
    // Gets all accessed reads and write slot from a recording session, for a given address
    function accesses(address) external returns (bytes32[] memory reads, bytes32[] memory writes);
    // Prepare an expected log with (bool checkTopic1, bool checkTopic2, bool checkTopic3, bool checkData).
    // Call this function, then emit an event, then call a function. Internally after the call, we check if
    // logs were emitted in the expected order with the expected topics and data (as specified by the booleans)
    function expectEmit(bool,bool,bool,bool) external;
    // Mocks a call to an address, returning specified data.
    // Calldata can either be strict or a partial match, e.g. if you only
    // pass a Solidity selector to the expected calldata, then the entire Solidity
    // function will be mocked.
    function mockCall(address,bytes calldata,bytes calldata) external;
    // Clears all mocked calls
    function clearMockedCalls() external;
    // Expect a call to an address with the specified calldata.
    // Calldata can either be strict or a partial match
    function expectCall(address,bytes calldata) external;

    function getCode(string calldata) external returns (bytes memory);
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

    function constrictToRange(uint256 input, uint256 min, uint256 max) internal pure returns (uint256 output) {
        return min == max ? max : input % (max - min) + min;
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

contract ForgeStateManipulations {
    ForgeVm internal forgeVm = ForgeVm(address(bytes20(uint160(uint256(keccak256("hevm cheat code"))))));
}

