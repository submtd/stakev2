const { task } = require("hardhat/config");
const deploy = require("../scripts/deploy");

task("deployContracts", "Deploy all contracts")
    .setAction(async (taskArgs, hre) => {
        await hre.run("clean");
        await hre.run("compile");
        await deploy(hre);
    });
