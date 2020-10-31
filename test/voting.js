var Voting = artifacts.require("./Voting.sol")

contract("Voting", (accounts) => {

    it("Initializes with 2 proposals", async () => {
        instance = await Voting.deployed();
        count = await instance.proposalsCount();
        assert.equal(count, 2);
    })

    it("Initializes with proposals with correct values", async () => {
        instance = await Voting.deployed()
        //check first
        proposal = await instance.proposals(1)
        assert.equal(proposal[0], 1, "contains the correct id")
        // 1 field is a name
        assert.equal(proposal[1], "White", "contains the correct name")
        assert.equal(proposal[2], 0, "contains the correct votes count")
        // check second
        proposal = await instance.proposals(2)
        assert.equal(proposal[0], 2, "contains the correct id")
        assert.equal(proposal[1], "Black", "contains the correct name")
        assert.equal(proposal[2], 0, "contains the correct votes count")
    })
})