pragma solidity >=0.4.22 <0.9.0;

import "./artworkstudio.sol";

contract ArtworkHelper is ArtworkBuilder {

 uint levelUpFee = 0.01 ether;
 uint8 maxLevel = 5;

  modifier onlyOwnerOf(uint _artworkId) {
    require(msg.sender == artworkToOwner[_artworkId]);
    _;
  }  

  modifier aboveLevel(uint8 _level, uint _artworkId) {
    require(artworks[_artworkId].level >= _level);
    _;
  }

  modifier belowLevel(uint8 _level, uint _artworkId) {
    require(artworks[_artworkId].level < _level);
    _;
  }  

  function setLevelUpFee(uint _fee) external onlyOwner {
    levelUpFee = _fee;
  }

  function setMaxLevel(uint8 _level) external onlyOwner {
    maxLevel = _level;
  }

  function levelUp(uint _artworkId) external payable belowLevel(maxLevel, _artworkId) {
    require(msg.value == levelUpFee);
    artworks[_artworkId].level++;
  }

  function withdraw() external onlyOwner {
    address payable _owner = address(uint160(owner()));
    _owner.transfer(address(this).balance);
  }

  function _triggerCooldown(Artwork storage _artwork) internal {
    _artwork.readyTime = uint32(now + cooldownTime);
  }

  function _isReady(Artwork storage _artwork) internal view returns (bool) {
      return (_artwork.readyTime <= now);
  }  

  function randomSketch(uint8 _level) internal view returns (uint) {
      uint randomLevel = uint(keccak256(abi.encodePacked(now, msg.sender))) % _level;
      return randomLevel;
  }

  function changeParams(uint _artworkId) external onlyOwnerOf(_artworkId) {
    Artwork storage myArtwork = artworks[_artworkId];
    require(_isReady(myArtwork));
    uint8 _level = myArtwork.level;
    uint randParams = _generateRandomParams();
    randParams = randParams - (randParams % 100);
    if (_level > 1) {
      randParams = randParams + randomSketch(_level);
    }
    myArtwork.params = randParams;
    _triggerCooldown(myArtwork);
  }

  function changeName(uint _artworkId, string calldata _newName) external onlyOwnerOf(_artworkId) {
    artworks[_artworkId].name = _newName;
  }

  function changeBgcolor(uint _artworkId, bytes3 _bgcolor) external onlyOwnerOf(_artworkId) {
    artworks[_artworkId].bgcolor = _bgcolor;
  }

  function changeRating(uint _artworkId, uint32 _rating) external {
    require((_rating <= 10) && (_rating >= 0));
    artworks[_artworkId].rating = artworks[_artworkId].rating + _rating;
    artworks[_artworkId].raters++;
  }  

  function getArtworksByOwner(address _owner) external view returns(uint[] memory) {
    uint[] memory result = new uint[](ownerArtworkCount[_owner]);
    uint counter = 0;
    for (uint i = 0; i < artworks.length; i++) {
      if (artworkToOwner[i] == _owner) {
        result[counter] = i;
        counter++;
      }
    }
    return result;
  }

  function getArtworkCount() external view returns(uint) {
    return artworks.length;
  }

}
