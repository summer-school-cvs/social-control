var Alliance = artifacts.require("Alliance")
var IElection = artifacts.require("IElection")

contract("members_test", (accounts) => {
    it("Add members", async () => {
        alliance = await Alliance.new({ from: accounts[0] });
        assert.isOk(alliance, "Contract was not deployed.");

        members_count = await alliance.membersCount();
        assert.equal(members_count, 1, "The new alliance must have at least one member.");

        ///////////////////////////////////////////////////////////////////////////////////////////
        // join 2
        await alliance.join.sendTransaction(accounts[1]);
        election_add = await alliance.candidates_for_membership(accounts[1]);
        election = await IElection.at(election_add);
        await election.vote.sendTransaction(0, { from: accounts[0] });

        await alliance.processVotingResult.sendTransaction(election_add, { from: accounts[0] });

        members_count = await alliance.membersCount();
        assert.equal(members_count, 2, "The second member has not been added.");

        ///////////////////////////////////////////////////////////////////////////////////////////
        // join 3 fail
        await alliance.join.sendTransaction(accounts[2]);
        election_add = await alliance.candidates_for_membership(accounts[2]);
        election = await IElection.at(election_add);
        await election.vote.sendTransaction(0, { from: accounts[0] });

        await alliance.processVotingResult.sendTransaction(election_add, { from: accounts[0] });

        members_count = await alliance.membersCount();
        assert.equal(members_count, 2, "The member shouldn't have been added.");

        // join 2 success
        await alliance.join.sendTransaction(accounts[2]);
        election_add = await alliance.candidates_for_membership(accounts[2]);
        election = await IElection.at(election_add);
        await election.vote.sendTransaction(0, { from: accounts[0] });
        await election.vote.sendTransaction(0, { from: accounts[1] });

        await alliance.processVotingResult.sendTransaction(election_add, { from: accounts[0] });
        
        members_count = await alliance.membersCount();
        assert.equal(members_count, 3, "The 3 member has not been added.");

        ////////////////////////////////////////////////////

        await alliance.destroy({ from: accounts[0] });
        // TODO: Check if it is destroyed. 
    })
})