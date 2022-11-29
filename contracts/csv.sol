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

    modifier csvExists(string memory filePath_) {
        require(doesCSVExist(filePath_), "CSV uninitialized.");
        _;
    }

    modifier validRow(string[] memory row_) {
        require(validateAllRowCellsHaveValues(row_), "Missing values");
        _;
    }

    modifier validRowForCsv(string memory filePath_, uint256 rowLength) {
        require(getCSVRowLength(filePath_) == rowLength, "Row length mismatch");
        _;
    }

    function _addRow(string memory filePath_, string[] memory row_) validRow(row_) internal {
        csvs[filePath_].push(row_);
    }

    function addRow(string memory filePath_, string[] memory row_) csvExists(filePath_) validRowForCsv(filePath_, row_.length) internal {
        _addRow(filePath_, row_);
    }

    function addRow(string memory filePath_, string memory cell1_) csvExists(filePath_) validRowForCsv(filePath_, 1) internal {
        string[] memory row_ = new string[](1);
        row_[0] = cell1_;
        _addRow(filePath_, row_);
    }

    function addRow(string memory filePath_, string memory cell1_, string memory cell2_) csvExists(filePath_) validRowForCsv(filePath_, 2) internal {
        string[] memory row_ = new string[](2);
        row_[0] = cell1_;
        row_[1] = cell2_;
        _addRow(filePath_, row_);
    }

    function addRow(string memory filePath_, string memory cell1_, string memory cell2_, string memory cell3_) csvExists(filePath_) validRowForCsv(filePath_, 3) internal {
        string[] memory row_ = new string[](3);
        row_[0] = cell1_;
        row_[1] = cell2_;
        row_[2] = cell3_;
        _addRow(filePath_, row_);
    }

    function addRow(string memory filePath_, string memory cell1_, string memory cell2_, string memory cell3_, string memory cell4_) csvExists(filePath_) validRowForCsv(filePath_, 4) internal {
        string[] memory row_ = new string[](4);
        row_[0] = cell1_;
        row_[1] = cell2_;
        row_[2] = cell3_;
        row_[3] = cell4_;
        _addRow(filePath_, row_);
    }

    function addRow(string memory filePath_, string memory cell1_, string memory cell2_, string memory cell3_, string memory cell4_, string memory cell5_) csvExists(filePath_) validRowForCsv(filePath_, 5) internal {
        string[] memory row_ = new string[](5);
        row_[0] = cell1_;
        row_[1] = cell2_;
        row_[2] = cell3_;
        row_[3] = cell4_;
        row_[4] = cell5_;
        _addRow(filePath_, row_);
    }

    function clearCSV(string memory filePath_) internal {
        delete csvs[filePath_];
    }

    /**
        @dev header length decides the row length for csv
     */
    function _initCSV(string memory filePath_, string[] memory header_) internal {
        clearCSV(filePath_);
        _addRow(filePath_, header_);
    }

    function initCSV(string memory filePath_, string[] memory header_) internal {
        _initCSV(filePath_, header_);
    }

    function initCSV(string memory filePath_, string memory header1_) internal {
        string[] memory row_ = new string[](1);
        row_[0] = header1_;
        _initCSV(filePath_, row_);
    }

    function initCSV(string memory filePath_, string memory header1_, string memory header2_) internal {
        string[] memory row_ = new string[](2);
        row_[0] = header1_;
        row_[1] = header2_;
        _initCSV(filePath_, row_);
    }

    function initCSV(string memory filePath_, string memory header1_, string memory header2_, string memory header3_) internal {
        string[] memory row_ = new string[](3);
        row_[0] = header1_;
        row_[1] = header2_;
        row_[2] = header3_;
        _initCSV(filePath_, row_);
    }

    function initCSV(string memory filePath_, string memory header1_, string memory header2_, string memory header3_, string memory header4_) internal {
        string[] memory row_ = new string[](4);
        row_[0] = header1_;
        row_[1] = header2_;
        row_[2] = header3_;
        row_[3] = header4_;
        _initCSV(filePath_, row_);
    }

    function initCSV(string memory filePath_, string memory header1_, string memory header2_, string memory header3_, string memory header4_, string memory header5_) internal {
        string[] memory row_ = new string[](5);
        row_[0] = header1_;
        row_[1] = header2_;
        row_[2] = header3_;
        row_[3] = header4_;
        row_[4] = header5_;
        _initCSV(filePath_, row_);
    }

    function modifyCell(string memory filePath_, uint256 row_, uint256 column_, string memory content_) internal {
        csvs[filePath_][row_][column_]     = content_;
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

        for (uint256 index; index < csv.length; ++index) {
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

        for (uint256 index; index < a.length; ++index) {
            if (a[index] != b[index]) return false;
        }

        return true;
    }

    function generateCSVLineFromArray(string[] memory array_) private pure returns (string memory line_) {
        for (uint256 index; index < array_.length; ++index) {
            line_ = index == 0
                ? array_[index]
                : string(abi.encodePacked(line_, ",", array_[index]));
        }
    }

    function validateAllRowCellsHaveValues(string[] memory row_) private pure returns (bool allHaveValues_) {
        for (uint256 index; index < row_.length; ++index) {
            string memory cell = row_[index];

            if (bytes(cell).length == 0) return false;
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
