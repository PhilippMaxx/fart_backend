pragma solidity >=0.4.22 <0.9.0;

import "./artworkhelper.sol";
import "./erc721.sol";
import "./safemath.sol";

contract ArtworkOwnership is ArtworkHelper, ERC721 {

  using SafeMath for uint256;

  mapping (uint => address) artworkApprovals;

  function balanceOf(address _owner) external view returns (uint256) {
    return ownerArtworkCount[_owner];
  }

  function ownerOf(uint256 _artworkId) external view returns (address) {
    return artworkToOwner[_artworkId];
  }

  function _transfer(address _from, address _to, uint256 _artworkId) private {
    ownerArtworkCount[_to] = ownerArtworkCount[_to].add(1);
    ownerArtworkCount[msg.sender] = ownerArtworkCount[msg.sender].sub(1);
    artworkToOwner[_artworkId] = _to;
    emit Transfer(_from, _to, _artworkId);
  }

  function transferFrom(address _from, address _to, uint256 _artworkId) external payable {
    require (artworkToOwner[_artworkId] == msg.sender || artworkApprovals[_artworkId] == msg.sender);
    _transfer(_from, _to, _artworkId);
  }

  function approve(address _approved, uint256 _artworkId) external payable onlyOwnerOf(_artworkId) {
    artworkApprovals[_artworkId] = _approved;
    emit Approval(msg.sender, _approved, _artworkId);
  }

}
