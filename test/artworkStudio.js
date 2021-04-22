const ArtworkBuilder = artifacts.require("ArtworkOwnership");
const utils = require("./helpers/utils");
const time = require("./helpers/time");

contract("ArtworkBuilder", (accounts) => {
    let [alice, bob] = accounts;
    let contractInstance;
    beforeEach(async () => {
        contractInstance = await ArtworkBuilder.new();
    });

    it("should be able to create a new artworks", async () => {
    	var result = await contractInstance.createRandomArtwork({from: alice});
		assert.equal(result.receipt.status, true);
    	assert.equal(result.logs[0].args.name, "New Artwork");
    	assert.equal(result.logs[0].args.bgcolor, "0xffffff");
    })
    it("should not allow more than one artworks", async () => {
    	await contractInstance.createRandomArtwork({from: alice});
    	await utils.shouldThrow(contractInstance.createRandomArtwork({from: alice}));
    })

    context("with the single-step transfer scenario", async () => {
        it("should transfer an artwork", async () => {
            const result = await contractInstance.createRandomArtwork({from: alice});
            const artworkId = result.logs[0].args.artworkId.toNumber();
            await contractInstance.transferFrom(alice, bob, artworkId, {from: alice});
            const newOwner = await contractInstance.ownerOf(artworkId);
            //TODO: replace with expect
            assert.equal(newOwner, bob);
        })
    })
    context("with the two-step transfer scenario", async () => {
        it("should approve and then transfer an artwork when the approved address calls transferFrom", async () => {
            const result = await contractInstance.createRandomArtwork({from: alice});
            const artworkId = result.logs[0].args.artworkId.toNumber();
            await contractInstance.approve(bob, artworkId, {from: alice});
            await contractInstance.transferFrom(alice, bob, artworkId, {from: bob});
            const newOwner = await contractInstance.ownerOf(artworkId);
            //TODO: replace with expect
            assert.equal(newOwner,bob);
        })
        it("should approve and then transfer an artwork when the owner calls transferFrom", async () => {
            const result = await contractInstance.createRandomArtwork({from: alice});
            const artworkId = result.logs[0].args.artworkId.toNumber();
            await contractInstance.approve(bob, artworkId, {from: alice});
            await contractInstance.transferFrom(alice, bob, artworkId, {from: alice});
            const newOwner = await contractInstance.ownerOf(artworkId);
            //TODO: replace with expect
            assert.equal(newOwner,bob);
         })
    })
})