pragma solidity ^0.8.10;


// SPDX-License-Identifier: UNLICENSED
interface ERC20Interface {
    function totalSupply() external view returns (uint) ;
    function balanceOf(address tokenOwnwer) external view returns (uint balance);
    function transfer(address to, uint tokens) external returns (bool success);
    
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferfrom(address from, address to, uint tokens) external returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract CrypArt is ERC20Interface{
    string public name = "CrypArt";
    string public symbol = "CAT";
    uint public decimals = 0;

    uint public supply;
    address public founder;

    mapping(address => uint) public balances;

    mapping(address => mapping(address => uint)) public allowed;

    constructor() {
        supply = 300000000000000000000000; // 300K Eth
        founder = msg.sender;
        balances[founder] = supply;
    }

    function totalSupply() public override view returns (uint){
        return supply;
    }

    function balanceOf(address tokenOwner) public override view returns (uint balance){
        return balances[tokenOwner];
    }

    function transfer(address to, uint tokens) public override returns (bool success){
        require(balances[msg.sender] >= tokens && tokens > 0);

        balances[to] += tokens;
        balances[msg.sender] -= tokens;
        emit Transfer(msg.sender, to, tokens);
        return true;
    }

    function allowance(address tokenOwner, address spender) public override view returns (uint remaining){
        return allowed[tokenOwner][spender];
    }

    function approve(address spender, uint tokens) public override returns (bool success){
        require(balances[msg.sender] >= tokens);
        require(tokens > 0);
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    function transferfrom(address from, address to, uint tokens) public override returns (bool success){
        require(allowed[from][to] >= tokens);
        require(balances[from] >= 0);

        balances[from] -= tokens;
        balances[to] += tokens;
        allowed[from][to] -= tokens;
        return true;
    }

}