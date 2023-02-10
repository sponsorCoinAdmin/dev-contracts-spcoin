// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;
/// @title ERC20 Contract
import "./KYC.sol";
import "./utils/Utils.sol";

contract AccountRecords is KYC, Utils{

   // Keep track of account insertions
   address[] public accountIndex;
   address[] public sponsorIndex;
   address[] public agentIndex;
   uint public lastStakingUpdateTime = block.timestamp;

   struct accountRec {
       sponsorRec[] sponsors;
       uint index;
       uint insertionTime;
       bool inserted;
       kyc KYC;
       bool verified;
    }
    struct rateRec {
       uint rate;
       uint insertionTime;
       uint lastUpdateTime;
       uint256 quantity;
    }
    struct agentRec {
       address addr;
       uint rate;
    }
    mapping(address => accountRec)  accounts;
    // mapping(address => sponsorRec)  sponsors;
    // mapping(address => agentRec)  agents;

    constructor(){
    }

    /// @notice determines if address is inserted in account array
    /// @param _accountKey public account key validate Insertion
    function isInserted(address _accountKey) public onlyOwnerOrRootAdmin(_accountKey) view returns (bool) {
        if (accounts[_accountKey].inserted)
            return true;
        else
            return false;
    }

    /// @notice insert address for later recall
    /// @param _accountKey public account key to get sponsor array
    /// @param _sponsorKey new sponsor to add to account list
    function insertAccountSponsor(address _accountKey, address _sponsorKey) public onlyOwnerOrRootAdmin(_accountKey) returns (bool) {
        insertAccount(_accountKey);
        insertAccount(_sponsorKey);
        accountRec storage account = accounts[_accountKey];
        uint256 insertionTime = block.timestamp;

        sponsorRec memory newSponsor;
        newSponsor.addr = _sponsorKey;
        newSponsor.rate = 10;

        account.sponsors.push(newSponsor);
        return true;
    }

    /// @notice get address for an account sponsor
    /// @param _accountKey public account key to get sponsor array
    /// @param _sponsorIdx new sponsor to add to account list
    function getAccountSponsorKey(address _accountKey, uint _sponsorIdx ) public view onlyOwnerOrRootAdmin(_accountKey) returns (address) {
        // console.log("getAccountSponsorKey(");
        // console.log("_accountKey = ");
        // console.log(_accountKey);
        // console.log("_sponsorIdx = ");
        // console.log(_sponsorIdx);
        // console.log(")");

        address sponsoraddr = accounts[_accountKey].sponsors[_sponsorIdx].addr;
        return sponsoraddr;
    }

    /// @notice insert address for later recall
    /// @param _accountKey public account key to set new balance
    /// @return true if balance is set, false otherwise
    function insertAccount(address _accountKey) public onlyOwnerOrRootAdmin(_accountKey) returns (bool) {
         if (!isInserted(_accountKey)) {
            accounts[_accountKey].insertionTime = block.timestamp;
            accounts[_accountKey].inserted = true;
            accounts[_accountKey].index = accountIndex.length;
            accountIndex.push(_accountKey);
            // console.log("Returning TRUE");
            return true;
         }
            // console.log("Returning FALSE");
            return false;
    }

    /// @notice retreives the array record size a specific address.
    /// @param _accountKey public account key to get Sponsor Record Length
    function getSponsorRecordCount(address _accountKey) public view onlyOwnerOrRootAdmin(_accountKey) returns (uint) {
        return getAccountSponsors(_accountKey).length;
    }

   function getAccountSponsors(address _accountKey) internal view onlyOwnerOrRootAdmin(_accountKey) returns (sponsorRec[] memory) {
        return accounts[_accountKey].sponsors;
    }


    /// @notice retreives the array index of a specific address.
    /// @param _accountKey public account key to set new balance
    function getindex(address _accountKey) public onlyOwnerOrRootAdmin(_accountKey) view returns (uint) {
        if (isInserted(_accountKey))
            return accounts[_accountKey].index;
        else
            return 0;
    }

    /// @notice retreives the array index of a specific address.
     function getAccountRecordCount() public view returns (uint) {
        return accountIndex.length;
      }

    /// @notice retreives a specified account address from accountIndex.
    /// @param _idx index of a specific account in accountIndex
     function getAccount(uint _idx) public view returns (address) {
        return accountIndex[_idx];
      }

    /// @notice retreives the account record of a specific account address.
    /// @param _accountKey public account key to set new balance
    function getAccountRecord(address _accountKey) internal onlyOwnerOrRootAdmin(_accountKey) view returns (accountRec storage) {
        require (isInserted(_accountKey));
        return accounts[_accountKey];
    }

    /// @notice retreives the account balance of a specific address.
    function getSponsorRecCount() public view returns (uint) {
        return getSponsorRecords().length;
    }
    
   /// @notice retreives the account balance of a specific address.
    function getSponsorRecords() internal view returns (sponsorRec[] memory) {
        return getSponsorRecords(msg.sender);
    }
    
    /// @notice retreives the account balance of a specific address.
    /// @param _accountKey public account key to set new balance
    function getSponsorRecords(address _accountKey) internal onlyOwnerOrRootAdmin(_accountKey) view returns (sponsorRec[] memory) {
        sponsorRec[] storage actSponsor = accounts[_accountKey].sponsors;
        return actSponsor;
    }
}