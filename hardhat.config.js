require("@nomicfoundation/hardhat-toolbox");
require("hardhat-interface-generator");
require("dotenv").config();

require("./tasks/deployContracts");

const accounts = process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [];

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
    solidity: {
        compilers: [
            {
                version: "0.8.9",
                settings: {
                    optimizer: {
                        enabled: true,
                        runs: 200
                    }
                }
            }
        ]
    },
    defaultNetwork: "hardhat",
    networks: {
        hardhat: {
            forking: {
                url: process.env.SEPOLIA_RPC_URL || '',
                blockNumber: 3096771
            },
            router: process.env.SEPOLIA_ROUTER || ''
        },
        sepolia: {
            url: process.env.SEPOLIA_RPC_URL || '',
            accounts: accounts,
            router: process.env.SEPOLIA_ROUTER || '',
            pairToken: process.env.SEPOLIA_PAIR_TOKEN || null
        },
        bsc: {
            url: process.env.BSC_RPC_URL || '',
            accounts: accounts,
            router: process.env.BSC_ROUTER || ''
        }
    },
    etherscan: {
        apiKey: {
            sepolia: process.env.SEPOLIA_ETHERSCAN_API_KEY || '',
            bsc: process.env.BSC_ETHERSCAN_API_KEY || ''
        }
    },
    gasReporter: {
        enabled: true,
        currency: 'USD',
        gasPrice: 21,
        coinmarketcap: process.env.COINMARKETCAP_API_KEY || ''
    }
};
