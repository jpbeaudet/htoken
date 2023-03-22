const contractAddress = '<ADD_CONTRACT_ADDRESS_HERE>';
const abi = <ADD_ABI_HERE>;

const web3 = new Web3(window.ethereum);
const hTokenFactory = new web3.eth.Contract(abi, contractAddress);

$(document).ready(async () => {
  const hTokenCount = await hTokenFactory.methods.getHTokenCount().call();
  for (let i = 0; i < hTokenCount; i++) {
    const hTokenAddress = await hTokenFactory.methods.getHTokenAtIndex(i).call();
    const hTokenName = await hTokenFactory.methods.getHTokenNameAtIndex(i).call();
    const hTokenSymbol = await hTokenFactory.methods.getHTokenSymbolAtIndex(i).call();
    const hTokenData = await getHTokenData(hTokenAddress);
    displayHTokenData(hTokenName, hTokenSymbol, hTokenAddress, hTokenData);
  }
});

async function getHTokenData(hTokenAddress) {
  const hToken = new web3.eth.Contract(abi, hTokenAddress);
  const name = await hToken.methods.name().call();
  const symbol = await hToken.methods.symbol().call();
  const totalSupply = await hToken.methods.totalSupply().call();
  const balance = await hToken.methods.balanceOf(window.ethereum.selectedAddress).call();
  return { name, symbol, totalSupply, balance };
}

function displayHTokenData(name, symbol, hTokenAddress, hTokenData) {
  const hTokenRow = `
    <div class="row">
      <div class="col-md-12">
        <h3>${name} (${symbol})</h3>
        <p>HToken Address: ${hTokenAddress}</p>
        <p>Name: ${hTokenData.name}</p>
        <p>Symbol: ${hTokenData.symbol}</p>
        <p>Total Supply: ${hTokenData.totalSupply}</p>
        <p>Your Balance: ${hTokenData.balance}</p>
      </div>
    </div>
    <hr />
  `;
  $('#htk-data').append(hTokenRow);
}
