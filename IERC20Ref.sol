// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import  "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IERC20Ref is IERC20  {
    event RewardToRefer(address indexed account, address indexed refer, uint value);


    function rewardToRefer(address account, address refer, uint amount) external returns (uint256);
}