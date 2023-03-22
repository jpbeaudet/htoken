const providerOptions = {
  walletconnect: {
    package: WalletConnectProvider,
    options: {
      rpc: {
        1: 'https://mainnet.infura.io/v3/your-infura-id',
        4: 'https://rinkeby.infura.io/v3/your-infura-id'
      }
    }
  }
};

const web3Modal = new Web3Modal({
  network: "mainnet", // optional
  cacheProvider: true, // optional
  providerOptions // required
});

const connectWalletButton = document.getElementById("connect-wallet-button");
const connectedWalletAddress = document.getElementById("connected-wallet-address");

connectWalletButton.addEventListener("click", async () => {
  const provider = await web3Modal.connect();
  const web3 = new Web3(provider);
  const accounts = await web3.eth.getAccounts();

  if (accounts.length > 0) {
    connectedWalletAddress.innerText = accounts[0];
    // Add code to handle connected wallet address
  }
});
