pragma solidity 0.4.18;

import "./SafeMath.sol";

contract ERC20 {
    function balanceOf(address _owner) constant returns (uint balance);
    function transfer(address _to, uint _value) returns (bool success);
}

contract ICOPool {
    using SafeMath for uint256;

    // The ICO this pool will transfer the eth to in order to buy tokens
    address public targetICO;

    // The account that created the pool
    address public poolAdmin;

    // The balance in wei the pool currently manages
    uint public poolBalance;

    // The balance in wei each pool contributor has transferred
    mapping (address => uint) public contributorsBalance;
    uint public amountOfContributors = 0;

    // The minimum wei a contributor has to send to participate in the pool
    uint public minContribution;

    // The maximum wei a contributor can send to participate in the pool
    uint public maxContribution;

    // The minimum poolBalance the pool must have in order to be able to buy the tokens from the targetICO
    uint public poolSoftCap;

    // The maximum poolBalance the pool can have. Contributions beyond this amount won't be accepted
    uint public poolHardCap;

    // Minimum amount of contributors the pool needs
    uint public contributorsSoftCap;
    // Maximum amount of contributors the pool can have
    uint public contributorsHardCap;

    bool investedInICO = false;

    uint tokensWithdrawn = 0;
    mapping (address => uint) public tokensWithdrawnByContributor;

    function ICOPool(address _targetICO,
                    uint _minContribution,
                    uint _maxContribution,
                    uint _poolSoftCap,
                    uint _poolHardCap,
                    uint _contributorsSoftCap,
                    uint _contributorsHardCap
                    ) public {

        require (_targetICO != address(0));
        require (_minContribution > 0);
        require (_maxContribution > _minContribution);
        require (_poolHardCap > _poolSoftCap);
        require (_contributorsHardCap >= _contributorsSoftCap);

        // Max people * their minimum contribution should be able to meet pool softcap
        // For example, we can't allow having the max contributors (10 people) put $100 each when the softcap is $1500.
        require(_contributorsHardCap * _minContribution >= _poolSoftCap);
        // Min people * their maximum contribution should be within pool hardcap
        // For example, we can't allow 3 people to reach the hardcap if the minimum contributors is 5
        require(_contributorsSoftCap * _maxContribution <= _poolHardCap);

        targetICO = _targetICO;
        poolAdmin = msg.sender;
        minContribution = _minContribution;
        maxContribution = _maxContribution;

        poolSoftCap = _poolSoftCap;
        poolHardCap = _poolHardCap;

        contributorsSoftCap = _contributorsSoftCap;
        contributorsHardCap = _contributorsHardCap;
    }

    function contributeToPool() payable public {
        require(msg.value > 0);
        require(msg.value >= minContribution && msg.value <= maxContribution); // Must send eth within min and max contributions
        require(contributorsBalance[msg.sender].add(msg.value) <= maxContribution); // msg.sender's balance can't exceed max contribution limit

        // Pool can't exceed hard cap
        require(poolBalance.add(msg.value) <= poolHardCap);

        //Register how much eth the pool has
        poolBalance = poolBalance.add(msg.value);

        //If it is the first time this account contributes, increase num. of contributors
        if (contributorsBalance[msg.sender] == 0){
            amountOfContributors++;
        }
        // Pool can't exceed contributors hard cap
        require(amountOfContributors <= contributorsHardCap);

        //Register how much eth has each contributor put into the pool
        contributorsBalance[msg.sender] = contributorsBalance[msg.sender].add(msg.value);
    }

    function buyTokensFromICO() public {
        require(!investedInICO);
        require(poolBalance >= poolSoftCap);
        require(amountOfContributors >= contributorsSoftCap);
        require(this.balance >= poolBalance);

        //Can be called only by the pool admin to avoid timing problems
        // We'll need to trust the admin to execute this at the right moment
        // Could be changed to allow any contributor to call it.
        require(msg.sender == poolAdmin);

        investedInICO = true;

        // BE CAREFUL, OPENING RE-ENTRANCY DOOR
        require(targetICO.call.value(poolBalance)());

        // **************
        //If you are hesitant about using call() you can instead instantiate
        //the target ICO and directly use whatever function it has to buy tokens
        // ------
        //Crowdsale c = Crowdsale(targetICO);
        //c.buyTokens.value(poolBalance)();
        // **************
    }

    /// @dev this function transfers the tokens from the pool to the corresponding contributors
    /// Each contributor is responsible of calling this function to withdraw their tokens
    /// @param _tokenAddress The address of the tokens bought (not to be confused with the ICO address)
    function withdrawTokens(address _tokenAddress) public {
        require(contributorsBalance[msg.sender] > 0);

        ERC20 token = ERC20(_tokenAddress);
        require (token.balanceOf(this) > 0);

        // tokenBalance is always the max tokens the pool bought (balanceOf + already withdrawn)
        uint tokenBalance = token.balanceOf(this).add(tokensWithdrawn);

        // Get contributor share based on his contribution vs total pool
        // poolBalance (total wei pooled) -> contributorsBalance[msg.sender] (wei put by msg.sender)
        // tokenBalance (total tokens bought with poolBalance) -> tokensToWithdraw (how many tokens corresponds to msg.sender)
        uint tokensToWithdraw = tokenBalance.mul(contributorsBalance[msg.sender]).div(poolBalance);
        tokensToWithdraw = tokensToWithdraw.sub(tokensWithdrawnByContributor[msg.sender]);

        require(tokensToWithdraw > 0);

        // Keep track of tokens already withdrawn
        tokensWithdrawn = tokensWithdrawn.add(tokensToWithdraw);
        tokensWithdrawnByContributor[msg.sender] = tokensWithdrawnByContributor[msg.sender].add(tokensToWithdraw);

        // Transfer calculated tokens to msg.sender
        require(token.transfer(msg.sender,tokensToWithdraw));
    }

    function withdrawEther() public {
        require(!investedInICO);
        require(contributorsBalance[msg.sender] > 0);

        uint ethToWithdraw = contributorsBalance[msg.sender];
        contributorsBalance[msg.sender] = 0;

        //Remove contribution from poolBalance
        poolBalance = poolBalance.sub(ethToWithdraw);
        amountOfContributors--;

        msg.sender.transfer(ethToWithdraw);

    }
}
