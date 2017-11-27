# ICOPool - An investment pool for ICOs

Please refer to my Medium article for further information, considerations and warnings about this contract: https://medium.com/@pabloruiz55/hacking-a-popular-ico-practice-that-only-rewards-the-richer-7d10b2019f1e

## The problem
Many ICOs offer volume-based bonuses that reward investors for investing some arbitrary amount of money (typically 20x - 100x of the minimum investment). While it is nice for investors to get extra tokens for their hefty investment, most people can't access such bonuses. This usually leads smaller investors to having to pool their resources with other people, which is very risky. The people organizing such pools may disappear with the money.

## The solution
What follows is a contract that allows people to pool their ether while making sure the money will only be used to invest in the selected ICO. Once the required money has been raised, the contract will buy the tokens from the selected crowdsale and make them available for its contributors to withdraw them. Contributors can also withdraw their money at any moment (before the money is used to buy the tokens).

## How it works
The ICOPool contract allows people to form an investment pool for any particular ICO. The idea behind this contract is to allow people to access volume-based bonuses that would not be accesible to them otherwise.

There's one person, the admin, who deploys the contract and configures the investment pool. Once the contract has been deployed, other people can send ether to it to participate in the pool.

Once enough money has been raised, the admin can instruct the contract to buy the tokens from the ICO. The contract will send the ether to the target ICO, which in turn will assign the corresponding tokens to the ICOPool.

Now, each contributor can withdraw the tokens they are entitled to. The contract will calculate how many tokens they own based on how many it bought and how much money each person contributed.

## How to set it up and use it
Please refer to this article for details on how to set the contract up and usage instructions: https://medium.com/@pabloruiz55/hacking-a-popular-ico-practice-that-only-rewards-the-richer-7d10b2019f1e

## How to test ICOPool

I've included another contract in this repository called Crowdsale.sol which contains an example ICO you can deploy to test the ICOPool. The Crowdsale.sol contract MUST NOT be used in production to run an ICO as it only contains the bare minimum functions to accept money and issue tokens. It has no security measures taken into account. I repeat, DON'T USE THE CROWDSALE code except to test ICOPool.

Here are the steps you can follow to deploy and test ICOPool:

1. Deploy the Crowdsale.sol contract. Take note of its address. Also, take note of the token's address ad we will need it later.

2. Deploy the ICOPool contract. You will need the address of the ICO/Crowdsale contract you just deployed. This is the ICO we are targetting which we'll buy the tokens from. You will need to supply the rest of the parameters which define minimum and maximum contributions, pool caps and number of contributors. You can use the following parameters (if testing on Remix):
"0x0XXXXXXX...","1000000000000000000","10000000000000000000","15000000000000000000","50000000000000000000",3,15

This will initialize the ICOPool contract with:
- The target ICO
- Minimum contribution per person: 1 ether
- Maximum contribution per person: 10 ether
- Soft cap (how much money must be raised at minimum to proceed with token purchase): 15 ether
- Hard cap (ICOPool won't accept contributions past this number): 50 ether
- Minimum amount of contributors: 3
- Minimum amount of contributors: 15

3. Use other accounts to send money to the ICOPool. Just send ether to the ICOPool and the fallback function will get executed. For the ICOPool we configured above, at least 3 accounts should send 5 ether each to meet the minimum number of contributors and soft cap requirements.

4. Once the minimum requirements are met (money and number of contributors), the admin may execute the buyTokensFromICO() function. This function will forward the contract's ether to the ICO which should then issue the tokens to the ICOPool contract. After this function is called, you may call balanceOf(-ICOPool's address-) on the token to see how many tokens were bought with the balance the pool had. 

5. Once you've checked that the ICOPool has the tokens, each of the accounts that made a contribution can call the withdrawTokens(address _tokenAddress) function to get their tokens.
Using one of the accounts that contributed ether to the ICOPool, execute this function. If everything goes well, you may use token's balanceOf() to check the contributor's token balance.
