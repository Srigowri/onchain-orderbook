const Migrations = artifacts.require("Migrations");
const Orderbook = artifacts.require("Orderbook");
module.exports = function (deployer) {
  deployer.deploy(Migrations);
};
module.exports = function (deployer) {
  deployer.deploy(Orderbook);
};