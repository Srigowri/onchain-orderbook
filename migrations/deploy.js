const Asset = artifacts.require('Asset');

module.exports = async function (deployer) {
  await deployer.deploy(Asset, 'Rupee', 'INR', '10000000000000000000000');
  await deployer.deploy(Asset, 'Saske', 'SKE', '10000000000000000000000');
};