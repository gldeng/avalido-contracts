// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import "openzeppelin-contracts/contracts/utils/Strings.sol";

// import "../ValidatorManager.sol";
import "../Oracle.sol";

import "./cheats.sol";

address constant ZERO_ADDRESS = 0x0000000000000000000000000000000000000000;
address constant USER1_ADDRESS = 0x0000000000000000000000000000000000000001;
address constant USER2_ADDRESS = 0x0000000000000000000000000000000000000002;
address constant ROLE_ORACLE_MANAGER = 0xf195179eEaE3c8CAB499b5181721e5C57e4769b2; // Wendy the whale gets to manage the oracle 🐳
string constant WHITELISTED_VALIDATOR_1 = "NodeID-P7oB2McjBGgW2NXXWVYjV8JEDFoW9xDE5";
string constant WHITELISTED_VALIDATOR_2 = "NodeID-GWPcbFJZFfZreETSoWjPimr846mXEKCtu";
string constant WHITELISTED_VALIDATOR_3 = "NodeID-NFBbbJ4qCmNaCzeW7sxErhvWqvEQMnYcN";
address constant WHITELISTED_ORACLE_1 = 0x03C1196617387899390d3a98fdBdfD407121BB67;
address constant WHITELISTED_ORACLE_2 = 0x6C58f6E7DB68D9F75F2E417aCbB67e7Dd4e413bf;
address constant WHITELISTED_ORACLE_3 = 0xa7bB9405eAF98f36e2683Ba7F36828e260BD0018;
address constant WHITELISTED_ORACLE_4 = 0xE339767906891bEE026285803DA8d8F2f346842C;
address constant WHITELISTED_ORACLE_5 = 0x0309a747a34befD1625b5dcae0B00625FAa30460;

abstract contract Helpers {
    function validatorSelectMock(
        address oracle,
        string memory node,
        uint256 amount,
        uint256 remaining
    ) public {
        string[] memory idResult = new string[](1);
        idResult[0] = node;

        uint256[] memory amountResult = new uint256[](1);
        amountResult[0] = amount;

        cheats.mockCall(
            oracle,
            abi.encodeWithSelector(Oracle.selectValidatorsForStake.selector),
            abi.encode(idResult, amountResult, remaining)
        );
    }

    function timeFromNow(uint256 time) public view returns (uint64) {
        return uint64(block.timestamp + time);
    }

    // TODO: Some left-padding or similar to match real-world node IDs would be nice.
    function nodeId(uint256 num) public pure returns (string memory) {
        return string(abi.encodePacked("NodeID-", Strings.toString(num)));
    }

    function nValidatorsWithFreeSpace(
        uint256 n,
        uint64 endTime,
        uint256 freeSpace
    ) public pure returns (ValidatorData[] memory) {
        ValidatorData[] memory result = new ValidatorData[](n);
        for (uint256 i = 0; i < n; i++) {
            result[i] = ValidatorData(nodeId(i), endTime, freeSpace);
        }
        return result;
    }

    function mixOfBigAndSmallValidators() public view returns (ValidatorData[] memory) {
        ValidatorData[] memory smallValidators = nValidatorsWithFreeSpace(7, timeFromNow(30 days), 0.5 ether);
        ValidatorData[] memory bigValidators = nValidatorsWithFreeSpace(7, timeFromNow(30 days), 100 ether);

        ValidatorData[] memory validators = new ValidatorData[](smallValidators.length + bigValidators.length);

        for (uint256 i = 0; i < smallValidators.length; i++) {
            validators[i] = smallValidators[i];
        }
        for (uint256 i = 0; i < bigValidators.length; i++) {
            validators[smallValidators.length + i] = bigValidators[i];
        }

        return validators;
    }

    function stringArrayContains(string memory stringToCheck, string[] memory arrayOfStrings)
        public
        pure
        returns (bool)
    {
        for (uint256 i = 0; i < arrayOfStrings.length; i++) {
            if (keccak256(abi.encodePacked(arrayOfStrings[i])) == keccak256(abi.encodePacked(stringToCheck))) {
                return true;
            }
        }
        return false;
    }

    function addressArrayContains(address addressToCheck, address[] memory arrayOfAddresses)
        public
        pure
        returns (bool)
    {
        for (uint256 i = 0; i < arrayOfAddresses.length; i++) {
            if (keccak256(abi.encodePacked(arrayOfAddresses[i])) == keccak256(abi.encodePacked(addressToCheck))) {
                return true;
            }
        }
        return false;
    }
}
