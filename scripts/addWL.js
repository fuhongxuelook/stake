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
    "0x2fb5d01bee2ba2929fe270c6b0af3ce162803f77",
    "0x68F887d9ee3381c3d0B90A60c528B0FDBC999999",
    "0xb255775b3aE4040781592dD6C7D981f70e23eAC9",
    "0x53868E2b3e553a2fC3667a7a1647b86CCf0C4155",
    "0xe672b07De07e7711EB2f2146d00179DA5c88Ad3f",
    "0x50109D5b6A43f731bb01cDbaD8c5D372fA533494",
    "0xC6C98A22079a794A79Ac7DA0d0b93d4C39D4cF48",
    "0xF52eC7D18d4eF32F286c8e06869b5c50CD60A7Fa",
    "0xe1Ce4829E260877fA94261672d58422C7AA04496",
    "0xe624D16B116db0C40A0dE52dD0627Afe6CCc03Ca",
    "0x597Ddaf79527d46a3d838eD4B06BB37Ebba8fC87",
    "0x969ff8a381d2eac210063a6ab1e56b1d1150acad",
    "0x8a52Ea93a45f4Ac266e92bF641C45D1F2D79c915",
    "0x1c950886B2D7bE13D7B803cead9675Fa9A1E79c6",
    "0x3848392e3fF23Fd4BD1beD9b77DFE922dB777777",
    "0x981489030E476Ea5dE7F7ac2F0A81e4dBB68b7D8",
    "0xF33630be6B125EE00b0B22A5D6c5f54E60888178",
    "0x2cbb45ca0f69f512c572aea5e0be064c5bb19935",
    "0x0780b6d967992c91a60d114fb7ae104b1f35a618",
    "0x7065311bfB0ee75b87eC87B5F6763668c48DE840",
    "0x04Af47A3663BD762970fc0609a229203d28C2B11",
    "0x13ca91d828a0347d5a511ad8e52805ef747c15c9",
    "0x202a05168a7F15aE3005af63a2E100F9d2777777",
    "0x41822996a7a49D8fa4177057931B636c526Ed700",
    "0x34E51Af008c5A536ad0D6383e0Ed81c305900000",
    "0x6B5195c79Fb2eA977464007c8cda36353776c92f",
    "0xCd6A8543b35BFE8D783ec85600D82c4489E84295",
    "0x5dCE60D71a3a7a612e2Add32A3E5d11Ac18E10ca",
    "0x980Cd09101C9890252c2229DEeDDF1CF6D61f7ab",
    "0xdeAFD20cC7FF3b1fD9a001c1F9697fFc68C1ec2C",
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

  let tx = await myContract.batchAddWL(addresses);
  await tx.wait()
  console.log("add end");

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
