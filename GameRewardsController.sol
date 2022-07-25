// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

/**
 *           Module: GameRewardsController.sol
 *  Descriptiontion: Defines a proxy contract that is used to drive game rewards.
 *                   THIS IS SAMPLE CODE DO NOT USE IN A PRODUCTION ENVIRONMENT.
 *           Author: Moralis Web3 Technology AB, 559307-5988 - David B. Goodrich
 *  
 *  MIT License
 *  
 *  Copyright (c) 2022 Moralis Web3 Technology AB, 559307-5988
 *  
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to deal
 *  in the Software without restriction, including without limitation the rights
 *  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *  copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *  
 *  The above copyright notice and this permission notice shall be included in all
 *  copies or substantial portions of the Software.
 *  
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 *  SOFTWARE.
 */
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC1155.sol";
import "./IGameRewardMinter.sol";
// deployed to mumbai at 0x05af21b57d2E378F90106B229E717DC96c7Bb5e2
/// @notice Defines a proxy contract that is used to drive game rewards.
///         THIS IS SAMPLE CODE DO NOT USE IN A PRODUCTION ENVIRONMENT.
/// @dev This contract must have minter role in the target contract.
contract GameRewardsController is ERC1155, ERC1155Holder, Ownable {
    address NFT_CONTRACT_TARGET;


    constructor(address nftContractAddress) Ownable() ERC1155("") {
        NFT_CONTRACT_TARGET = nftContractAddress;
    }

    /// @notice Performs a one time mint of the token using this contract as the owner.
    /// @dev This function can only be called by the contract owner.
    function mint(uint256 id, uint256 amount, string memory url, bytes memory data)
        public onlyOwner {
        address account = address(this);
        // Token cannot already exist
        require(!hasToken(account, id), "Token has already been minted.");
        require(amount > 0, "Cannot mint less than 1 token.");

        IGameRewardMinter con = IGameRewardMinter(NFT_CONTRACT_TARGET);
        // Mint the token
        con.mint(account, id, amount, url, data);
    }

    /// @notice Allows owner update the target contract.
    function updateTargetContract(address contractAddress) public onlyOwner {
        require(contractAddress != address(0), "Must be a contract address");
        NFT_CONTRACT_TARGET = contractAddress;
    }

    /// @notice Enables an account to claim a one time award.
    /// @dev NOTE this functions not question the call other than that the 
    ///      msg.sender does not already own the token. It makes no assumptions 
    ///      on eligibility, etc.
    function claimReward(uint256 id) public {
        address account = address(this);
        // Cannot already own the reward
        require(!hasToken(msg.sender, id), "You have already claimed this reward.");
        // Some rewards must be available.
        require(hasToken(account, id), "Reward no longer available.");

        bytes memory _data = '0';
        IERC1155 con = IERC1155(NFT_CONTRACT_TARGET);
        // Transfer a token to the requestor.
        con.safeTransferFrom(account, msg.sender, id, 1, _data);
    }

    /// @notice Determines if the target account owns the target token.
    /// @param account - target owner address
    /// @param id - id of the token to check
    /// @return bool
    function hasToken(address account, uint256 id) internal view returns(bool) {
        IERC1155 con = IERC1155(NFT_CONTRACT_TARGET);

        return (con.balanceOf(account, id) > 0);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155, ERC1155Receiver) returns (bool) {
    return interfaceId == type(IERC1155).interfaceId
        || interfaceId == type(IERC1155Receiver).interfaceId
        || super.supportsInterface(interfaceId);
    }
}