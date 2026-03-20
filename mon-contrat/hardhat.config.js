require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

const config = {
  solidity: "0.8.20",
  networks: {
    ganache: {
      url: "http://127.0.0.1:8545",
      chainId: 1337
    }
  }
};

if (process.env.ALCHEMY_URL && process.env.PRIVATE_KEY && process.env.PRIVATE_KEY.length > 20) {
  const pk = process.env.PRIVATE_KEY.startsWith("0x")
    ? process.env.PRIVATE_KEY
    : `0x${process.env.PRIVATE_KEY}`;
  config.networks.sepolia = {
    url: process.env.ALCHEMY_URL,
    chainId: 11155111,
    accounts: [pk]
  };
}

module.exports = config;
