pragma solidity =0.8.6;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
contract Challenge1 {
    using SafeMath for uint256;
    
    uint256 id = 0;
    struct personDetails{
        string name;
        uint256 age;
    }
    
    mapping(uint256 => personDetails) public Person;
    
    function newPerson(string memory name,
    uint256 age
    ) 
    external
    {   
        Person[id] = personDetails(name,age);
        id = id.add(1);
        
        
        
    }
    function retrievePerson(uint256 personID)
    public 
    view 
    returns
    (personDetails memory) {
        personDetails memory p = Person[personID];
        return p;
        
    }
    
}