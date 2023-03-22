// create htk
$("#create-htk-form").submit(async (event) => {
  event.preventDefault();

  const htkName = $("#htk-name").val();
  const htkSymbol = $("#htk-symbol").val();

  // check if input values are valid
  if (!htkName || !htkSymbol) {
    alert("Please enter valid input values");
    return;
  }

  // call createHTK function from smart contract
  const receipt = await window.hTokenInstance.methods
    .createHTK(htkName, htkSymbol)
    .send({ from: window.selectedAccount });

  // wait for transaction to be confirmed
  const txHash = receipt.transactionHash;
  let txConfirmed = false;
  while (!txConfirmed) {
    const receipt = await window.web3.eth.getTransactionReceipt(txHash);
    if (receipt && receipt.status) {
      txConfirmed = true;
      alert("HToken created successfully!");
    }
    await new Promise((resolve) => setTimeout(resolve, 1000)); // wait 1 second before checking again
  }
});
