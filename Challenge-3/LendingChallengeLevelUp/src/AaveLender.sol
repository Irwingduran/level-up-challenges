// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

library DataTypes {
    struct ReserveConfigurationMap {
        uint256 data;
    }

    struct ReserveData {
        ReserveConfigurationMap configuration;
        uint128 liquidityIndex;
        uint128 currentLiquidityRate;
        uint128 variableBorrowIndex;
        uint128 currentVariableBorrowRate;
        uint128 currentStableBorrowRate;
        uint40 lastUpdateTimestamp;
        uint16 id;
        address aTokenAddress;
        address stableDebtTokenAddress;
        address variableDebtTokenAddress;
        address interestRateStrategyAddress;
        uint128 accruedToTreasury;
        uint128 unbacked;
        uint128 isolationModeTotalDebt;
    }
}

interface IPool {
    function supply(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16 referralCode
    ) external;

    function withdraw(
        address asset,
        uint256 amount,
        address to
    ) external returns (uint256);

    function getReserveData(
        address asset
    ) external view returns (DataTypes.ReserveData memory);
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

contract AaveLender {
    address public immutable AAVE_POOL_ADDRESS = 0x48914C788295b5db23aF2b5F0B3BE775C4eA9440;
    address public immutable STAKED_TOKEN_ADDRESS = 0x7984E363c38b590bB4CA35aEd5133Ef2c6619C40;

    function stake(uint256 amount) public {
        // Transfer DAI to this contract
        IERC20(STAKED_TOKEN_ADDRESS).transferFrom(msg.sender, address(this), amount);

        // Approve Aave Pool to manage DAI
        IERC20(STAKED_TOKEN_ADDRESS).approve(AAVE_POOL_ADDRESS, amount);

        // Supply DAI to Aave Pool
        IPool(AAVE_POOL_ADDRESS).supply(
            STAKED_TOKEN_ADDRESS,
            amount,
            msg.sender,
            0
        );
    }

    function unstake(uint256 amount) public {
        // Retrieve aDAI address
        DataTypes.ReserveData memory reserveData = IPool(AAVE_POOL_ADDRESS).getReserveData(STAKED_TOKEN_ADDRESS);
        address aTokenAddress = reserveData.aTokenAddress;

        // Transfer aDAI to this contract
        IERC20(aTokenAddress).transferFrom(msg.sender, address(this), amount);

        // Approve Aave Pool to manage aDAI
        IERC20(aTokenAddress).approve(AAVE_POOL_ADDRESS, amount);

        // Withdraw DAI from Aave Pool
        IPool(AAVE_POOL_ADDRESS).withdraw(
            STAKED_TOKEN_ADDRESS,
            amount,
            msg.sender
        );
    }
}