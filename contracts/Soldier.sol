//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Soldier is ERC721 {
    // next create id
    uint public nextId = 1;
    uint public constant XP_PER_JOB = 10;
    uint public constant XP_PER_LEVEL = 100;
    uint public constant SKILL_POINTS_PER_LEVEL = 1;

    // classes mapping of token id to int
    mapping (uint => uint) public classes;

    // level mapping for soldiers
    mapping (uint => uint) public level;

    // xp mapping for soldiers
    mapping (uint => uint) public xp;

    // skill point mapping for soldiers
    mapping (uint => uint) public skillPoints;

    // mapping of timestamps when the soldier last did a mission
    mapping(uint => uint) public missionTimers;


    event Created(address indexed owner, uint soldier);

    /* eslint-disable no-empty-blocks */
    constructor() ERC721("Soldier", "SLDR") {

    }

    function createSoldier(uint _class) external {
        // require that the class is 1, 2, or 3
        require(_class >= 1 && _class <= 3, "Class must be 1, 2, or 3");

        uint _nextId = nextId;

        // create soldier @ level 1
        level[_nextId] = 1;

        // set the soldier's class
        classes[_nextId] = _class;

        // set the soldier's xp to 0
        xp[_nextId] = 0;

        // set the soldier's skill points to 0
        skillPoints[_nextId] = 0;

        _safeMint(msg.sender, _nextId);
        emit Created(msg.sender, _nextId);

        // increment next id
        nextId++;
    }

    function doMission(uint _soldier) external {
        // require that the soldier exists
        require(_exists(_soldier), "Soldier does not exist");

        // require that the soldier is owned by the caller
        require(ownerOf(_soldier) == msg.sender, "Soldier must be owned by caller");

        require(block.timestamp > missionTimers[_soldier], "You can only do one mission per day");
        missionTimers[_soldier] = block.timestamp + (1 days);

        // increase the soldier's xp by 1
        xp[_soldier]+= XP_PER_JOB;

        // if the soldier's xp is greater than the max
        if (xp[_soldier] >= XP_PER_LEVEL) {
            _levelUp(_soldier);
        }
    }

    function _levelUp(uint _soldier) private {
        // require that the soldier exists
        require(_exists(_soldier), "Soldier does not exist");

        // require that the soldier is owned by the caller
        require(ownerOf(_soldier) == msg.sender, "Soldier must be owned by caller");

        // require that the soldier's xp is less than the max
        require(xp[_soldier] >= XP_PER_LEVEL, "Soldier must have more than or equal to XP_PER_LEVEL xp");

        // increase the soldier's level by 1
        level[_soldier]++;

        // increment the soldier's skill points by 1
        skillPoints[_soldier] += SKILL_POINTS_PER_LEVEL;

        // reduce the soldier's xp by XP_PER_LEVEL
        xp[_soldier] -= XP_PER_LEVEL;
    }

    function speedUpMissionTimer(uint _soldier) external payable {
        // require that the soldier exists
        require(_exists(_soldier), "Soldier does not exist");

        // require that the soldier is owned by the caller
        require(ownerOf(_soldier) == msg.sender, "Soldier must be owned by caller");

        require(msg.value == 1 ether, "You must pay 1 ether to speed up the mission timer");
        // ensure the msg sender has enough ether
        require(msg.sender.balance >= 1 ether, "You must have at least 1 ether to speed up the mission timer");

        // charge the caller a token value here
        sendEther(payable(this));

        require(block.timestamp < missionTimers[_soldier]);

        // reset the mission timer to 0
        missionTimers[_soldier] = 0;
    }

    function sendEther(address payable recipient) public payable {
        recipient.transfer(msg.value);
    }

    fallback() external payable {}
    receive() external payable {}
}
