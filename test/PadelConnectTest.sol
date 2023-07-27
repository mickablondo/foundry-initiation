// SPDX-License-Identifier: MIT 
pragma solidity 0.8.20;

import "forge-std/Test.sol";
import "../src/PadelConnect.sol";

abstract contract HelperContract {
    address constant ADDRESS = 0xb4c79daB8f259C7Aee6E5b2Aa729821864227e84; // adresse des tests sur Foundry
    PadelConnect pc;
}

contract PadelConnectTest is Test, HelperContract {
    address owner = 0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496;
    address manager = makeAddr("Manager");
    address badManager = makeAddr("BadManager");

    event ManagerAdded(address _address);

    function setUp() public {
        pc = new PadelConnect(); // déploiement du Smart contract
    }

    function test_addManager() public { // test d'un cas passant
        pc.addManager(manager);
        assertTrue(pc.managers(manager));
    }

    function test_owner() public { // test du owner
        assertTrue(pc.owner() == owner);
    }

    function testFail_addManager() public { // test revert
        pc.addManager(address(0));
    }

    function testFail_addManagerFromManager() public { // test revert en forçant le signer
        vm.prank(manager);
        pc.addManager(badManager);
    }

    function test_ExpectEmit() public { // test événement émit
        vm.expectEmit(false, false, false, true);
        emit ManagerAdded(address(manager));
        pc.addManager(manager);
    }
}