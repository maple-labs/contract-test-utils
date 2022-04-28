// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.7;

import { Vm } from "./interfaces.sol";

abstract contract CSVWriter {
    Vm constant internal vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
    string private constant writeToFileScriptPath = "scripts/write-to-file.sh";

    string[][] internal csv;

    function initCSV(string[] memory header_) internal {
        csv = new string[][](0);
        csv[0] = header_;
    }

    function writeCSV(string memory filePath_) internal {
        for (uint256 index = 0; index < csv.length; index++) {
            writeLine(filePath_, index);
        }
    }

    function deleteFile(string memory filePath_) internal {
        string[] memory inputs = new string[](3);
        inputs[0] = "scripts/rm-file.sh";
        inputs[1] = "-f";
        inputs[2] = filePath_;

        vm.ffi(inputs);
    }

    function writeLine(string memory filePath_, uint256 index_) private {
        string[] memory inputs = new string[](5);
        inputs[0] = "scripts/write-to-file.sh";
        inputs[1] = "-f";
        inputs[2] = filePath_;
        inputs[3] = "-i";

        // Build line.
        inputs[4] = generateCSVLineFromArray(csv[index_]);

        vm.ffi(inputs);
    }

    function generateCSVLineFromArray(string[] memory array_) private pure returns (string memory line_) {
        for (uint256 index = 0; index < array_.length; index++) {
            if (index == 0) {
                line_ = array_[index];
            } else {
                line_ = string(abi.encodePacked(line_, ",", index));
            }
        }
    }



}
