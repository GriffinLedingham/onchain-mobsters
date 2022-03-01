//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Item is ERC721 {
    address owner;

    // Address of boss contract
    address bossContractAddress;

    // Address of soldier contract
    address soldierContractAddress;

    // next create id
    uint public nextId = 1;

    // item type mapping of token id to int
    mapping (uint => uint) public itemType;

    // attack stat mapping of token id to int
    mapping (uint => uint) public attackStat;

    // defense stat mapping of token id to int
    mapping (uint => uint) public defenseStat;

    event Created(address indexed owner, uint item);

    /* eslint-disable no-empty-blocks */
    constructor() ERC721("Item", "ITM") {
        owner = msg.sender;
    }

    // Private create item to address, only to be used by owner or private within contracts
    function createItemToAddress(address _to, uint _type, uint _attack, uint _defense) private {
        uint _nextId = nextId;

        // set attack stat
        attackStat[_nextId] = _attack;

        // set defense stat
        defenseStat[_nextId] = _defense;

        // set item type
        itemType[_nextId] = _type;

        _safeMint(_to, _nextId);
        emit Created(_to, _nextId);

        // increment next id
        nextId++;
    }

    function ownerCreateItemToAddress(address _to, uint _type, uint _attack, uint _defense) external {
        require(msg.sender == owner);

        uint _nextId = nextId;

        // set attack stat
        attackStat[_nextId] = _attack;

        // set defense stat
        defenseStat[_nextId] = _defense;

        // set item type
        itemType[_nextId] = _type;

        _safeMint(_to, _nextId);
        emit Created(_to, _nextId);

        // increment next id
        nextId++;
    }

    // Create an item for _to, to be dropped by a killed boss
    function createItemFromBoss(address _to, uint _type, uint _attack, uint _defense) external {
        require(msg.sender == bossContractAddress);
        createItemToAddress(_to, _type, _attack, _defense);
    }

    function getItemAttack(uint id) external view returns (uint) {
        return attackStat[id];
    }
    function getItemDefense(uint id) external view returns (uint) {
        return defenseStat[id];
    }
    function getItemType(uint id) external view returns (uint) {
        return itemType[id];
    }

    function totalSupply() public view returns (uint) {
        return nextId - 1;
    }

    // Get an array of all of _owner's items
    function itemsOfOwner(address _owner) external view returns(uint256[] memory) {
        uint256 tokenCount = balanceOf(_owner);

        if (tokenCount == 0) {
            // Return an empty array
            return new uint256[](0);
        } else {
            uint256[] memory result = new uint256[](tokenCount);
            uint256 totalItems = totalSupply();
            uint256 resultIndex = 0;

            uint256 itemId;

            for (itemId = 1; itemId <= totalItems; itemId++) {
                if (ownerOf(itemId) == _owner) {
                    result[resultIndex] = itemId;
                    resultIndex++;
                }
                if(resultIndex == tokenCount) {
                    break;
                }
            }

            return result;
        }
    }

    // Get the total attack stat of all _owner's items
    function allItemAttackOfOwner(address _owner) external view returns(uint256) {
        uint256 tokenCount = balanceOf(_owner);

        if (tokenCount == 0) {
            return 0;
        } else {
            uint256 totalItems = totalSupply();
            uint256 itemAttackStrength = 0;
            uint256 itemId;

            for (itemId = 1; itemId <= totalItems; itemId++) {
                if (ownerOf(itemId) == _owner) {
                    itemAttackStrength+=attackStat[itemId];
                }
            }

            return itemAttackStrength;
        }
    }

    // Set the Boss contract address that will be allowed to call createItemFromBoss
    function setBossContractAddress(address _bossContractAddress) public {
        require(msg.sender == owner);
        bossContractAddress = _bossContractAddress;
    }

    // Set the Soldier contract address that will be allowed to call internal contract calls
    function setSoldierContractAddress(address _soldierContractAddress) public {
        require(msg.sender == owner);
        soldierContractAddress = _soldierContractAddress;
    }
}