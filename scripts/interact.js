const { ethers } = require("hardhat");

const contractAddress = "0x9B251326E4c3534185DCcD2C49Ee88e6503d7557";

async function main() {
  const contract = await ethers.getContractAt("TaxSwap", contractAddress);

  const distribute = await contract.withdrawTokensToFeesReceiver();

  console.log(distribute);
}

main()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error(err);
    process.exit(1);
  });
