// SPDX-License-Identifier: MIT

pragma solidity >=0.4.22 <0.9.0;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.0/contracts/token/ERC20/ERC20.sol";

/**
 * @title PineappleToke
 * @author Asvoria Kuan<asvoria@live.com>
 * @dev Use solidity compiler version 0.8.1
 */

contract GOD is ERC20 {
    
    enum stages {
        STAGE_INIT,
        STAGE_FUNDING,
        STAGE_GRACE,
        STAGE_REPAYMENT,
        STAGE_END
    }
    // This is the current stage.
    stages public CURENT_STAGE = stages.STAGE_INIT;
    
    string public token_name = "GodsToken";    //Generated
    string public token_symbol = "GOD";        //Generated
    
    uint256 public tokenBuyRate = 1;
    //1 ether = 1,000,000,000,000,000,000 wei (10^18)
    
    uint256 public tokenPrice = 0.000001 ether;     //Fix 
    uint256 public initial_token_supply = 1e18;     //Fix
    address payable public deployWallet;
    
    // modifier
    modifier atStage(stages _stage) {
        require(
            CURENT_STAGE == _stage,
            "Function cannot be called at this time."
        );
        _;
    }
    
    modifier onlyOwner{
        require(msg.sender == deployWallet);
        _;
    }

    // function
    function nextStage() internal {
        CURENT_STAGE = stages(uint(CURENT_STAGE) + 1);
    }

    function buyTokens(uint256 tokensToBuy) public payable {
        address payable token_Wallet = payable(deployWallet);
        require(msg.sender != address(0));
        require(balanceOf(token_Wallet) > 0);
        uint256 etherUsed = tokensToBuy*(tokenBuyRate);
        require(etherUsed > 0);
        
        approve(payable(msg.sender), etherUsed);
        
        // Return extra ether when tokensToBuy > balances[deployWallet]
        if(tokensToBuy > balanceOf(token_Wallet)){
            uint256 exceedingTokens = tokensToBuy - (balanceOf(token_Wallet));
            uint256 exceedingEther = 0 ether;

            exceedingEther = exceedingTokens * (tokenBuyRate);
            payable(msg.sender).transfer(exceedingEther);
            tokensToBuy = tokensToBuy - (exceedingTokens);
            etherUsed = etherUsed - (exceedingEther);
        }

        transferFrom(token_Wallet,msg.sender,uint256(tokensToBuy));
        payable(token_Wallet).transfer(etherUsed);
    }

    constructor() ERC20(token_name,token_symbol){
        deployWallet = payable(address(msg.sender));
        _mint(deployWallet, (initial_token_supply));
    }
}
