pragma solidity >=0.7.0 <0.9.0;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Challenge3 is Ownable {
    using SafeMath for uint;
    uint taskCount = 0;
   struct Todo{
       string taskName;
       uint id;
       bool isActive;
       
   } 
    mapping(uint => Todo) public Tasks;
    
    function addTask(string memory _name) public onlyOwner {
        Tasks[taskCount] = Todo(_name,taskCount,true);
        taskCount = taskCount++;
        
    
    }
    
    
    
}