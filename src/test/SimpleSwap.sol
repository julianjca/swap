// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0;

import {DSTest} from "ds-test/test.sol";
import {Utilities} from "./utils/Utilities.sol";
import {console} from "./utils/Console.sol";
import {Vm} from "forge-std/Vm.sol";

import {SimpleSwap, NFTStruct} from "../SimpleSwap.sol";
import {SimpleERC721NFT} from "../SimpleERC721NFT.sol";

contract ContractTest is DSTest {
    Vm internal immutable vm = Vm(HEVM_ADDRESS);

    Utilities internal utils;
    address payable[] internal users;

    SimpleSwap internal swapContract;
    SimpleERC721NFT internal simpleERC721NFTContract;

    address payable internal alice;
    address payable internal bob;

    function setUp() public {
        utils = new Utilities();
        users = utils.createUsers(5);
        swapContract = new SimpleSwap();
        simpleERC721NFTContract = new SimpleERC721NFT(
            "Simple NFT",
            "SNFT",
            "https://1"
        );

        vm.label(alice, "Alice");
        vm.label(bob, "Bob");

        alice = users[0];
        bob = users[1];

        // mint for alice and bob
        vm.prank(alice);
        simpleERC721NFTContract.mint{value: 0 ether}(5);
        simpleERC721NFTContract.setApprovalForAll(address(swapContract), true);

        vm.prank(bob);
        simpleERC721NFTContract.mint{value: 0 ether}(5);
        simpleERC721NFTContract.setApprovalForAll(address(swapContract), true);

        assertEq(simpleERC721NFTContract.balanceOf(alice), 5);
        assertEq(simpleERC721NFTContract.balanceOf(bob), 5);
    }

    function testCreateNoValueSwap() public {
        vm.prank(alice);

        NFTStruct[] memory offeredNFT;
        NFTStruct[] memory counterPartyNFT;

        swapContract.createSwap{value: 0 ether}(
            bob,
            0,
            offeredNFT,
            counterPartyNFT
        );

        // check if it's created
        assertEq(swapContract.getSwaps(alice).length, 1);
        assertEq(swapContract.getSwaps(bob).length, 1);
    }

    function testCreateSwap1() public {
        vm.prank(alice);

        NFTStruct[] memory offeredNFT;
        NFTStruct[] memory counterPartyNFT = new NFTStruct[](1);

        uint256[] memory tokenIDs = new uint256[](3);
        tokenIDs[0] = 8;
        tokenIDs[1] = 9;
        tokenIDs[2] = 10;

        counterPartyNFT[0] = NFTStruct(
            address(simpleERC721NFTContract),
            tokenIDs
        );

        swapContract.createSwap{value: 0 ether}(
            bob,
            0,
            offeredNFT,
            counterPartyNFT
        );

        // check if it's created
        assertEq(swapContract.getSwaps(alice).length, 1);
        assertEq(swapContract.getSwaps(bob).length, 1);

        NFTStruct[] memory cp = swapContract.getCounterPartyNFT(0);

        assertEq(cp[0].tokenContract, address(simpleERC721NFTContract));
        assertEq(cp[0].tokenId.length, 3);
    }
}
