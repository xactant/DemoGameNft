// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

/// @notice Interface that defines a contract that is used to mint game reward assets.
interface IGameRewardMinter {
    /// @notice Mints a single game reward asset
    /// @param account - Address to tranfer to after minting.
    /// @param id - Token Id
    /// @param amount - number of tokens to mint.
    /// @param url - url unique to this token
    /// @param data - token data
    function mint(address account, uint256 id, uint256 amount, string memory url, bytes memory data) external;
    /// @notice Mints a batch of game reward assets, can be different types of assets
    /// @param to - Address to tranfer to after minting.
    /// @param ids - Token Id
    /// @param amounts - number of tokens to mint.
    /// @param urls - url unique to this token
    /// @param data - token data
    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, string[] memory urls, bytes memory data) external;
}