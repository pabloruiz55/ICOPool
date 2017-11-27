pragma solidity 0.4.18;

import "./SafeMath.sol";

contract Crowdsale {
    using SafeMath for uint256;

    ERC20Basic public token;

    function Crowdsale() public {
        token = new ERC20Basic();
    }

    function() payable public {
        buyTokens();
    }

    function buyTokens() public payable {
        require(msg.value > 0);

        uint tokensBought = msg.value;
        require(token.transfer(msg.sender, tokensBought));
    }

    function getBalance() view public returns(uint){
        return this.balance;
    }
}

contract ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;
  string public constant name = "Pool Token";
  string public constant symbol = "POOL";
  uint8 public constant decimals = 18;
  uint256 public totalSupply;

  event Transfer(address indexed from, address indexed to, uint256 value);

  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

  function ERC20Basic() public {
    totalSupply = 100000 * 10 ** uint(decimals);
    balances[msg.sender] = totalSupply;
  }
}
