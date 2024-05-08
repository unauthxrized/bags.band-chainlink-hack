import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { ethers } from "hardhat";
import { SignerWithAddress } from "@nomicfoundation/hardhat-ethers/signers";
import { expect } from "chai";
import hre from "hardhat";
import { AggregatorV3Mock, BagsBandPool, UserStorage } from "../typechain-types";

describe("FirstTest", function () {

  let owner: SignerWithAddress;
  let user: SignerWithAddress;
  let user2: SignerWithAddress;
  let user3: SignerWithAddress;

  let btcpair: AggregatorV3Mock;
  let ethpair: AggregatorV3Mock;

  let storage: UserStorage;

  let firstprotocol: BagsBandPool;
  let secondprotocol: BagsBandPool;

  before(async () => {
    [owner, user, user2, user3] = await ethers.getSigners();

    const AggregatorV3Mocked = await ethers.getContractFactory("AggregatorV3Mock");
    btcpair = await AggregatorV3Mocked.deploy(6325692456734);
    ethpair = await AggregatorV3Mocked.deploy(220045623491);

    const UserStorageContract = await ethers.getContractFactory('UserStorage');
    storage = await UserStorageContract.deploy();

    const BagsBandPoolContract = await ethers.getContractFactory("BagsBandPool");
    firstprotocol = await BagsBandPoolContract.deploy(await storage.getAddress(), await btcpair.getAddress());
    secondprotocol = await BagsBandPoolContract.deploy(await storage.getAddress(), await ethpair.getAddress());

    await storage.addProtocol(await firstprotocol.getAddress());
    await storage.addProtocol(await secondprotocol.getAddress());
})

  describe("Test Init", function () {
    it("First Protocol Test", async function () {
      await firstprotocol.connect(user).makePosition(true, 1000);
      const userPosition = await firstprotocol.position(user.address);
      
      expect(userPosition[0]).eq(1000n);
    });

    it("Some expected desc", async function () {
      const balance = await storage.getBalance(user.address);
      expect(balance).eq(9000n);
    });

    it("Some expected desc", async function () {
      
    });

    it("Some expected desc", async function () {
      
    });
  });
});
