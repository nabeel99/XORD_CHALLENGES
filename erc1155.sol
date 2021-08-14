pragma solidity^0.8.6;
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";

// interface ERC165 {
//     /// @notice Query if a contract implements an interface
//     /// @param interfaceID The interface identifier, as specified in ERC-165
//     /// @dev Interface identification is specified in ERC-165. This function
//     ///  uses less than 30,000 gas.
//     /// @return `true` if the contract implements `interfaceID` and
//     ///  `interfaceID` is not 0xffffffff, `false` otherwise
//     function supportsInterface(bytes4 interfaceID) external view returns (bool);
// }

contract task4 is IERC1155{
    
    mapping(uint => mapping(address => uint)) 
    private _balance;
    mapping (address => mapping(address => bool))
    private authorizedAll;
    
    
    
    
    
    
    
    function balanceOf(address account, uint256 id) 
    public override view
    returns(uint256) {
        return _balance[id][account];
    }
    
    function balanceOfBatch(address[] memory accounts,uint256[] memory ids)
    public override view
    returns(uint256[] memory) {
        require(accounts.length==ids.length,
        "size mismatch between id and accounts");
        uint256[] memory  balances;
        for(uint256 i = 0; i<accounts.length;i++) 
        {
         balances[i] = balanceOf(accounts[i],ids[i]);
        }
        return balances;
    }
    function setApprovalForAll(address operator, bool approved)
    public override {
        address send = msg.sender;
        require(send!=operator);
        authorizedAll[send][operator] = approved;
         emit ApprovalForAll(send, operator, approved);
    }
    function isApprovedForAll(address account, address operator) 
    public override view
    returns(bool) {
      
        return authorizedAll[account][operator];
        
    }
    
    function safeTransferFrom(address from, address to,
    uint256 id, uint256 amount, bytes calldata data)
    public override {
        require(to!=address(0));
        require(from==msg.sender||
        authorizedAll[from][msg.sender]);
        require(balanceOf(from,id)>=amount);
      
        
        
        _balance[id][from] -= amount;
        _balance[id][to] += amount;
        
          if(isContract(to)) {
            IERC1155Receiver receiver = IERC1155Receiver(to);
            require(receiver.onERC1155Received(msg.sender, from, id, amount, data)==
            bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)")));    
        }
        
        emit TransferSingle(msg.sender, from, to, id, amount);
        
    }
    
    function safeBatchTransferFrom(address from, address to, 
    uint256[] memory ids, uint256[] memory amounts, 
    bytes calldata data)
    public override {
         require(amounts.length==ids.length,
        "size mismatch between id and accounts");
        require(from==msg.sender|| isApprovedForAll(from,msg.sender));
        require(to!=address(0));
         
        for(uint i=0; i<amounts.length;i++){
            
           uint256 id = ids[i];
            uint256 amount = amounts[i];
            uint256 fromBalance = _balance[id][from];
            require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
            _balance[id][from] = fromBalance -amount;
            _balance[id][to] +=amount;
        }
       
        emit TransferBatch(msg.sender, from, to, ids, amounts);
         if(isContract(to)) {
            IERC1155Receiver receiver = IERC1155Receiver(to);
            require(receiver.onERC1155BatchReceived(msg.sender, from, ids, amounts, data)==
            bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)")));
        }
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
    function supportsInterface(bytes4 interfaceID) 
     public pure override 
    returns (bool) {
        return (interfaceID==0x01ffc9a7);
    }
}