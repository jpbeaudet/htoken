const createHTKForm = document.querySelector("#create-htk-form");

createHTKForm.addEventListener("submit", async (event) => {
  event.preventDefault();

  // Check if user is connected to wallet
  if (!window.ethereum || !window.ethereum.selectedAddress) {
    alert("Please connect to a wallet to create HToken.");
    return;
  }

  // Get form data
  const name = createHTKForm.elements.namedItem("htk-name").value;
  const symbol = createHTKForm.elements.namedItem("htk-symbol").value;
  const initialDeposit = createHTKForm.elements.namedItem("initial-deposit").value;
  const initialSupply = createHTKForm.elements.namedItem("initial-supply").value;

  // Check if form data is valid
  if (!name || !symbol || !initialDeposit || !initialSupply) {
    alert("Please fill in all form fields to create HToken.");
    return;
  }

  try {
    // Get contract instance
    const web3 = new Web3(window.ethereum);
    const accounts = await web3.eth.getAccounts();
    const htkContract = new web3.eth.Contract(HTK_ABI);

    // Estimate gas cost
    const gasPrice = await web3.eth.getGasPrice();
    const gasLimit = 300000;
    const data = htkContract.deploy({
      data: HTK_BYTECODE,
      arguments: [name, symbol, initialDeposit, initialSupply],
    }).encodeABI();
    const nonce = await web3.eth.getTransactionCount(accounts[0], "latest");
    const tx = {
      from: accounts[0],
      to: null,
      gasPrice: web3.utils.toHex(gasPrice),
      gasLimit: web3.utils.toHex(gasLimit),
      nonce: web3.utils.toHex(nonce),
      data: data,
    };
    const estimatedGas = await web3.eth.estimateGas(tx);

    // Send transaction to create HToken
    const transactionHash = await htkContract
      .deploy({
        data: HTK_BYTECODE,
        arguments: [name, symbol, initialDeposit, initialSupply],
      })
      .send(
        {
          from: accounts[0],
          gasPrice: web3.utils.toHex(gasPrice),
          gasLimit: web3.utils.toHex(estimatedGas),
        },
        async (error, transactionHash) => {
          if (error) {
            alert(`Error creating HToken: ${error}`);
          } else {
            alert(
              `HToken created successfully. Transaction hash: ${transactionHash}`
            );
          }
        }
      );
  } catch (error) {
    alert(`Error creating HToken: ${error}`);
  }
});
