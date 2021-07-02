// SPDX-License-Identifier: MIT

pragma solidity >=0.4.22 <0.9.0;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.0/contracts/token/ERC20/ERC20.sol";

/**
 * @title God Token
 * @author Jesus
 * @dev Use solidity compiler version 0.8.1
 */

contract GOD is ERC20 {
    
    IERC20 public token;

    string public token_name = "GodsToken";    //Generated
    string public token_symbol = "GOD";        //Generated

    //1 ether = 1,000,000,000,000,000,000 wei (10^18)
    
    uint256 public tokenPrice = 1e22;     //Fix 
    uint256 public initial_token_supply = 1e18;     //Fix
    address payable public deployWallet;
    
    // modifier
    modifier onlyOwner{
        require(msg.sender == deployWallet);
        _;
    }

    // function
    function buyTokens() public payable{
        
        address payable token_Wallet = payable(deployWallet);
        require(msg.sender != address(0));
        require(balanceOf(token_Wallet) > 0);
        uint256 etherUsed = msg.value;
        require(etherUsed > 0);
        uint256 tokensToBuy = (etherUsed/(tokenPrice/1e18));

        // Return extra ether when tokensToBuy > balances[tokenWallet]
        
        if(tokensToBuy > balanceOf(token_Wallet)){
            uint256 exceedingTokens = tokensToBuy - (balanceOf(token_Wallet));
            uint256 exceedingEther = 0;

            exceedingEther = exceedingTokens * (tokenPrice/1e18);
            payable(msg.sender).transfer(exceedingEther);
            tokensToBuy = tokensToBuy - (exceedingTokens);
            etherUsed = etherUsed - (exceedingEther);
        }
        
        _approve(token_Wallet, payable(msg.sender), tokensToBuy);

        transferFrom(token_Wallet,msg.sender,tokensToBuy);
        payable(token_Wallet).transfer(etherUsed);
    }

    constructor() ERC20(token_name,token_symbol){
        deployWallet = payable(address(msg.sender));
        _mint(deployWallet, (initial_token_supply));
    }
}
