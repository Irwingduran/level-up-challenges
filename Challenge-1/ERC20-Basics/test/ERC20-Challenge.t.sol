// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/ERC20-Challenge.sol";

contract ERC20ChallengeTest is Test {
    ERC20Challenge private token;
    address private owner = address(0x123);
    address private user1 = address(0x456);
    address private user2 = address(0x789);

    function setUp() public {
        vm.prank(owner);
        token = new ERC20Challenge("TestToken", "TTK", 18);
        token.mint(owner, 1000 * 10**18);
    }

    function testTransfer() public {
        uint256 amount = 100 * 10**18;
        vm.prank(owner);
        token.transfer(user1, amount);

        assertEq(token.balanceOf(user1), amount);
        assertEq(token.balanceOf(owner), 900 * 10**18);
    }

    function testTransferFrom() public {
        uint256 amount = 100 * 10**18;
        vm.prank(owner);
        token.approve(user1, amount);

        vm.prank(user1);
        token.transferFrom(owner, user2, amount);

        assertEq(token.balanceOf(user2), amount);
        assertEq(token.balanceOf(owner), 900 * 10**18);
    }

    function testMint() public {
        uint256 amount = 500 * 10**18;
        vm.prank(owner);
        token.mint(user1, amount);

        assertEq(token.balanceOf(user1), amount);
        assertEq(token.totalSupply(), 1500 * 10**18);
    }

    function testBurn() public {
        uint256 amount = 100 * 10**18;
        vm.prank(owner);
        token.burn(amount);

        assertEq(token.balanceOf(owner), 900 * 10**18);
        assertEq(token.totalSupply(), 900 * 10**18);
    }

    function testFailTransferInsufficientBalance() public {
        uint256 amount = 2000 * 10**18;
        vm.prank(owner);
        token.transfer(user1, amount); // Debería fallar
    }

    function testTransferEvent() public {
        uint256 amount = 100 * 10**18;
        vm.expectEmit(true, true, false, true);
        emit Transfer(owner, user1, amount);

        vm.prank(owner);
        token.transfer(user1, amount);
    }
}