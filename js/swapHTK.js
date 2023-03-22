// Connect to Web3
if (typeof window.ethereum !== 'undefined') {
    window.ethereum.enable().then(function(accounts) {
        web3.eth.defaultAccount = accounts[0];
        console.log('Connected to Web3');
    }).catch(function(error) {
        console.log('Web3 connection error:', error);
    });
} else {
    console.log('Web3 is not available');
}

// Get HTokenFactory contract instance
const factoryAbi = [
    // HTokenFactory contract ABI
];
const factoryAddress = '0x...'; // Address of HTokenFactory contract
const factoryContract = new web3.eth.Contract(factoryAbi, factoryAddress);

// Get list of existing HTK tokens
let htkOptions = '';
factoryContract.methods.getHTokenCount().call((error, count) => {
    for (let i = 0; i < count; i++) {
        factoryContract.methods.getHTokenAtIndex(i).call((error, htkAddress) => {
            factoryContract.methods.getHTokenNameAtIndex(i).call((error, htkName) => {
                factoryContract.methods.getHTokenSymbolAtIndex(i).call((error, htkSymbol) => {
                    htkOptions += `<option value="${htkAddress}">${htkName} (${htkSymbol})</option>`;
                    if (i === count - 1) {
                        document.getElementById('fromHTKSelect').innerHTML = htkOptions;
                        document.getElementById('toHTKSelect').innerHTML = htkOptions;
                    }
                });
            });
        });
    }
});

// Handle form submission
document.getElementById('swapForm').addEventListener('submit', (event) => {
    event.preventDefault();

    const fromHTKAddress = document.getElementById('fromHTKSelect').value;
    const toHTKAddress = document.getElementById('toHTKSelect').value;
    const amount = document.getElementById('swapAmount').value;

    // Get HTokenRouter contract instance
    const routerAbi = [
        // HTokenRouter contract ABI
    ];
    const routerAddress = '0x...'; // Address of HTokenRouter contract
    const routerContract = new web3.eth.Contract(routerAbi, routerAddress);

    // Call swapExactHTKForHTK function on HTokenRouter contract
    routerContract.methods.swapExactHTKForHTK(fromHTKAddress, amount, toHTKAddress).send({from: web3.eth.defaultAccount})
        .on('transactionHash', (hash) => {
            console.log('Transaction hash:', hash);
            document.getElementById('swapResult').innerHTML = `Transaction submitted with hash: <a href="https://etherscan.io/tx/${hash}" target="_blank">${hash}</a>`;
        })
        .on('confirmation', (confirmationNumber, receipt) => {
            console.log('Confirmation number:', confirmationNumber);
            console.log('Receipt:', receipt);
            document.getElementById('swapResult').innerHTML = `Transaction confirmed with ${confirmationNumber} confirmations. Gas used: ${receipt.gasUsed}`;
        })
        .on('error', (error) => {
            console.log('Transaction error:', error);
            document.getElementById('swapResult').innerHTML = `Transaction error: ${error.message}`;
        });
});
