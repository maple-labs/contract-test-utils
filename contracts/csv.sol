// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.7;

import { Vm } from "./interfaces.sol";

abstract contract CSVWriter {
    Vm constant internal vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
    string private constant writeToFileScriptPath = "scripts/write-to-file.sh";

    mapping (string => string[][]) csvs;

    /*************************/
    /*** Storage Functions ***/
    /*************************/

    function init(string memory filePath_, string[] memory header_) internal {
        string[][] storage csv = csvs[filePath_] = new string[][](0);
        csv[0] = header_;
    }

    function addCell(string memory filePath_, uint256 row_, string memory content_) internal {
        string[][] storage csv = csvs[filePath_];
        csv[row_].push(content_);
    }

    function addRow(string memory filePath_, string[] memory row_) internal {
        string[][] storage csv = csvs[filePath_];
        csv.push(row_);
    }

    function modifyCell(string memory filePath_, uint256 row_, uint256 column_, string memory content_) internal {
        string[][] storage csv = csvs[filePath_];
        csv[row_][column_] = content_;
    }

    function clearCSV(string memory filePath_) internal {
        delete csvs[filePath_];
    }

    /**********************/
    /*** File Functions ***/
    /**********************/

    function writeCSV(string memory filePath_) internal {
        string[][] storage csv = csvs[filePath_];
        for (uint256 index = 0; index < csv.length; index++) {
            writeLine(filePath_, index);
        }
    }

    function deleteCSV(string memory filePath_) internal {
        string[] memory inputs = new string[](3);
        inputs[0] = "scripts/rm-file.sh";
        inputs[1] = "-f";
        inputs[2] = filePath_;

        vm.ffi(inputs);
    }

    function compareCSV(string memory filePath_A_, string memory filePath_B_) internal {
        string[] memory inputs = new string[](5);
        inputs[0] = "scripts/cmp-files.sh";
        inputs[1] = "-a";
        inputs[2] = filePath_A_;
        inputs[3] = "-b";
        inputs[4] = filePath_B_;

        vm.ffi(inputs);
    }

    /************************/
    /*** Helper Functions ***/
    /************************/

    function writeLine(string memory filePath_, uint256 index_) private {
        string[][] storage csv = csvs[filePath_];

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
