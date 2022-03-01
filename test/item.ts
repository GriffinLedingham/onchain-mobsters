import { expect } from "chai";
import { ethers } from "hardhat";

describe("Item", function () {
  it("Should create a item", async function () {
    const Item = await ethers.getContractFactory("Item");
    const item = await Item.deploy();
    await item.deployed();
    const [owner, testUserAddr] = await ethers.getSigners();

    // Get the next expected item id
    const nextId = await item.nextId();

    const ITEM_TYPE = 0;
    const ITEM_ATTACK = 10;
    const ITEM_DEFENSE = 0;

    // Mint a item to test user
    await item.connect(owner).ownerCreateItemToAddress(testUserAddr.address, ITEM_TYPE, ITEM_ATTACK, ITEM_DEFENSE);

    // Expect the newly minted item to be owned by the test user
    expect(await item.ownerOf(nextId)).to.equal(testUserAddr.address);
    expect(await item.getItemAttack(nextId)).to.equal(ITEM_ATTACK);
    expect(await item.getItemDefense(nextId)).to.equal(ITEM_DEFENSE);
    expect(await item.getItemType(nextId)).to.equal(ITEM_TYPE);
  });

  it("Should create two items, and fetch them using itemsOfOwner", async function () {
    const Item = await ethers.getContractFactory("Item");
    const item = await Item.deploy();
    await item.deployed();
    const [owner, testUserAddr] = await ethers.getSigners();

    const ITEM_TYPE = 0;
    const ITEM_ATTACK = 10;
    const ITEM_DEFENSE = 0;

    // Mint a item to test user
    await item.connect(owner).ownerCreateItemToAddress(testUserAddr.address, ITEM_TYPE, ITEM_ATTACK, ITEM_DEFENSE);
    await item.connect(owner).ownerCreateItemToAddress(testUserAddr.address, ITEM_TYPE, ITEM_ATTACK, ITEM_DEFENSE);

    // Expect the newly minted item to be owned by the test user
    expect((await (item.itemsOfOwner(testUserAddr.address))).length).to.equal(2);

  });
});
