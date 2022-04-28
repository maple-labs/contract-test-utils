// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.7;

import { Vm } from "./interfaces.sol";
import {console} from "./log.sol";

abstract contract CSVWriter {
    Vm constant internal vm2 = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
    string private constant writeToFileScriptPath = "scripts/write-to-file.sh";

    mapping (string => string[][]) csvs;

    /*************************/
    /*** Storage Functions ***/
    /*************************/

    function init(string memory filePath_, string[] memory header_) internal {
        string[][] storage csv = csvs[filePath_] = new string[][](0);
        csv.push(header_);
    }

    function addCell(string memory filePath_, uint256 row_, string memory content_) internal {
        string[][] storage csv = csvs[filePath_];
        csv[row_].push(content_);
    }

    function addRow(string memory filePath_, string[] memory row_) internal {
        string[][] storage csv = csvs[filePath_];
        console.log("csv length", csv.length);
        csv.push(row_);
        console.log("csv length", csv.length);
        console.log("csv[0]", csv[csv.length-1][0]);
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
        deleteCSV(filePath_);

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

        vm2.ffi(inputs);
    }

    function compareCSV(string memory filePath_A_, string memory filePath_B_) internal returns (bool result_) {
        string[] memory inputs = new string[](5);
        inputs[0] = "scripts/cmp-files.sh";
        inputs[1] = "-a";
        inputs[2] = filePath_A_;
        inputs[3] = "-b";
        inputs[4] = filePath_B_;

        console.log("filePath_A_", filePath_A_);
        console.log("filePath_B_", filePath_B_);

        bytes memory output = vm2.ffi(inputs);
        bytes memory matching = hex"1124";
        result_ = compareBytes(output, matching);
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
        console.log(inputs[4]);

        vm2.ffi(inputs);
    }

    function generateCSVLineFromArray(string[] memory array_) private pure returns (string memory line_) {
        for (uint256 index = 0; index < array_.length; index++) {
            if (index == 0) {
                line_ = array_[index];
            } else {
                line_ = string(abi.encodePacked(line_, ",", array_[index]));
            }
        }
    }

    function compareBytes(bytes memory a, bytes memory b) internal returns (bool result_) {
        if (a.length != b.length) return false;
        for (uint256 index = 0; index < a.length; index++) {
            if(a[index] != b[index]) return false;
        }
        return true;
    }

}
