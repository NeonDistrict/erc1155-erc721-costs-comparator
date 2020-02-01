/* global artifacts module */

const ERC721Test = artifacts.require('ERC721Test');

const proxyRegistryAddress = '0x0000000000000000000000000000000000000000';

module.exports = async (deployer) => {
  await deployer.deploy(
    ERC721Test,
    "Test NFT",
    "ERC721Test",
    proxyRegistryAddress
  );
};
