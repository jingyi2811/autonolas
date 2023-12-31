pragma solidity =0.8.20;

import {Test} from "forge-std/Test.sol";
import {Utils} from "./utils/Utils.sol";
import {ZuniswapV2Factory} from "zuniswapv2/ZuniswapV2Factory.sol";
import {ZuniswapV2Router} from "zuniswapv2/ZuniswapV2Router.sol";
import {ZuniswapV2Pair} from "zuniswapv2/ZuniswapV2Pair.sol";
import "../src/Depository.sol";
import "../src/GenericBondCalculator.sol";
import "../src/test/MockTokenomics.sol";
import {MockERC20} from "../lib/zuniswapv2/lib/solmate/src/test/utils/mocks/MockERC20.sol";
import "../src/Treasury.sol";
import "forge-std/console.sol";
import "../src/Tokenomics.sol";
import "../src/Dispenser.sol";
import "../src/test/MockVE.sol";
import "../src/test/MockRegistry.sol";
import {DonatorBlacklist} from "../src/DonatorBlacklist.sol";

contract BaseSetup is Test {
    Utils internal utils;
    MockERC20 internal olas;
    MockERC20 internal dai;
    ZuniswapV2Factory internal factory;
    ZuniswapV2Router internal router;
    MockTokenomics internal tokenomics;
    Treasury internal treasury;
    Depository internal depository;
    GenericBondCalculator internal genericBondCalculator;
    Dispenser internal dispenser;
    MockVE internal mockVE;
    MockRegistry internal mockComponentRegistry;
    MockRegistry internal mockAgentRegistry;
    MockRegistry internal mockServiceRegistry;
    DonatorBlacklist internal donatorBlacklist;

    address payable[] internal users;
    address internal deployer;
    address internal dev;
    address internal pair;

    uint256 internal initialMint = 40_000 ether;
    uint256 internal largeApproval = 1_000_000 ether;
    uint256 internal initialLiquidity;
    uint256 internal amountOLAS = 5_000 ether;
    uint256 internal amountDAI = 5_000 ether;
    uint256 internal minAmountOLAS = 5_00 ether;
    uint256 internal minAmountDAI = 5_00 ether;
    uint256 internal supplyProductOLAS =  2_000 ether;
    uint256 internal defaultPriceLP = 2 ether;
    uint256 internal vesting = 7 days;

    function setUp() public virtual {
        utils = new Utils();
        users = utils.create2Users();

        deployer = users[0];
        vm.label(deployer, "Deployer");
        dev = users[1];
        vm.label(dev, "Developer");

        olas = new MockERC20("OLAS Token", "OLAS", 18);
        olas.mint(address(this), initialMint);
        dai = new MockERC20("DAI Token", "DAI", 18);
        dai.mint(address(this), initialMint);

         tokenomics = new MockTokenomics();
        treasury = new Treasury(address(olas), address(tokenomics), deployer, deployer);
        genericBondCalculator = new GenericBondCalculator(address(olas), address(tokenomics));
        depository = new Depository(address(olas), address(tokenomics), address(treasury), address(genericBondCalculator));

        dispenser = new Dispenser(address(tokenomics), address(treasury));
        donatorBlacklist = new DonatorBlacklist();
        mockVE = new MockVE();

        mockComponentRegistry = new MockRegistry();
        mockAgentRegistry = new MockRegistry();
        mockServiceRegistry = new MockRegistry();
        donatorBlacklist = new DonatorBlacklist();
    }
}

contract TokenomicsTest is BaseSetup {
    function setUp() public override {
        super.setUp();
    }

    function testMy() public {
        Tokenomics t = new Tokenomics();

        t.initializeTokenomics(
            address(olas),
            address(treasury),
            address(depository),
            address(dispenser),
            address(mockVE),
            1 weeks,
            address(mockComponentRegistry),
            address(mockAgentRegistry),
            address(mockServiceRegistry),
            address(donatorBlacklist)
        );

        t.checkpoint();
    }
}
