// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IERC20Ref.sol";


contract ERC20Ref is ERC20, IERC20Ref, Ownable{
    uint256 public rewardPercent;    //rewardPercentage

    mapping(address=>bool) private _isRewardToReferCaller;
    address[] private _rewardToReferCallers;

    bool inRewarding;
    mapping(address =>uint256) public totalReward;  //total reward received by refer

    event SetRewardPercent(uint256 oldPercent, uint256 newPercent);
    event AddRewardToReferCaller(address indexed account);
    event RemoveRewardToReferCaller(address indexed account);


    string public constant TOKEN_NAME = "bunny";
    string public constant TOKEN_SYMBOL = "bunny";

    modifier onlyRewardToReferCaller() {
        require(_isRewardToReferCaller[_msgSender()], "not authorized");
        _;
    }

    modifier lockRewarding () {
        require(!inRewarding, "in rewarding");
        inRewarding = true;
        _;
        inRewarding = false;
    }

    constructor( ) ERC20(TOKEN_NAME, TOKEN_SYMBOL) {
        uint256 _initalSupply = 10000;
        _mint(msg.sender, _initalSupply * 10 ** uint256(decimals()));
    }


    function mint(address account, uint256 value) public onlyOwner {
        _mint(account, value);
    }


    function addRewardToReferCaller(address account) public onlyOwner{
        require(account != address(0), "caller is zero address");
        require(!_isRewardToReferCaller[account], "caller already exist in rewardToReferCaller");
        _isRewardToReferCaller[account] =true;
        _rewardToReferCallers.push(account);
        emit AddRewardToReferCaller(account);
    }


    function removeRewardToReferCaller(address account) public onlyOwner{
        require(_isRewardToReferCaller[account], "caller doesn't exist in rewardToReferCaller");
        for (uint256 i = 0; i < _rewardToReferCallers.length; i++) {
            if (_rewardToReferCallers[i] == account) {
                _rewardToReferCallers[i] = _rewardToReferCallers[_rewardToReferCallers.length - 1];
                _isRewardToReferCaller[account] = false;
                _rewardToReferCallers.pop();
                break;
            }
        }
        emit RemoveRewardToReferCaller(account);
    }

    function setRewardPercent(uint256 percent) external onlyOwner{
        require(percent <= 100, "percent > 100");
        uint256 old = rewardPercent;
        rewardPercent = percent;
        emit SetRewardPercent(old, rewardPercent);
    }

    function getrewardToReferCallers() public view returns(address[] memory){
        return _rewardToReferCallers;
    }


    function rewardToRefer(address account, address refer, uint256 amount) external override onlyRewardToReferCaller lockRewarding returns (uint256) {
        require(account != address(0),"address is zero address");
        require(refer != address(0),"refer is zero address");
        require(account != refer, "refer is same to account");
        require(amount >0, "amount is 0");
        require(amount <= totalSupply(), "amount exceed totalsupply");

        uint256 _reward;
        _reward = amount*rewardPercent/100 ;

        _mint(msg.sender, _reward);
        totalReward[refer] = totalReward[refer] + _reward;
        emit RewardToRefer(account, refer, _reward);
        return _reward;
    }

} 