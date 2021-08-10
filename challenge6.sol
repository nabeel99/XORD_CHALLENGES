pragma solidity=0.8.5;
import "@openzeppelin/contracts/access/Ownable.sol";

contract Challenge6 is Ownable{
    

    function hashAddress(address  c,address d)public pure returns(bytes32){
        
    
     if(c>d)
     {
        
         return keccak256(abi.encodePacked(c,d));
     } else{
         return keccak256(abi.encodePacked(d,c));
     }
    }
     
}
