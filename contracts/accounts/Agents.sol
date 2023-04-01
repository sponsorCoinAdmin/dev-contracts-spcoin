// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
/// @title ERC20 Contract
import "./SponsorRates.sol";
import "../utils/StructSerialization.sol";

contract Agents is SponsorRates {
        constructor(){
    }

    /// @notice insert sponsors Agent
    /// @param _patreonKey public Sponsor Coin Account Key
    /// @param _sponsorKey public account key to get sponsor array
    /// @param _agentKey new sponsor to add to account list
    function addSponsorAgent(address _patreonKey, address _sponsorKey, uint _sponsorRateKey, address _agentKey)
            public onlyOwnerOrRootAdmin(msg.sender) 
            nonRedundantAgent ( _patreonKey, _sponsorKey, _agentKey) {
        addSponsorRate(_patreonKey, _sponsorKey, _sponsorRateKey);
        addAccountRecord(_agentKey);

        AccountStruct storage accountSponsorRec = accountMap[_sponsorKey];
        AccountStruct storage accountAgentRec = accountMap[_agentKey];
        SponsorStruct storage patreonSponsorRec = getSponsorRecordByKeys(_patreonKey, _sponsorKey);
        AgentStruct storage  sponsorAgentRec = getAgentRecordByKeys(_patreonKey, _sponsorKey, _agentKey);
        if (!sponsorAgentRec.inserted) {
            sponsorAgentRec.index = patreonSponsorRec.agentRecordKeys.length;
            sponsorAgentRec.insertionTime = block.timestamp;
            sponsorAgentRec.agentAccountKey = _agentKey;
            sponsorAgentRec.inserted = true;
            patreonSponsorRec.agentRecordKeys.push(_agentKey);
            accountSponsorRec.agentRecordKeys.push(_agentKey);
            accountAgentRec.accountParentSponsorKeys.push(_sponsorKey);
        }
    }

    /// @notice Remove all sponsorship relationships for Patreon and Sponsor accounts
    /// @param _patreonKey Patreon key containing the Sponsor relationship
    /// @param _sponsorKey Sponsor to be removed from the Sponsor relationship
    function deletePatreonSponsorRecord(address _patreonKey, address _sponsorKey)  
        public onlyOwnerOrRootAdmin(_patreonKey)
        accountExists(_patreonKey)
        accountExists(_sponsorKey)
        nonRedundantSponsor ( _patreonKey,  _sponsorKey) {
    
        AccountStruct storage patreonAccountRec = accountMap[_patreonKey];
        SponsorStruct storage sponsorRec = patreonAccountRec.sponsorMap[_sponsorKey];
        uint256 totalSponsoed = sponsorRec.totalAgentsSponsored;

        // console.log("BEFORE patreonAccountRec.balanceOf     = ", patreonAccountRec.balanceOf);
        // console.log("BEFORE patreonAccountRec.stakedSPCoins = ", patreonAccountRec.stakedSPCoins);
        // console.log("BEFORE totalSponsoed                   = ", totalSponsoed);
        patreonAccountRec.balanceOf += totalSponsoed;
        patreonAccountRec.stakedSPCoins -= totalSponsoed;
        // console.log("AFTER patreonAccountRec.balanceOf     = ", patreonAccountRec.balanceOf);
        // console.log("AFTER patreonAccountRec.stakedSPCoins = ", patreonAccountRec.stakedSPCoins);

        address[] storage patreonSponsorKeys = patreonAccountRec.agentRecKeys;
        if (deleteAccountRecordFromSearchKeys(_sponsorKey, patreonSponsorKeys)) {
            deleteSponsorRecord(_patreonKey, _sponsorKey);
        }
    }

    function deleteSponsorRecord(address _patreonKey, address _sponsorKey) internal {
        AccountStruct storage sponsorAccountRec = accountMap[_sponsorKey];
        address[] storage accountPatreonKeys = sponsorAccountRec.accountPatreonKeys;
        if (deleteAccountRecordFromSearchKeys(_patreonKey, accountPatreonKeys)) {
            deletePatreonSponsorAgentRecordRecords (_patreonKey, _sponsorKey);
        }
        // Optional        delete accountMap[_sponsorKey];
    }

    function deletePatreonSponsorAgentRecordRecords (address _patreonKey, address _sponsorKey) internal {
        // Get The Patreon Account Record and Remove from the Child Sponsor Relationship account list
        AccountStruct storage patreonAccountRec = accountMap[_patreonKey];
        mapping(address => SponsorStruct) storage sponsorMap = patreonAccountRec.sponsorMap;

        // console.log("deleteAgentsFromSponsor(_sponsorKey, sponsorMap)");
        mapping(address => AgentStruct) storage agentMap = sponsorMap[_sponsorKey].agentMap;
        address[] storage agentRecordKeys = sponsorMap[_sponsorKey].agentRecordKeys;

        uint i = agentRecordKeys.length - 1;
        // console.log("*** BEFORE AGENT DELETE agentRecordKeys.length = ", agentRecordKeys.length);
         for (i; i >= 0; i--) {
            deletePatreonSponsorAgentRecordRecord(_sponsorKey, agentRecordKeys[i]); 
            // console.log("***** Deleting agentRecordKeys ", agentStruct.agentAccountKey);
            delete agentMap[agentRecordKeys[i]];
            delete agentRecordKeys[i];
            agentRecordKeys.pop();
            if (i == 0)
               break;
        }
    }

    function deletePatreonSponsorAgentRecordRecord (address _sponsorKey, address _agentKey) public {
        // console.log("Deleting Agent Key ", _agentKey, "from Sponsor child Agent Keys ", _sponsorKey); 
        AccountStruct storage accountSponsorRec = accountMap[_sponsorKey];
        address[] storage AgentKeys = accountSponsorRec.agentRecordKeys;
        if (deleteAccountRecordFromSearchKeys(_agentKey, AgentKeys)) {
            deleteSponsorParentFromAgent (_sponsorKey, _agentKey);
        }
    }

    function deleteSponsorParentFromAgent (address _sponsorKey, address _agentKey) internal {
        // console.log("Deleting Sponsor Key ", _sponsorKey, "from Agent Parent Sponsor Keys ", _agentKey); 
        AccountStruct storage accountAgentRec = accountMap[_agentKey];

        address[] storage parentSponsorKeys = accountAgentRec.accountParentSponsorKeys;
        deleteAccountRecordFromSearchKeys(_sponsorKey, parentSponsorKeys);
    }

    /// @notice determines if agent address is inserted in account.sponsor.agent.map
    /// @param _patreonKey public account key validate Insertion
    /// @param _sponsorKey public sponsor account key validate Insertion
    /// @param _agentKey public agent account key validate Insertion
    function isAgentInserted(address _patreonKey,address _sponsorKey,address _agentKey) public onlyOwnerOrRootAdmin(_patreonKey) view returns (bool) {
        return getAgentRecordByKeys(_patreonKey, _sponsorKey, _agentKey).inserted;
    }

    function getAgentTotalSponsored(address _patreonKey, address _sponsorKey, address _agentKey) public view onlyOwnerOrRootAdmin(_sponsorKey) returns (uint) {
        AgentStruct storage agentRec = getAgentRecordByKeys(_patreonKey, _sponsorKey, _agentKey);
        // console.log("Agents.sol:agentRec.totalRatesSponsored  = ", agentRec.totalRatesSponsored);
        return agentRec.totalRatesSponsored; 
    }

    function getAgentIndex(address _patreonKey, address _sponsorKey, address _agentKey) public onlyOwnerOrRootAdmin(_patreonKey) view returns (uint) {
        if (isAgentInserted(_patreonKey, _sponsorKey, _agentKey)) {
            return accountMap[_patreonKey].sponsorMap[_sponsorKey].agentMap[_agentKey].index;
        }
        else
            return 0;
    }

    /// @notice retreives the sponsor array records from a specific account address.
    /// @param _patreonKey patreon Key to retrieve the sponsor list
    /// @param _sponsorKey sponsor Key to retrieve the agent list
    /// @param _agentKey agent Key to retrieve the agentate list
    function getAgentRateKeys(address _patreonKey, address _sponsorKey, address _agentKey) public view onlyOwnerOrRootAdmin(_sponsorKey) returns (uint[] memory) {
        AgentStruct storage agentRec = getAgentRecordByKeys(_patreonKey, _sponsorKey, _agentKey);
        uint[] memory agentRateKeys = agentRec.agentRateKeys;
// console.log("AGENTS.SOL:addSponsorAgent: _patreonKey, _sponsorKey, _sponsorRateKey, _agentKey = " , _patreonKey, _sponsorKey, _sponsorRateKey, _agentKey);
// console.log("AGENTS.SOL:addSponsorAgent:agentRec.agentAccountKey = " , agentRec.agentAccountKey);
// console.log("AGENTS.SOL:getAgentRateKeys:agentRateKeys.length = ",agentRateKeys.length);
        return agentRateKeys;
    }
}
