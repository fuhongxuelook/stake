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


  const Obj = await hre.ethers.getContractFactory("AkpStake");
  const akpstake = await Obj.deploy("0xA5abAAB0172D005cd02643E96A961d73d2C6f7d5");

  await akpstake.deployed();

  console.log("akpstake deployed to:", akpstake.address);
  
  // let tx = await akp.changeWLStatus("0x37aa15f95c6b4193aBe6687Fd0bD9BD2BbF97719", true);
  // await tx.wait()
  // console.log("wl set");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
