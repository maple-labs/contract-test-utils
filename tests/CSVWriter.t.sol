// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.7;

import { TestUtils } from "../contracts/test.sol";
import { CSVWriter } from "../contracts/csv.sol";

contract CSVWriterTests is TestUtils, CSVWriter {
    function setUp() public {} 

    function test_csv_simple() external {
        string memory filePath = "output/teammates.csv";

        uint256 rowLength = 5;

        string[] memory header = new string[](rowLength);
        header[0] = "id";
        header[1] = "name";
        header[2] = "position";
        header[3] = "location";
        header[4] = "animal";

        initCSV(filePath, header);

        string[] memory row = new string[](getCSVRowLength(filePath));

        row[0] = "0";
        row[1] = "Erick";
        row[2] = "Smart Contracts";
        row[3] = "Detroit";
        row[4] = "iguana";

        addRow(filePath, row);

        row[0] = "1";
        row[1] = "Lucas";
        row[2] = "Smart Contracts";
        row[3] = "Toronto";
        row[4] = "kangaroo";

        addRow(filePath, row);

        row[0] = "2";
        row[1] = "Bidin";
        row[2] = "Smart Contracts";
        row[3] = "Panama";
        row[4] = "giraffe";

        addRow(filePath, row);

        row[0] = "3";
        row[1] = "JG";
        row[2] = "Smart Contracts";
        row[3] = "Rio";
        row[4] = "elephant";

        addRow(filePath, row);

        writeFile(filePath);

        assertTrue(compareFiles(filePath, "tests/expected/csv1.csv"), "Files don't match");
    }

    function test_csv_large() external {
        string memory filePath = "output/large.csv";

        uint256 rowLength = 50;
        uint256 numberOfRows = 100;

        string[] memory header = new string[](rowLength);
        for (uint256 index = 0; index < header.length; index++) {
            header[index] = string(abi.encodePacked("header_", convertUintToString(index)));
        }
        initCSV(filePath, header);

        for (uint256 rowIndex = 0; rowIndex < numberOfRows; rowIndex++) {
            string[] memory row = new string[](rowLength);

            for (uint256 columnIndex = 0; columnIndex < row.length; columnIndex++) {
                row[columnIndex] = convertUintToString(uint256(keccak256(abi.encodePacked("cell", convertUintToString(rowIndex), convertUintToString(columnIndex)))));
            }

            addRow(filePath, row);
        }

        writeFile(filePath);

        assertTrue(compareFiles(filePath, "tests/expected/large.csv"), "Files don't match");
    }

    function test_csv_mismatchedRows() external {
        string memory filePath = "output/teammates.csv";

        uint256 rowLength = 5;
        string[] memory header = new string[](rowLength);
        header[0] = "id";
        header[1] = "name";
        header[2] = "position";
        header[3] = "location";
        header[4] = "animal";

        initCSV(filePath, header);

        string[] memory row = new string[](rowLength + 1);

        row[0] = "0";
        row[1] = "Erick";
        row[2] = "Smart Contracts";
        row[3] = "Detroit";
        row[4] = "iguana";
        row[5] = "ROW IS TOO LONG";

        vm.expectRevert("Row length mismatch");
        addRow(filePath, row);

        row = new string[](rowLength);

        row[0] = "0";
        row[1] = "Erick";
        row[2] = "Smart Contracts";
        row[3] = "Detroit";
        row[4] = "iguana";

        addRow(filePath, row);
    }

    function test_csv_missingHeader() external {
        string memory filePath = "output/teammates.csv";

        uint256 rowLength = 5;
        string[] memory header = new string[](rowLength);
        header[0] = "id";
        header[1] = "name";
        header[2] = "";
        header[3] = "location";
        header[4] = "animal";

        vm.expectRevert("Missing header values");
        initCSV(filePath, header);

        header[2] = "position";
        initCSV(filePath, header);
    }
}