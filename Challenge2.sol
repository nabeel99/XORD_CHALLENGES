pragma solidity >=0.7.0 <0.9.0;
import "./SafeMath.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
contract Challenge2 is Ownable {
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
    function changePersonName(uint _id,string memory _name) public {
        
        Person[_id].name = _name;
    }
    function changeAge(uint _id) public onlyOwner {
        Person[_id].age = Person[_id].age.add(1);
        
    }
}