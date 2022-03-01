//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "./Item.sol";
import "./Soldier.sol";

contract Boss is ERC721 {
    Item private item;
    Soldier private soldier;

    // next create id
    uint public nextId = 1;

    // [type, attack, defense]
    mapping (uint => uint[3]) public bossDrops;

    // boss health value
    mapping (uint => uint) public bossHealth;

    constructor(Soldier _soldier, Item _item) ERC721("Boss", "BOSS") {
        soldier = _soldier;
        item = _item;
    }

    function spawnBoss() public {
        // create boss
        bossHealth[nextId] = 100;

        // setup boss item drop
        bossDrops[nextId] = [0, 10, 0];
        nextId++;
    }

    function attackBoss(uint soldierId, uint bossId) public {
        // check that bossId exists
        require(bossHealth[bossId] > 0, "Boss does not exist");

        address sender = msg.sender;

        require(soldier.ownerOf(soldierId) == sender, "You don't own this soldier");

        // get attack stat of all sender's items
        uint256 itemAttack = item.allItemAttackOfOwner(sender);

        // drop item if boss is slain
        if(bossHealth[bossId] <= itemAttack) {
            // create a boss drop item for the sender
            _dropItem(msg.sender, bossId);
        }
    }

    function getBossHealth(uint bossId) public view returns (uint) {
        return bossHealth[bossId];
    }

    function _dropItem(address sender, uint bossId) private {
        // create an item for the sender that killed the boss
        item.createItemFromBoss(sender, bossDrops[bossId][0], bossDrops[bossId][1], bossDrops[bossId][2]);
    }
}
