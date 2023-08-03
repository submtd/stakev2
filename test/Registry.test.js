const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Registry", function () {
    let Registry;
    let registry;
    let owner;
    let addr1;

    beforeEach(async function () {
        Registry = await ethers.getContractFactory("Registry");
        [owner, addr1] = await ethers.getSigners();
        registry = await Registry.deploy();
        await registry.deployed();
    });

    it("Should add contract to the registry", async function () {
        await registry.connect(owner).addContract("Contract1", addr1.address);
        expect(await registry.getContract("Contract1")).to.equal(addr1.address);
    });

    it("Should not add contract to the registry if not owner", async function () {
        await expect(registry.connect(addr1).addContract("Contract1", addr1.address)).to.be.revertedWith("Ownable: caller is not the owner");
    });

    it("Should not add contract to the registry if contract address is empty", async function () {
        await expect(registry.connect(owner).addContract("Contract1", ethers.constants.AddressZero)).to.be.revertedWithCustomError(registry, "ContractAddressCannotBeEmpty");
    });

    it("Should not add contract to the registry if contract already exists", async function () {
        await registry.connect(owner).addContract("Contract1", addr1.address);
        await expect(registry.connect(owner).addContract("Contract1", addr1.address)).to.be.revertedWithCustomError(registry, "ContractHasAlreadyBeenSet");
    });

    it("Should get contract address from the registry", async function () {
        await registry.connect(owner).addContract("Contract1", addr1.address);
        const contractAddress = await registry.getContract("Contract1");
        expect(contractAddress).to.equal(addr1.address);
    });

    it("Should not get contract address from the registry if contract does not exist", async function () {
        await expect(registry.getContract("Contract1")).to.be.revertedWithCustomError(registry, "ContractDoesNotExist");
    });
});
