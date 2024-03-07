const hre = require("hardhat");

async function main() {
  // Getting the contract factory for "AINFTS"
  const AINFTS = await hre.ethers.getContractFactory("AINFTS");

  // Deploying the contract
  const ainfts = await AINFTS.deploy(); // Add constructor arguments if necessary

  // Waiting for the contract to be deployed
  await ainfts.deployed();

  console.log("AINFTS deployed to:", ainfts.address);
}

main()
  .catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });
