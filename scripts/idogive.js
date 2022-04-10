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
    // "0xE542Aa3d76c11eae3AE976602C237d51B052f666",
    // "0xd25A60c8fFfE5b1Fcb90164A2FE45Cc92f753D05",
    // "0xfF9e0CB23BeeC06caF9b0281a517D77209FbDb35",
    // "0x3Cb5f59b696b9d781a5b7cCF93650AA449A9e6a2",
    // "0x07a2CDCABD615BBA366E87eDad66CBc8e16AF2c8",
    // "0xE4106ca1d82Cf5B384340C670068bB045560914C",
    // "0x8a8C4591d6a0D37F1B4cf2DF54B7D3Cfec6e3c85",
    // "0x5cC7e03c55Fe814258D6beeC562Eb83183a4386e",
    // "0xb04000c7a67002eebC5aE4dAb88DFD58929856ED",
    // "0x317Fc5A5DFf51908f9daAEe869f9761713bdA0D9",
    // "0xb5eD84660Ec80DDa959521c54035215d0169173B",
    // "0xA4E0BCB3356f39eE76319767a0Da0948AE7C0D14",
     "0xFe8C22DAc3bAaFBF76583bC559904DAb9E4C46C9",
    // "0xC67dcD7E51fdbfA321e22410EcA216d355b8e04b",
    // "0xF4C24AFD10AB25364264835D42073dca54e9051b",
    // "0xcF0f756df777283F97cEE0C07EfB91C20f81c2E0",
    // "0x5e3fB34C5B874131fd6b5F51f17353C625D68c1C",
    // "0x9BE03F92F8E324A7310707aa016E6381Ca5B3609",
    // "0x338Ead47797E245ADc8a5d4733CBD2577E4362Aa",
    // "0x23f08A34017966bE139dFa8e7235a47E6949938B",
  ]

  let amounts = [
      "1",
      // "2",
      // "2",
      // "2",
      // "2",
      // "2",
      // "2",
      // "2",
      // "2",
      // "2",
      // "2",
      // "2",
      // "2",
      // "2",
      // "2",
      // "2",
      // "2",
      // "2",
      // "2",
      // "2",
  ]
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled

  await hre.run('compile');

  const contractAddress = "0x91Dc1fc237116175D415202F2e44622c138e6571";
  let myContract = await hre.ethers.getContractAt("AKPIDO", contractAddress, signer);

  for(i = 0; i < amounts.length; i ++) {
     amounts[i] = hre.ethers.utils.parseEther(amounts[i]);
  }

  let tx = await myContract.batchGiveAkp(addresses, amounts);
  await tx.wait()
  console.log("set end");

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
