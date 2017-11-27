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

Now, the contributors can 

How to set it up

How to use it

Examples
