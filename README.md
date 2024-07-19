Document for flashloan bot

1.Install Node.js and Unzip flashloanarbitrage.zip file
2.Open folder and open CMD in this folder.
3.Set environment variable for smart contract compile and deploy.
-  open hardhat.config.js file, edit it as under image.



4.Smart contract compile and deploy
     -  For compile, in CMD, please run this instruction
	“npx hardhat compile”
     -  For deploy, in CMD, Run this instrunction
                “npx hardhat run scripts/deploy.js --network mainnet”
* important:
	When smart contract deployed successfully, you will see 	deployed contract address on CMD(***Save this 	address***)

5.Setting environment variable for bot running.
	- Open .env file
	Edit under image


	- After change .env, Edit bot.js file(FLASHLOAN_CONTRACT, FLASHLOAN_ABI)
	
	

	* Already you saved deployed contract address.
	* For FLASHLOAN_ABI, please open 	artifacts/contracts/TwoExchangeFlashloanArbitrage.sol/TwoExchangeFlashloanArbitrage.json
	In here, you will see “abi”:[], please copy array and past for your 	smart contract ABI.

6.Run flashloan bot
Open CMD agai, run this instruction 
 “node bot.js”

GREAT!
You will see bot running now.

