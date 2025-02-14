// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol"; // Importar el framework de pruebas de Foundry
import "../src/AaveLender.sol"; // Importar el contrato AaveLender

contract AaveLenderTest is Test {
    AaveLender public aaveLender;
    address public constant AAVE_POOL_ADDRESS = 0x48914C788295b5db23aF2b5F0B3BE775C4eA9440;
    address public constant STAKED_TOKEN_ADDRESS = 0x7984E363c38b590bB4CA35aEd5133Ef2c6619C40; // DAI en Scroll Sepolia
    address public user = address(1); // Dirección de un usuario ficticio

    function setUp() public {
        // Desplegar el contrato AaveLender antes de cada prueba
        aaveLender = new AaveLender();

        // Configurar el saldo de DAI para el usuario
        vm.deal(user, 100 ether); // Dar ETH al usuario (necesario para gas)
        vm.prank(user);
        IERC20(STAKED_TOKEN_ADDRESS).approve(address(aaveLender), type(uint256).max); // Aprobar el contrato para gastar DAI
    }

    function testStake() public {
        // Configurar el saldo de DAI para el usuario
        uint256 amount = 100 ether; // 100 DAI
        deal(STAKED_TOKEN_ADDRESS, user, amount); // Dar DAI al usuario

        // Verificar el saldo inicial del usuario
        uint256 initialBalance = IERC20(STAKED_TOKEN_ADDRESS).balanceOf(user);
        assertEq(initialBalance, amount);

        // Llamar a la función stake
        vm.prank(user);
        aaveLender.stake(amount);

        // Verificar que el saldo de DAI del usuario ha disminuido
        uint256 finalBalance = IERC20(STAKED_TOKEN_ADDRESS).balanceOf(user);
        assertEq(finalBalance, 0);

        // Verificar que el contrato AaveLender tiene los aDAI
        DataTypes.ReserveData memory reserveData = IPool(AAVE_POOL_ADDRESS).getReserveData(STAKED_TOKEN_ADDRESS);
        address aTokenAddress = reserveData.aTokenAddress;
        uint256 aTokenBalance = IERC20(aTokenAddress).balanceOf(address(aaveLender));
        assertEq(aTokenBalance, amount);
    }

    function testUnstake() public {
        // Configurar el saldo de DAI para el usuario
        uint256 amount = 100 ether; // 100 DAI
        deal(STAKED_TOKEN_ADDRESS, user, amount); // Dar DAI al usuario

        // Llamar a la función stake
        vm.prank(user);
        aaveLender.stake(amount);

        // Llamar a la función unstake
        vm.prank(user);
        aaveLender.unstake(amount);

        // Verificar que el usuario ha recuperado su DAI
        uint256 finalBalance = IERC20(STAKED_TOKEN_ADDRESS).balanceOf(user);
        assertEq(finalBalance, amount);

        // Verificar que el contrato AaveLender ya no tiene aDAI
        DataTypes.ReserveData memory reserveData = IPool(AAVE_POOL_ADDRESS).getReserveData(STAKED_TOKEN_ADDRESS);
        address aTokenAddress = reserveData.aTokenAddress;
        uint256 aTokenBalance = IERC20(aTokenAddress).balanceOf(address(aaveLender));
        assertEq(aTokenBalance, 0);
    }
}