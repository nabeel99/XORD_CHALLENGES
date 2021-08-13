pragma solidity^0.8.6;


import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

     contract Task2 is IERC721
     {
         
         
      using Address for address;
      mapping(uint => address) private tokenToOwner;
      mapping(address => uint) private nTokens;
      mapping (uint => address) private authorised;
      mapping(address => mapping(address => bool)) private ownerToOperator;
       uint256 totalTokens;
      ///verifyNFT check if tokenId<lOfTokens.length and >0
      
            function totalNFT() 
            public view
            returns (uint)
            {
                return totalTokens;
            }
          function balanceOf(address _owner) 
          public view override
          returns (uint256)
          {
              require(_owner!=(address(0)));
              return nTokens[_owner];
          }
           function ownerOf(uint256 _tokenId) 
           public view  override 
           returns (address)
           {
             require(tokenToOwner[_tokenId]!=address(0),"Invalid NFT");
               return tokenToOwner[_tokenId];
               
           }
           
           function transferFrom(address _from, 
           address _to,
           uint256 _tokenId)
           public override
           {
               address tokenOwner = ownerOf(_tokenId);
               require(tokenOwner==msg.sender||
               ownerToOperator[_from][msg.sender]||
               authorised[_tokenId]==msg.sender);
               require(_from == tokenOwner,"From does not own the token");
               require(_to!=address(0));
               nTokens[_from] --;
               nTokens[_to] ++;
               tokenToOwner[_tokenId] = _to;
               if (authorised[_tokenId]!=address(0))
               {
                   delete authorised[_tokenId];
               }
               emit Transfer(_from,_to,_tokenId);
           }
           
           function safeTransferFrom(address _from,
           address _to,
           uint256 _tokenId,
           bytes memory _data) 
           public override
           {
               transferFrom(_from,_to,_tokenId);
               if(_to.isContract()){
                   IERC721Receiver receiver = IERC721Receiver(_to);
                   require(receiver.onERC721Received(msg.sender,_from,_tokenId,_data)==bytes4(keccak256("onERC721Received(address,address,uint256,bytes)")),
                   "ERC721: transfer to non ERC721Receiver implementer");
                  
               } 
           }
           function safeTransferFrom(address _from, address _to, uint256 _tokenId) 
           public override
           {
               safeTransferFrom(_from,_to,_tokenId,"");
           }
           function approve(address _approved, uint256 _tokenId)
           public override
           {
              address owner = ownerOf(_tokenId);
               require(msg.sender==owner||ownerToOperator[owner][msg.sender],"sender is not owner or operator");
               emit Approval(owner, _approved, _tokenId);
               authorised[_tokenId] = _approved;
                emit Approval(owner, _approved, _tokenId);
           }
            function setApprovalForAll(address _operator, bool _approved) 
            public override
            {
                emit ApprovalForAll(msg.sender,_operator, _approved);
                ownerToOperator[msg.sender][_operator] = _approved;
            }
            function getApproved(uint256 _tokenId) 
            public view override
            returns (address)
            {
                require(_tokenId<totalTokens,"Invalid NFT");
                return authorised[_tokenId];
            }
             function isApprovedForAll(address _owner, address _operator) 
             public view override
             returns (bool)
             {
                 return ownerToOperator[_owner][_operator];
             }
        
             function mintTokens() 
             public
             {
                 tokenToOwner[totalTokens] = msg.sender;
                 totalTokens++;
                 nTokens[msg.sender]++;
                 
                 
             }
            
             function supportsInterface(bytes4 interfaceID) 
             public pure  override
             returns (bool)
             {
               return true;  
             }
               
}
        
    
    
    
    
