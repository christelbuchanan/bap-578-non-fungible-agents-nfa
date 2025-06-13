// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./BEP007Enhanced.sol";

contract BEP007EnhancedImpl is BEP007Enhanced {
    function createAgent(
        address to,
        address logicAddress,
        string memory metadataURI,
        AgentMetadata memory extendedMetadata
    ) external override returns (uint256 tokenId) {}

    function setLogicAddress(uint256 tokenId, address newLogic) external override  {
        revert("Not implemented");
    }

    function fundAgent(uint256 tokenId) external payable override {
        revert("Not implemented");
    }

    function getState(uint256 tokenId) external view override returns (State memory) {
        revert("Not implemented");
    }

    function pause(uint256 tokenId) external override {
        revert("Not implemented");
    }

    function unpause(uint256 tokenId) external override {
        revert("Not implemented");
    }

    function terminate(uint256 tokenId) external override {
        revert("Not implemented");
    }

    function updateAgentMetadata(
        uint256 tokenId,
        AgentMetadata memory metadata
    ) external override virtual {
        revert("Not implemented");
    }

    function registerExperienceModule(uint256 tokenId, address moduleAddress) external override {
        revert("Not implemented");
    }

    function withdrawFromAgent(uint256 tokenId, uint256 amount) external override {
        revert("Not implemented");
    }

    function setAgentMetadataURI(uint256 tokenId, string memory newMetadataURI) external override {
        revert("Not implemented");
    }
}