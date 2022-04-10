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

  const contractAddress = "0x9b9fA8fe91Ffa1435dc7bE3bFBD34fCE3E11e285";
  const AKP = "0xAA9556722Ea7904037c576dEe839909E7810f1aC"
  let myContract = await hre.ethers.getContractAt("AkpReleaser", contractAddress, signer);
  let akpContract = await hre.ethers.getContractAt("AKP", AKP, signer);

  // let approve_tx = await akpContract.approve(contractAddress, hre.ethers.constants.MaxUint256);
  // await approve_tx.wait()
  // console.log("approve end");
  // let can_tx = await myContract.changeCanRedeem()
  // await can_tx.wait()
  // console.log("can end");
  // return;

  let addrs = [
    "0xFe8Ca9F87755f5e3B5E2a883cBb26101Dd9BF888"
  ]

  let amounts = [
    10000
  ]
  let trans_tx = await akpContract.transfer(contractAddress, 10000000000000);
  await trans_tx.wait()

  console.log("transfer end")
  let batch_mint_tx = await myContract.batchSafeMint(addrs, amounts);
  await batch_mint_tx.wait()
  console.log("batch mint end");

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
