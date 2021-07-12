const { expect } = require("chai");
const { waffle, ethers, network } = require("hardhat");

const LoopTest = require("../artifacts/contracts/LoopTest.sol/LoopTest.json");

const BN = ethers.BigNumber;
const parseEther = ethers.utils.parseEther;

describe("TaToPia", function() {
    async function fixture() {
        const signers = await ethers.getSigners();
        const loopTest = await waffle.deployContract(signers[0], LoopTest);

        for (let i=0; i < 5000; i++) {
            await loopTest.connect(signers[i]).store();
        }

        return { loopTest, signers };
    }

    it("Big Loop", async () => {
        const { loopTest, signers } = await waffle.loadFixture(fixture);
        
        console.log("haha");
        await loopTest.bigLoop(0, 5000);
        const flag = await loopTest.flag();
        expect(flag);
    })

});