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


  const Obj = await hre.ethers.getContractFactory("AkpIDOClaim");
  const akpidoclaim = await Obj.deploy(
  	"0xAA9556722Ea7904037c576dEe839909E7810f1aC",
  	"0x91Dc1fc237116175D415202F2e44622c138e6571"
  );

  await akpidoclaim.deployed();

  console.log("akpidoclaim deployed to:", akpidoclaim.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
