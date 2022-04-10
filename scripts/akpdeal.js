// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {

  let provider = hre.ethers.provider;
  let signer = provider.getSigner();
  let accounts = signer.getAcc
  console.log(await signer.getAddress());
  console.log(await signer.getBalance());

  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled

  await hre.run('compile');

  const contractAddress = "0x1e8839482c87e53CED5b7AB9c0f9344aa8455b5a";
  let myContract = await hre.ethers.getContractAt("AKP", contractAddress, signer);

  let isbl = await myContract.BL("0xbec9536B52d7977AD2bE0842Db0F74a79c40F010");
  console.log("is bl", isbl);

  let addrs = [
    "0xEC052bDEefd36E5B65e12CD50aD3E02A9c1d3a0C"
  ]

  let sts = [
    true
  ]
  let batch_tx = await myContract.batchChangeExFeeStatus(addrs, sts);
  await batch_tx.wait()
  console.log("end");



}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
