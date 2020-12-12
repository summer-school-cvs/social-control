const { copySync } = require("fs-extra")

var Alliance = artifacts.require("./Alliance.sol")
var Election = artifacts.require("./Election.sol")
var AllianceStorage = artifacts.require("./AllianceStorage.sol")
var DefaultAllianceImplementation = artifacts.require("./DefaultAllianceImplementation.sol")

contract("Alliance", (accounts) => {

    it("Deploys contract properly", async () => {
        instance = await Alliance.deployed();
        assert(instance.address != '')
        assert(instance.address != undefined)
    })

    it("Allows to create a join member election", async () => {
        instance = await Alliance.deployed();
        res = await instance.join.call(accounts[2])
        assert(res != '')
        isvalid = web3.utils.isAddress(res)
        assert.equal(isvalid, true, "address of election was returned")
    })

    it("Allows to create a exclude member election", async () => {
        instance = await Alliance.deployed();
        res = await instance.exclude.call(accounts[2])
        assert(res != '')
        isvalid = web3.utils.isAddress(res)
        assert.equal(isvalid, true, "address of election was returned")
    })

    it("Allows to create a update impl election", async () => {
        instance = await Alliance.deployed();
        res = await instance.updateImplementation.call(accounts[2])
        assert(res != '')
        isvalid = web3.utils.isAddress(res)
        assert.equal(isvalid, true, "address of election was returned")
    })

    it("Self destruct", async () => {
        instance = await Alliance.deployed();
        res = await instance.destroy()
        assert(res != undefined)
        assert(res != '')
    })

    it("Basic operations", async () => {
        instance = await DefaultAllianceImplementation.deployed();
        res = await instance.join(accounts[2], { from: accounts[0] })
        el_addr = res.receipt.to
        election = await Election.at(el_addr)
        vote = await election.vote(0, 1, { from: accounts[0] })
        // gives error
        console.log(vote)
    })

    it("Allows to leave from members", async () => {
        instance = await Alliance.deployed();
        process = await instance.leave.call()
    })


    // add delegate and undelegate
})
