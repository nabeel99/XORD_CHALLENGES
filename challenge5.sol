pragma solidity=0.8.5;
import "@openzeppelin/contracts/access/Ownable.sol";

contract Challenge5 is Ownable{
 
    uint totalAccounts = 0;
    uint time = block.timestamp;
    
    struct Character{
        string name;
        uint level;
    }
    mapping(uint => Character) public Account;
    
    function createCharacter(string memory _charName) public {
        
        Account[totalAccounts] = Character(_charName,0);
        totalAccounts++;
        
    }
    function levelUp(uint _id) public payable{
        // address ow = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
        // ow.call{value:1 ether}("");
        require(msg.value==1 ether);
        Account[_id].level++;
    }
    
    function withdraw() public onlyOwner until(block.timestamp){
        
      (bool sent,) =  payable(owner()).call{value: address(this).balance}("");
      require(sent==true,"Transaction Failed");
    }
    modifier until(uint a) {
        require(a>(time + 1 seconds));
        _;
    }
    
    
    
}
