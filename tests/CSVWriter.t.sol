// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.7;

import { TestUtils } from "../contracts/test.sol";
import { CSVWriter } from "../contracts/csv.sol";

contract CSVWriterTests is TestUtils, CSVWriter {
    function setUp() public {} 

    function test_csv1() external {
        string memory filePath = "output/teammates.csv";

        string[] memory header = new string[](5);
        header[0] = "id";
        header[1] = "name";
        header[2] = "position";
        header[3] = "location";
        header[4] = "animal";

        initCSV(filePath, header);

        string[] memory row = new string[](5);

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
}