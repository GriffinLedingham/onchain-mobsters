// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers } from "hardhat";

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  const Soldier = await ethers.getContractFactory("Soldier");
  const soldier = await Soldier.deploy();

  await soldier.deployed();

  console.log("Soldier deployed to:", soldier.address);

  const Item = await ethers.getContractFactory("Item");
  const item = await Item.deploy();

  await item.deployed();

  console.log("Item deployed to:", item.address);

  const Boss = await ethers.getContractFactory("Boss");
  const boss = await Boss.deploy(soldier.address, item.address);

  await boss.deployed();

  // Set the boss/soldier contract addresses in the item contract for internal calls
  await item.setBossContractAddress(boss.address);
  await item.setSoldierContractAddress(soldier.address);

  console.log("Boss deployed to:", boss.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
