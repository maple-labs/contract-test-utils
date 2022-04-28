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

        init(filePath, header);

        string[] memory row0 = new string[](5);
        header[0] = "0";
        header[1] = "Erick";
        header[2] = "Smart Contracts";
        header[3] = "Detroit";
        header[4] = "iguana";

        addRow(filePath, row0);

        string[] memory row1 = new string[](5);
        header[0] = "1";
        header[1] = "Lucas";
        header[2] = "Smart Contracts";
        header[3] = "Toronto";
        header[4] = "kangaroo";

        addRow(filePath, row1);

        string[] memory row2 = new string[](5);
        header[0] = "2";
        header[1] = "Bidin";
        header[2] = "Smart Contracts";
        header[3] = "Panama";
        header[4] = "giraffe";

        addRow(filePath, row2);

        string[] memory row3 = new string[](5);
        header[0] = "3";
        header[1] = "JG";
        header[2] = "Smart Contracts";
        header[3] = "Rio";
        header[4] = "elephant";

        addRow(filePath, row3);

        compareCSV(filePath, "tests/expected/csv1.csv");
    }
}