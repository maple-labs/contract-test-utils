// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.8.7;

import { Vm } from "./interfaces.sol";

abstract contract CSVWriter {

    Vm constant private vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    string constant private ffiScriptsRootPath     = "scripts/ffi";
    string constant private compareFilesScriptPath = string(abi.encodePacked(ffiScriptsRootPath, "/", "cmp-files.sh"));
    string constant private deleteFileScriptPath   = string(abi.encodePacked(ffiScriptsRootPath, "/", "rm-file.sh"));
    string constant private makeDirScriptPath      = string(abi.encodePacked(ffiScriptsRootPath, "/", "mkdir.sh"));
    string constant private writeToFileScriptPath  = string(abi.encodePacked(ffiScriptsRootPath, "/", "write-to-file.sh"));


    mapping (string => string[][]) private csvs;

    /*************************/
    /*** Storage Functions ***/
    /*************************/

    function addRow(string memory filePath_, string[] memory row_) internal {
        require(doesCSVExist(filePath_), "CSV uninitialized.");
        require(getCSVRowLength(filePath_) == row_.length, "Row length mismatch");

        string[][] storage csv = csvs[filePath_];
        require(validateAllRowCellsHaveValues(row_), "Missing values");
        csv.push(row_);
    }

    function clearCSV(string memory filePath_) internal {
        delete csvs[filePath_];
    }

    /**
        @dev header length decides the row length for csv
     */
    function initCSV(string memory filePath_, string[] memory header_) internal {
        string[][] storage csv = csvs[filePath_] = new string[][](0);
        require(validateAllRowCellsHaveValues(header_), "Missing header values");
        csv.push(header_);
    }

    function modifyCell(string memory filePath_, uint256 row_, uint256 column_, string memory content_) internal {
        string[][] storage csv = csvs[filePath_];
        csv[row_][column_]     = content_;
    }

    /**********************/
    /*** File Functions ***/
    /**********************/

    function compareFiles(string memory filePath_A_, string memory filePath_B_) internal returns (bool result_) {
        string[] memory inputs = new string[](5);
        inputs[0] = compareFilesScriptPath;
        inputs[1] = "-a";
        inputs[2] = filePath_A_;
        inputs[3] = "-b";
        inputs[4] = filePath_B_;

        bytes memory output   = vm.ffi(inputs);
        bytes memory matching = hex"1124";
        result_               = compareBytes(output, matching);
    }

    function deleteFile(string memory filePath_) internal {
        string[] memory inputs = new string[](3);
        inputs[0] = deleteFileScriptPath;
        inputs[1] = "-f";
        inputs[2] = filePath_;

        vm.ffi(inputs);
    }

    function makeDir(string memory dirPath_) internal {
        string[] memory inputs = new string[](3);
        inputs[0] = makeDirScriptPath;
        inputs[1] = "-f";
        inputs[2] = dirPath_;

        vm.ffi(inputs);
    }

    function writeFile(string memory filePath_) internal {
        deleteFile(filePath_);

        string[][] storage csv = csvs[filePath_];
        for (uint256 index = 0; index < csv.length; index++) {
            writeLine(filePath_, index);
        }
    }

    /**********************/
    /*** View Functions ***/
    /**********************/

    function doesCSVExist(string memory filePath_) internal view returns (bool exists_) {
        string[][] storage csv = csvs[filePath_];
        exists_                = csv.length > 0; // Is header row there, aka, has initCSV been called.
    }

    function getCSVRowLength(string memory filePath_) internal view returns (uint256 length_) {
        string[][] storage csv = csvs[filePath_];
        length_                = csv[0].length;
    }

    /************************/
    /*** Helper Functions ***/
    /************************/

    function compareBytes(bytes memory a, bytes memory b) internal pure returns (bool result_) {
        if (a.length != b.length) return false;
        for (uint256 index = 0; index < a.length; index++) {
            if(a[index] != b[index]) return false;
        }
        return true;
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

    function validateAllRowCellsHaveValues(string[] memory row_) private pure returns (bool allHaveValues_) {
        for (uint256 index = 0; index < row_.length; index++) {
            string memory cell = row_[index];
            if (bytes(cell).length == 0) {
                return false;
            }
        }
        return true;
    }

    function writeLine(string memory filePath_, uint256 index_) private {
        string[][] storage csv = csvs[filePath_];

        string[] memory inputs = new string[](5);
        inputs[0] = writeToFileScriptPath;
        inputs[1] = "-f";
        inputs[2] = filePath_;
        inputs[3] = "-i";
        inputs[4] = generateCSVLineFromArray(csv[index_]);

        vm.ffi(inputs);
    }

}
