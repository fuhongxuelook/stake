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

  const contractAddress = "0x3aeE34aA6508fB612E39549a4bAD9317D1d16400";
  const AKP = "0xAA9556722Ea7904037c576dEe839909E7810f1aC"
  let myContract = await hre.ethers.getContractAt("AkpIDOClaim", contractAddress, signer);
  let akpContract = await hre.ethers.getContractAt("AKP", AKP, signer);
  const ido = "0x129C4a9fc029a5a6c6B1d2A06bCdE1AA07669219";
  let idoContract = await hre.ethers.getContractAt("AKPIDO", ido, signer);

  let bal = await idoContract.balanceOf("0xb854e5aD1b58C9e93b0e2853883d88F43FE5F205")
  console.log("ido number", bal);
  // return;
  let akpamount = await myContract.getIDOBalance("0xb854e5aD1b58C9e93b0e2853883d88F43FE5F205")
  console.log("akp akpamount", akpamount);

  let set_tx = await myContract.setClaimStatus(true);
  await set_tx.wait();
  console.log("set end");

  let redeemAmount = (akpamount/1e9).toFixed(0);
  let leftbal = await myContract.leftBalance();
  console.log("left bal", leftbal);

  let akpaddr = await myContract.akp();
  console.log("akp", akpaddr);

  let trans_tx = await akpContract.transfer(
    contractAddress, 
    ((bal * 200000)/1e9).toFixed(0) 
  );
  await trans_tx.wait()

  console.log("transfer end")
  let redeem_tx = await myContract.redeemAKP(redeemAmount);
  await redeem_tx.wait()
  console.log("redeemed end");

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
