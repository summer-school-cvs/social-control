const Alliance = artifacts.require("Alliance");
const AllianceStorage = artifacts.require("AllianceStorage");
const DefaultAllianceImplementation = artifacts.require("DefaultAllianceImplementation");

module.exports = function (deployer) {
    deployer.deploy(Alliance);
    deployer.deploy(AllianceStorage);
    deployer.deploy(DefaultAllianceImplementation);
};