const { TEST_HH_ACCOUNT_LIST } = require("./hhTestAccounts");
const { SpCoinAddMethods } = require("../../prod/lib/spCoinAddMethods");
const {} = require("../../prod/lib/utils/logging");
let hhTestElements = undefined;
let spCoinAddMethods = new SpCoinAddMethods();

class SpCoinTestMethods {

  constructor( ) { }
   
  getTestHHAccountKey = async ( _idx ) => {
    if (hhTestElements === undefined) {
      hhTestElements = await initHHAccounts();
    }
    const signers = hhTestElements.signers;
    const accounts = hhTestElements.accounts;
    const rates = hhTestElements.rates;
    return accounts[_idx];
  }

//////////////////////////// TEST ACCOUNT METHODS ////////////////////////////
  addTestNetworkAccount = async ( _accountIdx ) => {
    logFunctionHeader("addTestNetworkAccount = async (" + _accountIdx + ")");
    let accountKey = await getTestHHAccountKey(_accountIdx);
    logDetail("JS => For Adding Account Record: " + accountKey );
    await spCoinAddMethods.AccountRecord(accountKey);
    logExitFunction();
  };

  addTestNetworkAccounts = async ( _accountList ) => {
    logFunctionHeader("addTestNetworkAccounts = async (" + _accountList + ")");
    let testHHAccountList = await getTestHHAccountListKeys(_accountList);
    logDetail("JS => For Adding Account Records: " + testHHAccountList );
    await spCoinAddMethods.AccountRecords(testHHAccountList);
    logExitFunction();
  };

  //////////////////////////// TEST RECIPIENT METHODS ////////////////////////////

  addTestNetworkRecipient = async ( _accountIdx, _recipientIdx ) => {
    logFunctionHeader("addTestNetworkRecipient = async (" + _accountIdx + ", " + _recipientIdx + ")");

    let accountKey = await getTestHHAccountKey(_accountIdx);
    let recipientKey = await getTestHHAccountKey(_recipientIdx);  
    logDetail("JS => For Account: " + accountKey + " Inserting Recipient Records");
    logDetail(recipientKey);
    await spCoinAddMethods.Recipient(recipientKey);
    logExitFunction();
  };

  addTestNetworkRecipients = async (_accountIdx, _recipientAccountListIdx) => {
    logFunctionHeader("addTestNetworkRecipients = async (" + _accountIdx + ", " + _recipientAccountListIdx + ")");

    let accountKey = await spCoinAddMethods.MethodsContract.getTestHHAccountKey(_accountIdx);
    let recipientAccountList = await getTestHHAccountListKeys(_recipientAccountListIdx);
    logDetail("JS => For Account: " + accountKey + " Inserting Recipient Records:");
    logDetail(recipientAccountList);
    await spCoinAddMethods.Recipients(accountKey, recipientAccountList);
    logExitFunction();
  };

  //////////////////////////// TEST AGENT METHODS ////////////////////////////

  addTestNetworkRecipientAgents = async (_recipientIdx, _recipientRateKey, _agentListIdx ) => {
    logFunctionHeader("async (" + _recipientIdx + "," + _agentListIdx+ ")");
    let recipientKey = await getTestHHAccountKey(_recipientIdx);
    let agentAccountList = await getTestHHAccountListKeys(_agentListIdx);
    await spCoinAddMethods.Agents(recipientKey, _recipientRateKey, agentAccountList);
    return recipientKey;
    logExitFunction();
  };

  addTestNetworkAccount = async (_testHHAccountIdx) => {
    logFunctionHeader("async (" + _testHHAccountIdx+ ")");
    let accountKey = await getTestHHAccountKey(_testHHAccountIdx);
    await spCoinAddMethods.AccountRecord(accountKey);
    return accountKey;
    logExitFunction();
  };

  getTestHHAccountListKeys = async (testAccountIdxArr) => {
    logFunctionHeader("await getTestHHAccountListKeys (" + testAccountIdxArr + ")");
    let AccountListKeys = [];
    for (let i = 0; i < testAccountIdxArr.length; i++) {
      AccountListKeys.push(await getTestHHAccountKey(testAccountIdxArr[i]));
    }
    logExitFunction();
    return AccountListKeys;
  };

  ///////////////////////////// DELETE METHODS ///////////////////////////////

  deleteTestNetworkAccount = async (_testHHAccountIdx) => {
    logFunctionHeader("async (" + _testHHAccountIdx+ ")");
    let accountKey = await getTestHHAccountKey(_testHHAccountIdx);
    await deleteAccountRecord(accountKey);
    logExitFunction();
    return accountKey;
  };

  deleteTestNetworkAccounts = async (_testHHAccountArr) => {
    logFunctionHeader("async (" + _testHHAccountArr+ ")");
    testHHAccountList = await getTestHHAccountListKeys(_testHHAccountArr);
    await deleteAccountRecords(testHHAccountList);
    logExitFunction();
  };
}

module.exports = {
  SpCoinTestMethods
}
