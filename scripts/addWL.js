// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {

  let provider = hre.ethers.provider;
  let signer = provider.getSigner();
  console.log(await signer.getAddress());
  console.log(await signer.getBalance());

  let addresses = [
    "0x032a47a22c25F0065FF4B84cc81099E72aa48713"
  ]

  let amounts = [
    "0"
  ]
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled

  await hre.run('compile');

  const contractAddress = "0x91Dc1fc237116175D415202F2e44622c138e6571";
  let myContract = await hre.ethers.getContractAt("AKPIDO", contractAddress, signer);

  // for(i = 0; i < amounts.length; i ++) {
  //    amounts[i] = hre.ethers.utils.parseEther(amounts[i]);
  // }

  let tx = await myContract.addWL("0x032a47a22c25F0065FF4B84cc81099E72aa48713");
  await tx.wait()
  console.log("add end");

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
