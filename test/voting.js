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
        assert.equal(proposal[3], 0, "contains the correct votes count")
        // check second
        proposal = await instance.proposals(2)
        assert.equal(proposal[0], 2, "contains the correct id")
        assert.equal(proposal[1], "Black", "contains the correct name")
        // can check [2] = description 
        assert.equal(proposal[3], 0, "contains the correct votes count")
    })

    it("Initializes with valid discard", async () => {
        instance = await Voting.deployed()
        //check first
        discard = await instance.discards(0)
        assert.equal(discard[0], 0, "contains the correct id")
        // 1 field is a name
        assert.equal(discard[1], "Discard", "contains the correct name")
        assert.equal(discard[2], 0, "contains the correct votes count")
    })

    it("Allows to cast a vote", async () => {
        instance = await Voting.deployed()
        proposal = 1
        receipt = await instance.vote(proposal, 4, { from: accounts[0] })
        voted = await instance.voters(accounts[0])
        assert(voted, "was marked (voted, can't vote anymore)")
        candidate = await instance.proposals(proposal)
        voteCount = candidate[3]
        assert.equal(voteCount, 4, "Increments by votePower ")
    })

    it("Allows to end a voting", async () => {
        instance = await Voting.deployed()
        init = await instance.Ended()
        assert.equal(init, false, "Creates a valid Ended state")
        end = await instance.endVote()
        endResult = await instance.Ended()
        assert.equal(endResult, true, "Allows to end voting")
    })
})