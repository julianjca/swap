// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0;

import {DSTest} from "ds-test/test.sol";
import {Utilities} from "./utils/Utilities.sol";
import {console} from "./utils/Console.sol";
import {Vm} from "forge-std/Vm.sol";

import {SimpleSwap} from "../SimpleSwap.sol";

contract ContractTest is DSTest {
    Vm internal immutable vm = Vm(HEVM_ADDRESS);

    Utilities internal utils;
    address payable[] internal users;

    SimpleSwap internal swapContract;

    address payable alice;
    address payable bob;

    function setUp() public {
        utils = new Utilities();
        users = utils.createUsers(5);
        swapContract = new SimpleSwap();

        vm.label(alice, "Alice");
        vm.label(bob, "Bob");

        alice = users[0];
        bob = users[1];
    }

    function testCreateSwap() public {
        vm.prank(alice);

        swapContract.createSwap{value: 0 ether}(bob, 0);

        // check if it's created
        assertEq(swapContract.getSwaps(alice).length, 1);
        assertEq(swapContract.getSwaps(bob).length, 1);
    }
}
