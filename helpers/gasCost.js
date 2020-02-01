/* global module, web3 */

async function gasCost(receipt) {
  const gasUsed = web3.utils.toBN(receipt.receipt.gasUsed);
  const gasPrice = web3.utils.toBN((await web3.eth.getTransaction(receipt.tx)).gasPrice);
  return gasUsed.mul(gasPrice);
}

module.exports = gasCost;
