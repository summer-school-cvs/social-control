var Alliance = artifacts.require("Alliance")

contract("alliance_test", (accounts) => {
    it("Create new alliance", async () => {
        alliance = await Alliance.new({ from: accounts[0] });
        assert.isOk(alliance, "Contract was not deployed.");

        members_count = await alliance.membersCount();
        assert.equal(members_count, 1, "The new alliance must have at least one member.");
        
        is_memeber = await alliance.isMember(accounts[0]);
        assert.equal(is_memeber, true, "The creator must be a member of the alliance.");

        alliance.destroy.sendTransaction({ from: accounts[0] });
        // TODO: Check if it is destroyed.
    })

    it("Last member", async () => {
        alliance = await Alliance.new({ from: accounts[0] });
        assert.isOk(alliance, "Contract was not deployed.");

        members_count = await alliance.membersCount.call();
        assert.equal(members_count, 1, "The new alliance must have at least one member.");

        alliance.leave.sendTransaction({ from: accounts[0] });
        // TODO: Check if it is destroyed.
    })
})