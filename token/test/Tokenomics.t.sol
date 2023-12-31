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
        users = utils.createUsers(2);

        deployer = users[0];
        vm.label(deployer, "Deployer");
        dev = users[1];
        vm.label(dev, "Developer");

        // Get tokens and their initial mint
        olas = new MockERC20("OLAS Token", "OLAS", 18);
        olas.mint(address(this), initialMint);
        dai = new MockERC20("DAI Token", "DAI", 18);
        dai.mint(address(this), initialMint);

        // Deploying depository, treasury and mock tokenomics contracts
        tokenomics = new MockTokenomics();
        // Correct depository address is missing here, it will be defined just one line below
        treasury = new Treasury(address(olas), address(tokenomics), deployer, deployer);
        // Deploy generic bond calculator contract
        genericBondCalculator = new GenericBondCalculator(address(olas), address(tokenomics));
        // Deploy depository contract
        depository = new Depository(address(olas), address(tokenomics), address(treasury), address(genericBondCalculator));
        // Change depository contract addresses to the correct ones
        treasury.changeManagers(address(0), address(depository), address(0));

        // Deploy factory and router
        factory = new ZuniswapV2Factory();
        router = new ZuniswapV2Router(address(factory));

        // Create LP token
        factory.createPair(address(olas), address(dai));
        // Get the LP token address
        pair = factory.pairs(address(olas), address(dai));

        // Add liquidity
        olas.approve(address(router), largeApproval);
        dai.approve(address(router), largeApproval);

        (, , initialLiquidity) = router.addLiquidity(
            address(dai),
            address(olas),
            amountDAI,
            amountOLAS,
            amountDAI,
            amountOLAS,
            address(this)
        );

        // Enable LP token in treasury
        treasury.enableToken(pair);
        uint256 priceLP = depository.getCurrentPriceLP(pair);

        // Create bond product
        depository.create(pair, priceLP, supplyProductOLAS, vesting);

        // Give large approvals to accounts
        vm.prank(deployer);
        ZuniswapV2Pair(pair).approve(address(treasury), largeApproval);
        vm.prank(dev);
        ZuniswapV2Pair(pair).approve(address(treasury), largeApproval);
    }
}

contract TokenomicsTest is BaseSetup {
    function setUp() public override {
        super.setUp();
    }

    function myTest() public {
    }
}
