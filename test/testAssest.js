// //Reference: https://forum.openzeppelin.com/t/simple-erc20-token-example/4403Asset
// const { expect } = require('chai');

// // Import utilities from Test Helpers
// const { BN } = require('@openzeppelin/test-helpers');
// const Asset = artifacts.require('Asset');
// contract('Asset', function ([ creator, other ]) {
//   const NAME = 'RUPEE';
//   const SYMBOL = 'INR';
//   const TOTAL_SUPPLY = new BN('10000000000000000000000');

//   beforeEach(async function () {
//     this.token = await Asset.new(NAME, SYMBOL, TOTAL_SUPPLY, { from: creator });
//   });

//   it('retrieve returns a value previously stored', async function () {    
//     expect(await this.token.totalSupply()).to.be.bignumber.equal(TOTAL_SUPPLY);
//   });

//   it('has a name', async function () {
//     expect(await this.token.name()).to.be.equal(NAME);
//   });

//   it('has a symbol', async function () {
//     expect(await this.token.symbol()).to.be.equal(SYMBOL);
//   });

//   it('assigns the initial total supply to the creator', async function () {
//     expect(await this.token.balanceOf(creator)).to.be.bignumber.equal(TOTAL_SUPPLY);
//   });
// });

// contract('Asset', function ([ creator, other ]) {

//   const NAME = 'SASKE';
//   const SYMBOL = 'SKE';
//   const TOTAL_SUPPLY = new BN('10000000000000000000000');

//   beforeEach(async function () {
//     this.token = await Asset.new(NAME, SYMBOL, TOTAL_SUPPLY, { from: creator });
//   });

//   it('retrieve returns a value previously stored', async function () {    
//     expect(await this.token.totalSupply()).to.be.bignumber.equal(TOTAL_SUPPLY);
//   });

//   it('has a name', async function () {
//     expect(await this.token.name()).to.be.equal(NAME);
//   });

//   it('has a symbol', async function () {
//     expect(await this.token.symbol()).to.be.equal(SYMBOL);
//   });

//   it('assigns the initial total supply to the creator', async function () {
//     expect(await this.token.balanceOf(creator)).to.be.bignumber.equal(TOTAL_SUPPLY);
//   });
// });


