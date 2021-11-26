// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ERC20Faucet{
    address private admin;
    mapping(address => bool) public approvedtokens;
    address[] approvedtokenList;
    uint tokenAmount = 10000000;
    ERC20 token;

    constructor() payable{
        admin = msg.sender;
    }
    
    //Withdraw function to dispense ERC20 tokens to requestor
    function withdraw (address tokenAddress, address payable to) external onlyApprovedTokens(tokenAddress){
       token  = ERC20(tokenAddress);
       token.transfer(to, tokenAmount); 
    }

    //Add Token addresses to enable them to be distributed using faucet
    //Admin can only make this call
    function addTokens(address tokenAddress) external adminOnly(){
        approvedtokens[tokenAddress] = true;
    }

     //Remove tokens from Faucet
    function removeTokens(address tokenAddress) external adminOnly(){
        approvedtokens[tokenAddress] = false;
    }

    function tokenBalance(address tokenAddress) external adminOnly() returns(uint){
        token  = ERC20(tokenAddress);
        return token.balanceOf(tokenAddress); 
    }

    //Empty Faucet and withdraw all ERC20 tokens
    // Used to recover ERC20 tokens from the contract
    function destroy() external adminOnly(){
        for(uint i=0; i<approvedtokenList.length;i++){
            token  = ERC20(approvedtokenList[i]);
            token.transfer(admin, token.balanceOf(address(this)));
        }
    }

    modifier onlyApprovedTokens(address tokenAddress){
        require(approvedtokens[tokenAddress] == true, "Only approved tokens");
        _;
    }

    modifier adminOnly(){
        require(msg.sender == admin, "Admin only");
        _;
    }
}