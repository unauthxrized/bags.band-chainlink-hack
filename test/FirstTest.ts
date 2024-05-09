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
    it("Make position test", async function () {
      await firstprotocol.connect(user).makePosition(true, 1000);
      const userPosition = await firstprotocol.position(user.address);
      
      expect(userPosition[0]).eq(1000n);
    });

    it("Balance test", async function () {
      const balance = await storage.getBalance(user.address);
      expect(balance).eq(9000n);

      await btcpair.setCost(7325692456734);

      const data = await firstprotocol.calculateReward(user.address);
      // console.log(data);
      expect(data[0]).eq(1000000000000n);
      expect(data[3]).eq(true);
    });

    it("Close position", async function () {
      await firstprotocol.connect(user).closePosition();
      const upos = await firstprotocol.position(user.address);

      const balance = await storage.getBalance(user.address);

      // console.log(balance);
      
      expect(upos[0]).eq(0n);
      expect(balance).eq(10136n);
    });

    it("Second user position", async function () {
      await firstprotocol.connect(user2).makePosition(true, 3200);
      const userPosition = await firstprotocol.position(user2.address);
      
      expect(userPosition[0]).eq(3200n);
    });

    it("Oops...", async function () {
      await btcpair.setCost(5411111112233);
      const data = await firstprotocol.calculateReward(user2.address);
      console.log(data);
      
    });

    it("Check positions from storage", async function () {
      const data = await storage.calculateUserProfit(user2.address);
      console.log(data);
    });

    it("Stop position", async function () {
      await firstprotocol.connect(user2).closePosition();
      const balance = await storage.getBalance(user2.address);
      console.log(balance);
      
    });

    it("Get total users results", async function () {
      const data = await storage.getTotalUsersResults(0, 4);
      console.log(data);
    });
  });
});
