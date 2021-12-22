pragma solidity ^0.8.10;


// SPDX-License-Identifier: UNLICENSED
interface ERC20Interface {
    function totalSupply() external view returns (uint) ;
    function balanceOf(address tokenOwnwer) external view returns (uint balance);
    function transfer(address to, uint tokens) external returns (bool success);
    
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);

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

    function transfer(address to, uint tokens) public virtual override returns (bool success){
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

    function transferFrom(address from, address to, uint tokens) public virtual override returns (bool success){
        require(allowed[from][to] >= tokens);
        require(balances[from] >= 0);

        balances[from] -= tokens;
        balances[to] += tokens;
        allowed[from][to] -= tokens;
        return true;
    }

}

contract CrypArtICO is CrypArt{
    address public admin;

    address payable public deposit;
    
    //token price in wei: 1CAT = 0.001 ETHER, 1 ETHER = 1000 CAT
    uint tokenPrice = 1000000000000000;//0.001 Ether
   
    uint public hardCap = 300000000000000000000;//300 Ether

    uint public raisedAmount;
    uint public saleStart = block.timestamp;
    uint public saleEnd = block.timestamp + 604800; //one week
    uint public coinTradeStart = saleEnd + 604800; //transferable in a week after salesEnd
    
    uint public maxInvestment = 5000000000000000000;//5 Ether
    uint public minInvestment = 10000000000000000;//0.01 Ether
   
    enum State { beforeStart, running, afterEnd, halted}
    State public icoState;

    modifier onlyAdmin{
        require(msg.sender == admin);
        _;
    }

    event Invest(address investor, uint value, uint tokens);

    constructor(address payable _deposit) {
        deposit = _deposit;
        admin = msg.sender;
        icoState = State.beforeStart;
    }

    //emergency stop
    function halt() public onlyAdmin{
        icoState = State.halted;
    }

    //restart 
    function unhalt() public onlyAdmin{
        icoState = State.running;
    }

    function changeDepositAddress(address payable newDeposit) public onlyAdmin{
        deposit = newDeposit;
    }

    function getCurrentState() public view returns(State){
        if(icoState == State.halted){
            return State.halted;
        }else if(block.timestamp < saleStart){
            return State.beforeStart;
        }else if(block.timestamp >= saleStart && block.timestamp <= saleEnd){
            return State.running;
        }else{
            return State.afterEnd;
        }
    }

    function invest() payable public returns(bool){
        icoState = getCurrentState();
        require(icoState == State.running);
        require(msg.value >= minInvestment && msg.value <= maxInvestment);
        uint tokens = msg.value / tokenPrice;
        
        
        //hardCap not reached
        require(raisedAmount + msg.value <= hardCap);
        raisedAmount += msg.value;
        
        balances[msg.sender] += tokens;
        balances[founder] -= tokens;
        
        deposit.transfer(msg.value);//transfer eth to the deposit address
        emit Invest(msg.sender, msg.value, tokens);
        
        return true;
    }

    fallback () payable external {
        invest();
    }

    receive() external payable {
        
    }

    function burn() public returns(bool){
        icoState = getCurrentState();
        require(icoState == State.afterEnd);
        balances[founder] = 0;   
        return true;
    }

    function transfer(address to, uint value) public override returns(bool){
        require(block.timestamp > coinTradeStart);
        super.transfer(to, value);
        return true;
    }

    function transferFrom(address _from, address _to, uint _value) public override returns(bool){
        require(block.timestamp > coinTradeStart);
        super.transferFrom(_from, _to, _value);
        return true;
    }
}