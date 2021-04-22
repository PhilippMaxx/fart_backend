var Artworks = artifacts.require("./artworkownership.sol");

module.exports = function(deployer) {
  deployer.deploy(Artworks);
};