require("@nomicfoundation/hardhat-toolbox");
require("@nomiclabs/hardhat-waffle");
require('dotenv').config()

/** @type import('hardhat/config').HardhatUserConfig */

const optimismGoerliUrl = process.env.ALCHEMY_API_KEY    


module.exports = {
  solidity: "0.8.17",
  networks: {
    "optimism-goerli": {
       url: optimismGoerliUrl,
       accounts: { mnemonic: process.env.MNEMONIC }
    },
    "base-goerli": {
      url: "https://goerli.base.org",
      accounts: { mnemonic: process.env.MNEMONIC }
   },
   // for testnet   
    'zora-goerli': {      
      url: 'https://testnet.rpc.zora.energy/', 
          accounts: { mnemonic: process.env.MNEMONIC}
        }
  }
};
