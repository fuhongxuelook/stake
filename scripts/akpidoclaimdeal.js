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

  const contractAddress = "0x2e4f4bDC8441f8f98c7058760A2ED89149624A9E";
  const AKP = "0x1b87f3201057263a6C4ED7Bf633aBF98E7Bd396d"
  let myContract = await hre.ethers.getContractAt("AkpIDOClaim", contractAddress, signer);
  let akpContract = await hre.ethers.getContractAt("AKP", AKP, signer);
  const ido = "0x91Dc1fc237116175D415202F2e44622c138e6571";
  let idoContract = await hre.ethers.getContractAt("AKPIDO", ido, signer);


  let akp_amount = await akpContract.balanceOf(contractAddress);
  console.log("akp", akp_amount);


  let akp_addr = await myContract.akp();
  console.log("akp", akp_amount);

  return;

  let bal = await idoContract.balanceOf("0xb854e5aD1b58C9e93b0e2853883d88F43FE5F205")
  console.log("ido number", bal);
  // return;
  let akpamount = await myContract.getIDOBalance("0xb854e5aD1b58C9e93b0e2853883d88F43FE5F205")
  console.log("akp akpamount", akpamount);

  // let set_tx = await myContract.setClaimStatus(true);
  // await set_tx.wait();
  // console.log("set end");

  let redeemAmount = (akpamount/1e9).toFixed(0);
  let leftbal = await myContract.leftBalance();
  console.log("left bal", leftbal);

  let akpaddr = await myContract.akp();
  console.log("akp", akpaddr);

  //10000000_000000000
  let trans_tx = await akpContract.transfer(
    contractAddress, 
    (10000000 * 1e9).toString()
  );
  await trans_tx.wait()

  // console.log("transfer end")
  // let redeem_tx = await myContract.redeemAKP(redeemAmount);
  // await redeem_tx.wait()
  // console.log("redeemed end");

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
