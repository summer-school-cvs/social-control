var Alliance = artifacts.require("./Alliance.sol")

contract("Alliance", (accounts) => {

    it("Deploys contract properly", async () => {
        instance = await Alliance.deployed();
        assert(instance.address != '')
        assert(instance.address != undefined)
    })

    it("Allows to create a join member election", async () => {
        instance = await Alliance.deployed();
        res = await instance.join(accounts[2])
        assert(res != undefined)
        assert(res != '')
    })

    it("Allows to create a exclude member election", async () => {
        instance = await Alliance.deployed();
        res = await instance.exclude(accounts[2])
        assert(res != undefined)
        assert(res != '')
    })

    // VM Error
    it("Allows to leave from members", async () => {
        instance = await Alliance.deployed();
        address = await instance.leave()

        console.log(address)
    })

})