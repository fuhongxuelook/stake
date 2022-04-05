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
    "0x04828247b49e76a657aaac06537b62ba16a15b30",
    "0x0be9e1c0b88f217e74dde78aa228067897456d08",
    "0x1e61a513ff93c3e63008068e00fc76a5d916fa90",
    "0x2628307111a8ecf54bd172985f41c06420f83193",
    "0x288942e62a612b93307da76727abd355f8163ebf",
    "0x2b147be0310fa81af7e29dffb0d8d858e1180e60",
    "0x35cbf9a9ee391ca9396576243e94150bb09e52cc",
    "0x46bc21b2f48982f5d57a87155968e5084e63dee7",
    "0x49cd5d42cad3a536943b4faae097652d2550b894",
    "0x50e8e455b2c9db89a5843ed175da060c3a1f1cac",
    "0x64a856d59cea018610b11283b31ddc62a86ef018",
    "0x6925eb3d8e0e639032db5d5bff4c7908827838bf",
    "0x6c4b6992897db4229fe170bc1b3a7ccabd2bfa1e",
    "0x73f9ffaf2c90c3225de2c0b2a342d0a67e91d4cd",
    "0x742089577cb0c55d8109e33fe73d89208341efbf",
    "0x749865c4f5837fc2ce2a433173b3a61d1e9ed21a",
    "0x76c529566c97b2268b9f6dc19318153403f69792",
    "0x7f410f5126cea01022a2eef39d765e82a67a01c0",
    "0x80fd115006b068e1dc9919173751486732211447",
    "0xb52a78908de7928ba782bf1549cd8c2ae1515048",
    "0xb79816e18dd4342d400dff0d168cc31584cd3bf0",
    "0xc016d825c4ac3d514b898cc65a10ddb193dba73a",
    "0xd2ed9499ce681e4cc8edb27ea06b69f42a755a8a",
    "0xd2f5b196b541cb1e01170f5e5c5010ad5789e406",
    "0xd4a766461855f69ebe6f08a8fdde55c97a009cae",
    "0xdb752afb4866d63cb3abbb0c004146a36ec6d67d",
    "0xee00a3e60eed018640d43e08078b3745a888f182",
    "0xf5c104e552c165c66da0d2a0397c56f6541a59c0",
    "0xfc3f8da4e980bb5a74d4f79ab4670ee281897e0c",
    "0xfd4c740a856983bb7dda72980c879e5bacd5d940",
    "0xfeb3c83de3e77e9aba111c32c4e353e5eb30faff",
  ]

  let amounts = [
    "0.1",
    "0.8",
    "0.15",
    "0.5",
    "5",
    "0.1",
    "0.1",
    "0.5",
    "0.5",
    "0.5",
    "4.5",
    "0.1",
    "0.1",
    "0.2",
    "0.5",
    "0.3",
    "0.2",
    "4",
    "0.1",
    "0.5",
    "0.3",
    "0.63",
    "0.1",
    "0.1",
    "0.5",
    "0.1",
    "0.15",
    "0.17",
    "0.2",
    "0.1",
    "0.5",
  ]
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled

  await hre.run('compile');

  const contractAddress = "0x0b1f3D87376187254e3c7Bc4812b4a40a87F0DDc";
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
