var Alliance = artifacts.require("Alliance")
var IElection = artifacts.require("IElection")

contract("members_test", (accounts) => {
    it("Add 9 members and remove all.", async () => {
        alliance = await Alliance.new({ from: accounts[0] });
        assert.isOk(alliance, "Contract was not deployed.");

        members_count = await alliance.membersCount();
        assert.equal(members_count, 1, "The new alliance must have at least one member.");


        for (let i = 1; i < 10; i++) {
            await alliance.join.sendTransaction(accounts[i]);
            election_add = await alliance.candidates_for_membership(accounts[i]);
            election = await IElection.at(election_add);
            
            let votes = i < 5 ? i : 5;
            for (let j = 0; j < votes; j++) {
                await election.vote.sendTransaction(0, { from: accounts[j] });
            }

            await alliance.processVotingResult.sendTransaction(election_add, { from: accounts[0] });

            members_count = await alliance.membersCount();
            assert.equal(members_count, i + 1, "The member has not been added.");
        }

        for (let i = 9; i > 0; i--) {
            await alliance.exclude.sendTransaction(accounts[i]);
            election_excl = await alliance.candidates_for_exclusion(accounts[i]);
            election = await IElection.at(election_excl);
            
            let votes = i < 5 ? i : 5;
            for (let j = 0; j < votes; j++) {
                await election.vote.sendTransaction(1, { from: accounts[j] });
            }

            await alliance.processVotingResult.sendTransaction(election_excl, { from: accounts[0] });

            members_count = await alliance.membersCount();
            assert.equal(members_count, i, "The member has not been excluded.");
        }

        try {
            await alliance.exclude.sendTransaction(accounts[0]);
            throw null;
        }
        catch (error) {
            assert(error, "Excluding the last member through voting is a mistake.")
        }

        alliance.leave.sendTransaction({ from: accounts[0] });
        // TODO: Check if it is destroyed.
    })
})