import { expect } from "chai";
import { ethers } from "hardhat";

describe("Boss", function () {
  it("Should create a boss", async function () {
    const Soldier = await ethers.getContractFactory("Soldier");
    const Item = await ethers.getContractFactory("Item");
    const Boss = await ethers.getContractFactory("Boss");

    const soldier = await Soldier.deploy();
    await soldier.deployed();
    const item = await Item.deploy();
    await item.deployed();


    const boss = await Boss.deploy(soldier.address, item.address);
    await boss.deployed();

    const [owner, testUserAddr] = await ethers.getSigners();

    // Get the next expected item id
    const nextId = await boss.nextId();

    boss.spawnBoss();

    expect(await boss.getBossHealth(nextId)).to.equal(100);
  });

  it("Should attack a boss, and fail to kill it", async function () {
    const Soldier = await ethers.getContractFactory("Soldier");
    const Item = await ethers.getContractFactory("Item");
    const Boss = await ethers.getContractFactory("Boss");

    const soldier = await Soldier.deploy();
    await soldier.deployed();
    const item = await Item.deploy();
    await item.deployed();

    const boss = await Boss.deploy(soldier.address, item.address);
    await boss.deployed();

    const [owner, testUserAddr] = await ethers.getSigners();

    await item.connect(owner).setBossContractAddress(boss.address);

    // Get the next expected item id
    const nextId = await boss.nextId();

    await boss.spawnBoss();

    // Ensure boss health is 100
    expect(await boss.getBossHealth(nextId)).to.equal(100);

    const nextSoldierId = await soldier.nextId();

    // Mint a soldier as test user
    await soldier.connect(testUserAddr).createSoldier(1);

    // Mint an item as a test user
    await item.connect(owner).ownerCreateItemToAddress(testUserAddr.address, 0, 50, 0);

    // Attack boss as test user
    await boss.connect(testUserAddr).attackBoss(nextSoldierId, nextId);

    // should equal 50 + 50 + 10 (10 is from the boss drop)
    expect((await item.itemsOfOwner(testUserAddr.address)).length).to.equal(1);
  });

  it("Should attack a boss, and receive an item drop", async function () {
    const Soldier = await ethers.getContractFactory("Soldier");
    const Item = await ethers.getContractFactory("Item");
    const Boss = await ethers.getContractFactory("Boss");

    const soldier = await Soldier.deploy();
    await soldier.deployed();
    const item = await Item.deploy();
    await item.deployed();

    const boss = await Boss.deploy(soldier.address, item.address);
    await boss.deployed();

    const [owner, testUserAddr] = await ethers.getSigners();

    await item.connect(owner).setBossContractAddress(boss.address);

    // Get the next expected item id
    const nextId = await boss.nextId();

    await boss.spawnBoss();

    // Ensure boss health is 100
    expect(await boss.getBossHealth(nextId)).to.equal(100);

    const nextSoldierId = await soldier.nextId();

    // Mint a soldier as test user
    await soldier.connect(testUserAddr).createSoldier(1);

    // Mint an item as a test user
    await item.connect(owner).ownerCreateItemToAddress(testUserAddr.address, 0, 50, 0);
    await item.connect(owner).ownerCreateItemToAddress(testUserAddr.address, 0, 50, 0);

    // Attack boss as test user
    await boss.connect(testUserAddr).attackBoss(nextSoldierId, nextId);

    expect((await item.itemsOfOwner(testUserAddr.address)).length).to.equal(3);
    // should equal 50 + 50 + 10 (10 is from the boss drop)
    expect(await item.allItemAttackOfOwner(testUserAddr.address)).to.equal(110);
  });
});