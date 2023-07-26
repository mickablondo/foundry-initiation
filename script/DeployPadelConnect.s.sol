// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { Script } from "forge-std/Script.sol";
import { PadelConnect } from "../src/PadelConnect.sol";

contract DeployPadelConnect is Script {

    function run() external returns(PadelConnect) {
        vm.startBroadcast();
        PadelConnect padelConnect = new PadelConnect();
        vm.stopBroadcast();
        return padelConnect;
    }
}