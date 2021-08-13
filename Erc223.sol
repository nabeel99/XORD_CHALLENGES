pragma solidity 0.8.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IERC223 {
    function transfer(address _to, uint _value, bytes memory _data) external;
    event Transfer(address indexed from, address indexed to, uint value, bytes indexed data);
}
interface IERC223Recipient { 
    function tokenFallback(address _from, uint _value, bytes memory _data) external;
}


  contract Task3 is IERC20,IERC223 {
    uint256 private _totalTokens;
    address private _contractOwner;
    
    
    constructor(){
        
        _contractOwner = msg.sender;
    }
    
    mapping(address => uint256) private _balance;
    mapping(address => mapping(address => uint256) ) 
    private _approved;
    function totalSupply() 
    override public view
    returns(uint256)
    {
        return(_totalTokens);
    } 
    
    function balanceOf(address _owner)
    public view override returns
    (uint256) 
    {
        return _balance[_owner];
    }
    
    function transfer(address _to, uint256 _value) 
    public override
    returns (bool success)
    {
        require(balanceOf(msg.sender)>=_value,
        "Insufficient Balance");
        require(_to!=address(0));
        _balance[msg.sender] -= _value;
        _balance[_to] += _value;
        emit Transfer(msg.sender,_to,_value);
        return true;
        
    }
    
    function transferFrom(address _from,
    address _to,
    uint256 _value)
    public override 
    returns (bool success) 
    {
     require(balanceOf(_from)>=_value,
        "Insufficient Balance");
        require(allowance(_from,_to)>=_value,"not allowed");
        require(_to!=address(0),"please dont burn using this method");
         _balance[_from] -= _value;
        _balance[_to] += _value;
        emit Transfer(_from,_to,_value);
        return true;
        
    }
    
    function approve(address _spender, uint256 _value) 
    public override 
    returns (bool success)
    {
        require(balanceOf(msg.sender)>=_value,
        "Insufficient Balance");
        require(_spender!=address(0));
        _approved[msg.sender][_spender]= _value;
        emit Approval(msg.sender,_spender,_value);
        return true;
    }
    
    function allowance(address owner, address _spender) 
    public override view 
    returns (uint256 remaining)
    {
        return _approved[owner][_spender];
    }
    function _mint(address account, uint256 amount) public
    {
        require(account!=address(0));
        _totalTokens +=amount;
        _balance[account] += amount;
        emit Transfer(address(0),account,amount);
    } 
    
    function transfer(address _to, uint _value, bytes memory _data) 
    public override
    {
        address  send = msg.sender;
        require(_value>=0);
         require(balanceOf(send)>=_value,
        "Insufficient Balance");
        require(_to!=address(0));
        if(isContract(_to))
        {
        IERC223Recipient receiver = IERC223Recipient(_to);
        receiver.tokenFallback(send,_value,_data);
        }
        _balance[send] -= _value;
        _balance[_to] += _value;
        emit Transfer(send,_to,_value,_data);
    }
       function isContract(address _addr) 
       private view
       returns(bool)
    {
        uint length;
        assembly {
            length := extcodesize(_addr)
        }
        return (length>0);
        
    }


        
 }
    
 
