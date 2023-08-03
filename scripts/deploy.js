require("dotenv").config();

async function deploy(hre)
{
    let tx;
    const ethers = hre.ethers;
    const contracts = {};
    console.log("ROUTER=" + hre.network.config.router);

    // First deploy registry.
    const Registry = await ethers.getContractFactory("Registry");
    contracts.registry = await Registry.deploy();
    await contracts.registry.deployed();
    console.log("REGISTRY=" + contracts.registry.address);

    // Add router to registry
    tx = await contracts.registry.addContract("Router", hre.network.config.router);
    await tx.wait();

    // Deploy pair token.
    const PairToken = await ethers.getContractFactory("PairToken");
    if(hre.network.config.pairToken) {
        contracts.pairtoken = PairToken.attach(hre.network.config.pairToken);
    } else {
        contracts.pairtoken = await PairToken.deploy();
        await contracts.pairtoken.deployed();
    }
    tx = await contracts.registry.addContract("PairToken", contracts.pairtoken.address);
    await tx.wait();
    console.log("PAIR_TOKEN=" + contracts.pairtoken.address);

    // Deploy tax handler.
    const TaxHandler = await ethers.getContractFactory("TaxHandler");
    contracts.taxhandler = await TaxHandler.deploy(
        contracts.registry.address
    );
    await contracts.taxhandler.deployed();
    // Add tax handler to registry.
    tx = await contracts.registry.addContract("TaxHandler", contracts.taxhandler.address);
    await tx.wait();
    console.log("TAXHANDLER=" + contracts.taxhandler.address);

    // Deploy token.
    const Token = await ethers.getContractFactory("Token");
    contracts.token = await Token.deploy(
        process.env.TOKEN_NAME,
        process.env.TOKEN_SYMBOL,
        contracts.registry.address,
        process.env.TOKEN_MAX_SUPPLY,
        hre.network.config.tokenLaunchTime || 0,
    );
    await contracts.token.deployed();
    // Add token to registry.
    tx = await contracts.registry.addContract("Token", contracts.token.address);
    await tx.wait();
    console.log("TOKEN=" + contracts.token.address);

    // Disown registry
    tx = await contracts.registry.renounceOwnership();
    await tx.wait();

    // If we're on hardhat network, nothing to verify
    if(hre.network.name === "hardhat") {
        return contracts;
    }

    // Sleep for 1 minute and then verify contracts.
    await sleep(60000);
    // Verify registry.
    await hre.run("verify:verify", {
        address: contracts.registry.address
    });
    // Verify pair token.
    if(!hre.network.config.pairtoken) {
        await hre.run("verify:verify", {
            address: contracts.pairtoken.address
        });
    }
    // Verify tax handler.
    await hre.run("verify:verify", {
        address: contracts.taxhandler.address,
        constructorArguments: [
            contracts.registry.address
        ]
    });
    // Verify token.
    await hre.run("verify:verify", {
        address: contracts.token.address,
        constructorArguments: [
            process.env.TOKEN_NAME,
            process.env.TOKEN_SYMBOL,
            contracts.registry.address,
            process.env.TOKEN_MAX_SUPPLY,
            hre.network.config.tokenLaunchTime || 0,
        ]
    });

    return contracts;
}

function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

module.exports = deploy;