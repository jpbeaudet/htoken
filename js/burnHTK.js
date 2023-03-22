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
                        document.getElementById('htkSelect').innerHTML = htkOptions;
                    }
                });
            });
        });
    }
});

// Handle form submission
document.getElementById('burnForm').addEventListener('submit', (event) => {
    event.preventDefault();

    const htkAddress = document.getElementById('htkSelect').value;
    const amount = document.getElementById('burnAmount').value;

    // Get HToken contract instance
    const htkAbi = [
        // HToken contract ABI
    ];
    const htkContract = new web3.eth.Contract(htkAbi, htkAddress);

    // Call burn function on HToken contract
    htkContract.methods.burn(amount).send({from: web3.eth.defaultAccount})
        .on('transactionHash', (hash) => {
            console.log('Transaction hash:', hash);
            document.getElementById('burnResult').innerHTML = `Transaction submitted with hash: <a href="https://etherscan.io/tx/${hash}" target="_blank">${hash}</a>`;
        })
        .on('confirmation', (confirmationNumber, receipt) => {
            console.log('Confirmation number:', confirmationNumber);
            console.log('Receipt:', receipt);
            document.getElementById('burnResult').innerHTML = `Transaction confirmed with ${confirmationNumber} confirmations. Gas used: ${receipt.gasUsed}`;
        })
        .on('error', (error) => {
            console.log('Transaction error:', error);
            document.getElementById('burnResult').innerHTML = `Transaction error: ${error.message}`;
        });
});
