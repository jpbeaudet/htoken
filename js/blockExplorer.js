// Import necessary libraries
const Web3 = require('web3');
const HTokenABI = require('./HTokenABI.json');

// Initialize Web3 with Infura endpoint
const web3 = new Web3(new Web3.providers.HttpProvider('https://mainnet.infura.io/v3/your-project-id'));

// Address of the HToken smart contract
const htkAddress = '0x...';

// Instantiate HToken contract object with ABI and address
const htkContract = new web3.eth.Contract(HTokenABI, htkAddress);

// Get total supply of HTK tokens
htkContract.methods.totalSupply().call()
  .then(totalSupply => {
    // Populate the total supply element in the HTML block explorer
    const totalSupplyElement = document.getElementById('htk-total-supply');
    totalSupplyElement.innerHTML = totalSupply;
  })
  .catch(error => {
    console.error('Failed to get total supply:', error);
  });

// Get balance of a specific account
const accountAddress = '0x...';
htkContract.methods.balanceOf(accountAddress).call()
  .then(balance => {
    // Populate the balance element in the HTML block explorer
    const balanceElement = document.getElementById('htk-balance');
    balanceElement.innerHTML = balance;
  })
  .catch(error => {
    console.error('Failed to get balance:', error);
  });

web3.eth.getPastLogs({
  address: htkAddress,
  fromBlock: 0,
  toBlock: 'latest',
  topics: [web3.utils.sha3('Transfer(address,address,uint256)'), null, null, null]
})
  .then(logs => {
    // Process the logs to get the transaction data
    const transactions = logs.map(log => {
      const [from, to, value] = web3.eth.abi.decodeParameters(['address', 'address', 'uint256'], log.data);
      return {
        from,
        to,
        value
      };
    }).slice(0, 10); // Only show the last 10 transactions

    // Populate the transaction table in the HTML block explorer
    const transactionsTable = document.getElementById('htk-transactions');
    transactionsTable.innerHTML = ''; // Clear any existing rows
    transactions.forEach(transaction => {
      const row = transactionsTable.insertRow(-1);
      const fromCell = row.insertCell(0);
      const toCell = row.insertCell(1);
      const valueCell = row.insertCell(2);
      fromCell.innerHTML = transaction.from;
      toCell.innerHTML = transaction.to;
      valueCell.innerHTML = transaction.value;
    });
  })
  .catch(error => {
    console.error('Failed to get past logs:', error);
  });
