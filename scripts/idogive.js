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
    "0xDD9dd41E0449f94Daf4B81CA4cD49cC037fc1b15",
    "0xD8d238c52B484B7e58B0Ba8d7B6292ae0eE6388C",
    "0x4A362861b2711286B578c3276967AFc9Acb434Ac",
    "0x6c7Ab4257B94941f089e05F39a1987FAe266C507",
    "0xAdA0C47520262A5aa1D63598efE735794403fCA5",
    "0x98839EF0f24281Ce68f0Cb85Bae783ccc61BaD8a",
    "0xe57e91517510bff7C785C6399D6c17bEEa3DdF5c",
    "0x2bFA9eFeB75F4A1459f0CB99185331575df78713",
    "0xD03b2D6Cd3a85AB38b54c1E18FdffaE0dB580e28",
    "0xc15B6f8616CA10Dc594AFEF3BBd6B4eb0341bc58",
    "0x64f3dEdf8A4Ad34da202ac50bF1bAE248611E506",
    "0x2355DF1fe2655434354fBaDF23def149fd3Ec0bB",
    "0x64B999162B58b0ffcFD4e55aE1861203a26f9fc1",
    "0x13875372295935365311AFa50d117A2C6552120D",
    "0x564746fadc7bf772A0155748EF87113240a19DaD",
    "0xF1d34547E8B6F52B56050d6B21eeAC4619Dea076",
    "0x862aEd3E77bE8c35a423448A00CA6c1b8A963AA7",
    "0xB6160fF6A04842320f93986f7EF643f19Aa81Dec",
    "0xB17931cBA17A895c9b44BA2aB52d9adfc3EFa1dA",
    "0x597b57F302dDCFbcb5995784F59DDc3c9f2346C1",
    "0x87EBc7c773553861E39834619bdDF52b8Ec05622",
    "0xE9dD3Ad3731E800e292A1619932d4D482d75776E",
    "0x165b59E4d7d02934b18ec26522F8B5ce3F8633e1",
    "0xFB0a7E59626484716a0cC85B9Dc0C71146651467",
    "0x1692758bCa4BBa3Cdc84dC308e832a175D00A2F4",
    "0x2a0e7E10629C26db3195a68FC7b4370b5FD8c873",
    "0x5D06a3940Feb70411F248810406A8C6129b69504",
    "0xD8B3Ad4F737f229662760B454BFb13B0323d9Ef9",
    "0x2E0109efde1A6A8c26B38673cbBd35172Eb4996b",
    "0xf24395b058941c0DEa113e2a8ce50dBE6B84646A",
  ]

  let amounts = [
      "2",
      "2",
      "2",
      "2",
      "2",
      "2",
      "2",
      "2",
      "2",
      "2",
      "2",
      "2",
      "2",
      "2",
      "2",
      "2",
      "2",
      "2",
      "2",
      "2",
      "2",
      "2",
      "2",
      "2",
      "2",
      "2",
      "2",
      "2",
      "2",
      "2",
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
