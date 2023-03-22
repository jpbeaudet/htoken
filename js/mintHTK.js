import Web3 from 'web3';
import hTokenFactoryABI from './abi/hTokenFactoryABI.json';
import hTokenABI from './abi/hTokenABI.json';

// Web3 provider initialization
let web3 = window.web3;
if (typeof web3 !== 'undefined') {
  web3 = new Web3(web3.currentProvider);
} else {
  web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));
}

// Contract initialization
const hTokenFactoryAddress = "0x123..."; // Enter the address of your deployed HTK factory
const hTokenFactory = new web3.eth.Contract(hTokenFactoryABI, hTokenFactoryAddress);

// Get all existing HTK tokens and add them as options to the select element
const select = document.getElementById("htk-select");
hTokenFactory.methods.getHTokenCount().call().then(count => {
  for (let i = 0; i < count; i++) {
    hTokenFactory.methods.getHTokenAtIndex(i).call().then(address => {
      const hToken = new web3.eth.Contract(hTokenABI, address);
      hToken.methods.symbol().call().then(symbol => {
        const option = document.createElement("option");
        option.value = address;
        option.text = `${symbol} (${address})`;
        select.add(option);
      });
    });
  }
});

// Mint HTK on form submit
const form = document.getElementById("mint-form");
form.addEventListener("submit", event => {
  event.preventDefault();
  const address = select.value;
  const amount = event.target.elements.amount.value;

  // Contract instance initialization
  const hToken = new web3.eth.Contract(hTokenABI, address);

  // Get the current account
  web3.eth.getAccounts((error, accounts) => {
    if (error) {
      console.error(error);
    } else {
      const account = accounts[0];

      // Call the mint function with the specified amount
      hToken.methods.mint(web3.utils.toWei(amount)).send({from: account})
        .on("transactionHash", hash => {
          const resultDiv = document.getElementById("result");
          resultDiv.innerHTML = `Transaction Hash: <a href="https://etherscan.io/tx/${hash}" target="_blank">${hash}</a>`;
        })
        .on("confirmation", (confirmationNumber, receipt) => {
          const resultDiv = document.getElementById("result");
          resultDiv.innerHTML += `<br>Transaction confirmed in block ${receipt.blockNumber}`;
        })
        .on("error", error => {
          console.error(error);
          const resultDiv = document.getElementById("result");
          resultDiv.innerHTML = `Error: ${error.message}`;
        });
    }
  });
});
