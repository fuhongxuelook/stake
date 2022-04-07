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

  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled

  await hre.run('compile');

  const contractAddress = "0x07a8870f5361A47070BC3424ccA2D73db0100129";
  let myContract = await hre.ethers.getContractAt("AKP", contractAddress, signer);

  // let tx = await myContract.changeWLStatus("0x37aa15f95c6b4193aBe6687Fd0bD9BD2BbF97719", true);
  // await tx.wait()
  // console.log("wl set");


  // let tx = await myContract.openSale();
  // await tx.wait()
  // console.log("sales opened");

  let isBL = await myContract.BL("0x703B3d81e95049Fec224a5F8EeC2e18fBa530FbA");
  console.log("add bl status", isBL);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
