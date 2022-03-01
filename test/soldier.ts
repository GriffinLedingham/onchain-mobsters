import { expect } from "chai";
import { ethers } from "hardhat";

describe("Soldier", function () {
  it("Should create a soldier", async function () {
    const Soldier = await ethers.getContractFactory("Soldier");
    const soldier = await Soldier.deploy();
    await soldier.deployed();
    const [owner, testUserAddr] = await ethers.getSigners();

    // Get the next expected soldier id
    const nextId = await soldier.nextId();

    // Mint a soldier as test user
    await soldier.connect(testUserAddr).createSoldier(1);

    // Expect the newly minted soldier to be owned by the test user
    expect(await soldier.ownerOf(nextId)).to.equal(testUserAddr.address);
  });

    it("Should do a mission", async function () {
    const Soldier = await ethers.getContractFactory("Soldier");
    const soldier = await Soldier.deploy();
    await soldier.deployed();
    const [owner, testUserAddr] = await ethers.getSigners();

    // Get the next expected soldier id
    const nextId = await soldier.nextId();

    // Mint a soldier as test user
    await soldier.connect(testUserAddr).createSoldier(1);

    await soldier.connect(testUserAddr).doMission(nextId);

    // Expect the newly minted soldier to be owned by the test user
    expect(await soldier.xp(nextId)).to.equal(await soldier.XP_PER_JOB());
  });

  it("Should fail trying to do more than one mission per day", async function () {
    const Soldier = await ethers.getContractFactory("Soldier");
    const soldier = await Soldier.deploy();
    await soldier.deployed();
    const [owner, testUserAddr] = await ethers.getSigners();

    // Get the next expected soldier id
    const nextId = await soldier.nextId();

    // Mint a soldier as test user
    await soldier.connect(testUserAddr).createSoldier(1);

    await soldier.connect(testUserAddr).doMission(nextId);
    await expect(soldier.connect(testUserAddr).doMission(nextId)).to.be.revertedWith("You can only do one mission per day");
  });

  it("Should do a mission until level up", async function () {
      const Soldier = await ethers.getContractFactory("Soldier");
    const soldier = await Soldier.deploy();
    await soldier.deployed();
    const [owner, testUserAddr] = await ethers.getSigners();

    // Get the next expected soldier id
    const nextId = await soldier.nextId();

    // Mint a soldier as test user
    await soldier.connect(testUserAddr).createSoldier(1);

    // iterate 10 times
    for (let i = 0; i < 10; i++) {
      await soldier.connect(testUserAddr).doMission(nextId);
      await soldier.connect(testUserAddr).speedUpMissionTimer(nextId, { value: ethers.utils.parseEther(".001") } as any);
    }

    // Expect the newly minted soldier to be owned by the test user
    expect(await soldier.xp(nextId)).to.equal(0);
    expect(await soldier.level(nextId)).to.equal(2);
  });
});
