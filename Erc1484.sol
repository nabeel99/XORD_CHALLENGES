pragma solidity ^0.8.0;
import "./Address-set.sol";
import "hardhat/console.sol";
interface IdentityRegistryInterface {
    function isSigned(address _address, bytes32 messageHash, uint8 v, bytes32 r, bytes32 s)
        external pure returns (bool);

    // Identity View Functions /////////////////////////////////////////////////////////////////////////////////////////
    function identityExists(uint ein) external view returns (bool);
    function hasIdentity(address _address) external view returns (bool);
    function getEIN(address _address) external view returns (uint ein);
    function isAssociatedAddressFor(uint ein, address _address) external view returns (bool);
    function isProviderFor(uint ein, address provider) external view returns (bool);
    function isResolverFor(uint ein, address resolver) external view returns (bool);
    function getIdentity(uint ein) external view returns (
        address recoveryAddress,
        address[] memory associatedAddresses, address[] memory providers, address[] memory resolvers
    );

    // Identity Management Functions ///////////////////////////////////////////////////////////////////////////////////
    function createIdentity(address recoveryAddress, address[] calldata providers, address[] calldata resolvers)
        external returns (uint ein);
    function createIdentityDelegated(
        address recoveryAddress, address associatedAddress, address[] calldata providers, address[] calldata resolvers,
        uint8 v, bytes32 r, bytes32 s, uint timestamp
    ) external returns (uint ein);
    function addAssociatedAddress(
        address approvingAddress, address addressToAdd, uint8 v, bytes32 r, bytes32 s, uint timestamp
    ) external;
    function addAssociatedAddressDelegated(
        address approvingAddress, address addressToAdd,
        uint8[2] calldata v, bytes32[2] calldata r, bytes32[2] calldata s, uint[2] calldata timestamp
    ) external;
    function removeAssociatedAddress() external;
    function removeAssociatedAddressDelegated(address addressToRemove, uint8 v, bytes32 r, bytes32 s, uint timestamp)
        external;
    function addProviders(address[] calldata providers) external;
    function addProvidersFor(uint ein, address[] calldata providers) external;
    function removeProviders(address[] calldata providers) external;
    function removeProvidersFor(uint ein, address[] calldata providers) external;
    function addResolvers(address[] calldata resolvers) external;
    function addResolversFor(uint ein, address[] calldata resolvers) external;
    function removeResolvers(address[] calldata resolvers) external;
    function removeResolversFor(uint ein, address[] calldata resolvers) external;

    // Recovery Management Functions ///////////////////////////////////////////////////////////////////////////////////
    function triggerRecoveryAddressChange(address newRecoveryAddress) external;
    function triggerRecoveryAddressChangeFor(uint ein, address newRecoveryAddress) external;
    function triggerRecovery(uint ein, address newAssociatedAddress, uint8 v, bytes32 r, bytes32 s, uint timestamp)
        external;
    function triggerDestruction(
        uint ein, address[] calldata firstChunk, address[] calldata lastChunk, bool resetResolvers
    ) external;

    // Events //////////////////////////////////////////////////////////////////////////////////////////////////////////
    event IdentityCreated(
        address indexed initiator, uint indexed ein,
        address recoveryAddress, address associatedAddress, address[] providers, address[] resolvers, bool delegated
    );
    event AssociatedAddressAdded(
        address indexed initiator, uint indexed ein, address approvingAddress, address addedAddress
    );
    event AssociatedAddressRemoved(address indexed initiator, uint indexed ein, address removedAddress);
    event ProviderAdded(address indexed initiator, uint indexed ein, address provider, bool delegated);
    event ProviderRemoved(address indexed initiator, uint indexed ein, address provider, bool delegated);
    event ResolverAdded(address indexed initiator, uint indexed ein, address resolvers);
    event ResolverRemoved(address indexed initiator, uint indexed ein, address resolvers);
    event RecoveryAddressChangeTriggered(
        address indexed initiator, uint indexed ein, address oldRecoveryAddress, address newRecoveryAddress
    );
    event RecoveryTriggered(
        address indexed initiator, uint indexed ein, address[] oldAssociatedAddresses, address newAssociatedAddress
    );
    event IdentityDestroyed(address indexed initiator, uint indexed ein, address recoveryAddress, bool resolversReset);
}


contract erc1484 is IdentityRegistryInterface{
    using AddressSet for AddressSet.Set;

    struct Identity{ 
        address recoveryAddress;
        AddressSet.Set associatedAddress;
        AddressSet.Set provider;
        AddressSet.Set resolvers;
    }
    mapping(uint => Identity) einToIdentity;
    mapping(address => uint) addressToIdentity;
        uint public einCount = 1;
        uint maxAssociatedAdresses = 20;
        uint timeout = 1 days;
modifier signatureTimeout(uint timestamp)  {
    // require(block.timestamp>=timestamp && block.timestamp<timestamp+timeout);
     _;
}
    
    function identityExists(uint ein) 
    public view override
    returns(bool) {
      //  console.log("recieved ein in identityexists is " , ein);
      //  console.log("ein count in identityexists is " , einCount);
        return (ein<einCount && ein>=1);
    }
    function hasIdentity(address _address)
    public view override
    returns(bool) {
      //  console.log('address ein in hasidentity is ', addressToIdentity[_address]);
        //console.log("address is ", _address);
        return identityExists(addressToIdentity[_address]);

    }
    function getEIN(address _address)
    public view override
    returns (uint ein) {
        require(hasIdentity(_address),"Address has no identity associated with it");
        return addressToIdentity[_address];
    }

    function isAssociatedAddressFor(uint ein,
     address _address)
    public view override
    returns(bool) {
        require(addressToIdentity[_address]==ein,"This address is not associated with this ein");
        return true;
    }
    function isProviderFor(uint ein, address provider)
    public view override
    returns(bool) {

        require(einToIdentity[ein].provider.contains(provider),"it is not provider for the ein passed");
        return true;
    }
    function isResolverFor(uint ein,address resolver)
    public view override
    returns(bool) {
         require(einToIdentity[ein].resolvers.contains(resolver),"it is not resolver for the ein passed");
        return true;
    }
    function getIdentity(uint ein) 
    public view override
    returns(address ,address[] memory,address[] memory, address[] memory ) {
        Identity storage temp = einToIdentity[ein];
        return(temp.recoveryAddress, temp.associatedAddress.members, temp.provider.members, temp.resolvers.members);
    }
    function createIdentity(address recoveryAddress, 
    address[] memory providers, 
    address[] memory resolvers)
    public override
    returns(uint) {
      //  console.log("return value is ",_createIdentity(recoveryAddress,msg.sender,providers,resolvers,false));
       return _createIdentity(recoveryAddress,msg.sender,providers,resolvers,false);
       


    }
     function _createIdentity(address recoveryAddress, address associatedAddress, 
    address[] memory providers, 
    address[] memory resolvers,bool delegated)
    internal
    returns(uint) {
         uint ein = einCount;
         einCount++;
        // console.log("ein count in identity is ",einCount);
         
        einToIdentity[ein].recoveryAddress = recoveryAddress;
        einToIdentity[ein].associatedAddress.insert(associatedAddress);
      //  console.log("address in identity is",associatedAddress);
        addressToIdentity[associatedAddress] = ein;
        addProviders(providers);
        addResolvers(resolvers);
        emit IdentityCreated(associatedAddress,ein,recoveryAddress,associatedAddress,providers,resolvers,delegated);
        return ein;

    }
   
    function createIdentityDelegated(
    address recoveryAddress, address associatedAddress, 
    address[] memory providers, address[] memory resolvers,
    uint8 v, bytes32 r, bytes32 s, uint timestamp) 
    public override signatureTimeout(timestamp)
    returns (uint ein) {
     //   console.log("before hereeeee");
        require(
            isSigned(associatedAddress, 
            keccak256("I authorize creation of this Identity")
            , v, r, s)
            ,"Permission denited"
        );
       // console.log("after");
        return _createIdentity(recoveryAddress, associatedAddress,providers, resolvers, true);
    }
    function addAssociatedAddress(
    address approvingAddress, address addressToAdd,
     uint8 v, bytes32 r, bytes32 s, 
     uint timestamp)
     public override signatureTimeout(timestamp) {
     //   console.log("start");
         if(msg.sender==approvingAddress) {
       //      console.log("here");

             require(
            isSigned(addressToAdd, 
            keccak256("I authorize creation of this Identity")
            , v, r, s)
            ,"Permission denited"
        );
    //    console.log(approvingAddress);
            einToIdentity[getEIN(approvingAddress)].associatedAddress.insert(addressToAdd);
            addressToIdentity[addressToAdd] = getEIN(approvingAddress);
         } else if(msg.sender==addressToAdd) {
             
               require(
            isSigned(approvingAddress, 
            keccak256("I authorize creation of this Identity")
            , v, r, s)
            ,"Permission denited"
        );
            einToIdentity[getEIN(approvingAddress)].associatedAddress.insert(addressToAdd);
            addressToIdentity[addressToAdd] = getEIN(approvingAddress);
         }
         emit AssociatedAddressAdded(msg.sender,
         getEIN(approvingAddress),approvingAddress,addressToAdd);
    }


    function addAssociatedAddressDelegated(
    address approvingAddress, address addressToAdd,
    uint8[2] memory v, bytes32[2] memory r, bytes32[2] memory s, 
    uint[2] memory timestamp
)
    public override signatureTimeout(timestamp[0]) signatureTimeout(timestamp[1]) {

        require(isSigned(approvingAddress, 
            keccak256(("I authorize creation of this Identity"))
            , v[0], r[0], s[0]),"Permission denied");
         require(isSigned(addressToAdd, 
            keccak256(("I authorize creation of this Identity"))
            , v[1], r[1], s[1]),"Permission denied2");
        einToIdentity[getEIN(approvingAddress)].associatedAddress.insert(addressToAdd);
        addressToIdentity[addressToAdd] = getEIN(approvingAddress);

        emit AssociatedAddressAdded(msg.sender,
         getEIN(approvingAddress),approvingAddress,addressToAdd);
    }

    function removeAssociatedAddress() 
    public override {

        einToIdentity[addressToIdentity[msg.sender]].associatedAddress.remove(msg.sender);
        delete addressToIdentity[msg.sender];
        emit AssociatedAddressRemoved(msg.sender, addressToIdentity[msg.sender],msg.sender);
    }
    function removeAssociatedAddressDelegated(address addressToRemove, uint8 v, bytes32 r, bytes32 s, uint timestamp)
    public  override signatureTimeout(timestamp) {
        require(isSigned(addressToRemove, 
            keccak256((abi.encodePacked("I authorize creation of this Identity",timestamp)))
            , v, r, s),"Permission denied");
        einToIdentity[addressToIdentity[addressToRemove]].associatedAddress.remove(addressToRemove);
        delete addressToIdentity[addressToRemove];
        emit AssociatedAddressRemoved(msg.sender, addressToIdentity[addressToRemove],addressToRemove);
    }




     function addProviders(address[] memory providers) 
    public override {
        uint f =getEIN(msg.sender);
        Identity storage temp = einToIdentity[f];
        for(uint i = 0;i<providers.length;i++) {
            temp.provider.insert(providers[i]);
            emit ProviderAdded(msg.sender, f, providers[i], false);
        }   
       
    }
    function addProvidersFor(uint ein, address[] memory providers) 
    public override {
        Identity storage temp = einToIdentity[ein];
        for(uint i = 0;i<providers.length;i++) {
            temp.provider.insert(providers[i]);
            emit ProviderAdded(msg.sender, ein, providers[i], true);

        }   

    }

    function removeProviders(address[] memory providers) 
    public override {
        uint f =getEIN(msg.sender);
        Identity storage temp = einToIdentity[f];
        for(uint i = 0;i<providers.length;i++) {
            temp.provider.remove(providers[i]);
            emit ProviderRemoved(msg.sender, f, providers[i], false);
        }   
        
    }
    function removeProvidersFor(uint ein, address[] memory providers) 
    public override {
        Identity storage temp = einToIdentity[ein];
        for(uint i = 0;i<providers.length;i++) {
            temp.provider.remove(providers[i]);
            emit ProviderRemoved(msg.sender, ein, providers[i], true);
        }   
        
    }
     function addResolvers(address[] memory resolvers) 
    public override {
        uint f =getEIN(msg.sender);
        Identity storage temp = einToIdentity[f];
        for(uint i = 0;i<resolvers.length;i++) {
            temp.resolvers.insert(resolvers[i]);
            emit ResolverAdded(msg.sender, f, resolvers[i]);
        }   
        
    }
     function addResolversFor(uint ein, address[] memory resolvers) 
    public override {
        Identity storage temp = einToIdentity[ein];
        for(uint i = 0;i<resolvers.length;i++) {
            temp.resolvers.insert(resolvers[i]);
             emit ResolverAdded(msg.sender, ein, resolvers[i]);
        }   
       
    }
    function removeResolvers(address[] memory resolvers) 
    public override {
        uint f =getEIN(msg.sender);
        Identity storage temp = einToIdentity[f];
        for(uint i = 0;i<resolvers.length;i++) {
            temp.resolvers.remove(resolvers[i]);
        
        emit ResolverRemoved(msg.sender, f, resolvers[i]);
        }
    }
      function removeResolversFor(uint ein, address[] memory resolvers) 
    public override {
        Identity storage temp = einToIdentity[ein];
        for(uint i = 0;i<resolvers.length;i++) {
            temp.resolvers.remove(resolvers[i]);
        
        emit ResolverRemoved(msg.sender, ein, resolvers[i]);
        }
    }
    function triggerRecoveryAddressChange(address newRecoveryAddress) 
    public override {
        address tempold =  einToIdentity[addressToIdentity[msg.sender]].recoveryAddress;
        einToIdentity[addressToIdentity[msg.sender]].recoveryAddress = newRecoveryAddress;
        emit RecoveryAddressChangeTriggered(msg.sender, addressToIdentity[msg.sender], tempold, newRecoveryAddress);
    }
      function triggerRecoveryAddressChangeFor(uint ein,address newRecoveryAddress) 
    public override {
        address tempold =  einToIdentity[ein].recoveryAddress;
        einToIdentity[ein].recoveryAddress = newRecoveryAddress;
        emit RecoveryAddressChangeTriggered(msg.sender, ein, tempold, newRecoveryAddress);
    }
    function triggerRecovery(uint ein, 
    address newAssociatedAddress, uint8 v, bytes32 r, bytes32 s, 
    uint timestamp) 
    public override signatureTimeout(timestamp) {
        require(isSigned(newAssociatedAddress, 
            keccak256("I authorize creation of this Identity")
            , v, r, s),"Permission denied");
            Identity storage temp = einToIdentity[ein];
            address[] memory old;
              if(timestamp+ 2 weeks < block.timestamp){   

                  old = einToIdentity[ein].associatedAddress.members;
                  for(uint i = 0;i<old.length;i++){

                      delete addressToIdentity[temp.associatedAddress.members[i]];
                  }
                  delete temp.associatedAddress;
                  delete temp.provider;
           
              } 

        einToIdentity[ein].associatedAddress.insert(newAssociatedAddress);
        addressToIdentity[newAssociatedAddress] = ein;
        emit RecoveryTriggered(msg.sender, ein, old, newAssociatedAddress);
    }

       function triggerDestruction(uint ein, address[] memory firstChunk, address[] memory lastChunk, bool clearResolvers) override public{
        Identity storage _identity = einToIdentity[ein];

        address[1] memory middleChunk = [msg.sender];
        require(
            keccak256(
                abi.encodePacked(firstChunk, middleChunk, lastChunk)
            ) == keccak256(abi.encodePacked(_identity.associatedAddress.members)),
            "Cannot destroy an EIN from an address that was not recently removed from said EIN via recovery."
        );

        for(uint i = 0; i<_identity.associatedAddress.length();i++){
            delete addressToIdentity[_identity.associatedAddress.members[i]];        
        }
        delete _identity.associatedAddress;
        delete _identity.provider;
        if (clearResolvers) delete _identity.resolvers;
        emit IdentityDestroyed(msg.sender, ein, _identity.recoveryAddress, clearResolvers);
        _identity.recoveryAddress = address(0);

    }

      function isSigned(address _address, bytes32 messageHash, uint8 v, bytes32 r, bytes32 s)
       public pure override 
       returns (bool) {
        return _isSigned(_address, messageHash, v, r, s) || _isSignedPrefixed(_address, messageHash, v, r, s);
    }

   
    function _isSigned(address _address, bytes32 messageHash, uint8 v, bytes32 r, bytes32 s)
        internal pure returns (bool)
    {
        return ecrecover(messageHash, v, r, s) == _address;
    }

    function _isSignedPrefixed(address _address, bytes32 messageHash, uint8 v, bytes32 r, bytes32 s)
        internal pure returns (bool)
    {
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        return _isSigned(_address, keccak256(abi.encodePacked(prefix, messageHash)), v, r, s);
    }


}
