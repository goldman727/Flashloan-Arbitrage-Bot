const hre = require("hardhat");

async function main() {
    const [deployer] = await hre.ethers.getSigners();

    console.log("Deploying contracts with the account:", deployer.address);

    const FlashloanArbitrage = await hre.ethers.getContractFactory("TwoExchangeFlashloanArbitrage");
    const flashloanArbitrage = await FlashloanArbitrage.deploy(
        "0x2f39d218133AFaB8F2B819B1066c7E434Ad94E9e", // Aave Lending Pool Addresses Provider on ethereum mainnet
        "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D", // Uniswap Router Address on ethereum mainnet
        "0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F", // Sushiswap Router Address on ethereum mainnet
        "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2", // WETH Address on ethereum mainnet
        // "0xFF34B3d4Aee8ddCd6F9AFFFB6Fe49bD371b8a357"  // DAI Address on ethereum mainnet
    );

    await flashloanArbitrage.deployed();

    console.log("FlashloanArbitrage deployed to:", flashloanArbitrage.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });



