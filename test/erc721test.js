/* global assert artifacts before describe contract it require web3 */
var ERC721Test = artifacts.require("../contracts/ERC721Test.sol");

const shouldFail = require('../helpers/shouldFail.js');
const gasCost = require('../helpers/gasCost.js');

contract("ERC 721 Test", (accounts) => {

  var instance,
      owner = accounts[0],
      users = accounts;

  before(async() => {
    instance = await ERC721Test.deployed();
    console.log("Local instance contract address:", instance.address);
  });

  describe('Minting Test', () => {
    it('should mint to one', async() => {
      const tx = await instance.mint([users[1]], { from: owner });
      console.log("Gas used on minting to 1:", tx.receipt.gasUsed);
    });

    it('should mint to two', async() => {
      const tx = await instance.mint([users[1],users[2]], { from: owner });
      console.log("Gas used on minting to 2:", tx.receipt.gasUsed);
    });

    it('should mint to 10', async() => {
      const tx = await instance.mint(users, { from: owner });
      console.log("Gas used on minting to", users.length,":", tx.receipt.gasUsed);
    });
  });

  describe('Proxy registry address', async() => {
    it('should not allow non-owner to set address', async () => {
      await shouldFail.reverting(instance.setProxyRegistryAddress(
        // Useful address, not actually used for testing calls
        users[2],
        { from: users[1] }
      ));
    });

    it('should allow owner to set address', async () => {
      await instance.setProxyRegistryAddress(
        // Useful address, not actually used for testing calls
        users[2],
        { from: owner }
      );
      assert.equal(await instance.proxyRegistryAddress(), users[2]);
    });
  });
});
