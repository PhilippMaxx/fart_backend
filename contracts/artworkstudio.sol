/// @title Handles first generation of artworks and sets up the contract
///  This wrapper of ReverseAuction exists only so that users can create
///  auctions with only one transaction.

pragma solidity >=0.4.22 <0.9.0;

import "./ownable.sol";
import "./safemath.sol";

contract ArtworkBuilder is Ownable {

	// artwork "params" will contains informations:
	// 0000000000 - randomSeed with 10000000000 possibilies 
	// + 00 - one of up to 100 sketch algorithms

	using SafeMath for uint256;
	using SafeMath32 for uint32;
	using SafeMath16 for uint16;

	event NewArtwork(uint artworkId, string name, bytes3 bgcolor, uint params);

	uint paramDigits = 12;
	uint paramsModulus = 10 ** paramDigits;
	uint cooldownTime = 0 days;

	struct Artwork {
		string name;
		uint params;
		bytes3 bgcolor;
		uint32 readyTime;
		uint32 rating;
		uint32 raters;
		uint8 level;
	}

	Artwork[] public artworks;

    mapping (uint => address) public artworkToOwner;
    mapping (address => uint) ownerArtworkCount;

	function _createArtwork (string memory _name, bytes3 _bgcolor, uint _params) internal {
		uint id = artworks.push(Artwork(_name, _params, _bgcolor, uint32(now + cooldownTime), 0, 0, 1)) - 1;
		artworkToOwner[id] = msg.sender;
        ownerArtworkCount[msg.sender]++;
        emit NewArtwork(id, _name, _bgcolor, _params);
	}

	function _generateRandomParams() internal view returns (uint) {
		uint rand = uint(keccak256(abi.encodePacked(now, msg.sender)));
		return rand % paramsModulus;
	}

	function createRandomArtwork() public {
		// first artwork has sketch set to 00 -- free beginner sketch
		require(ownerArtworkCount[msg.sender] == 0);
        uint randParams = _generateRandomParams();
        randParams = randParams - (randParams % 100);
        _createArtwork("New Artwork", 0xffffff, randParams);
    }
}
