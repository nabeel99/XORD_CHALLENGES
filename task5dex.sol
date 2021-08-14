
pragma solidity^0.8.6;
import "./erc721.sol";


contract Task5Dex is Task2 {
  
  mapping (uint => uint) private _nftToPrice;
  mapping (uint => address) private _nftToOwner;
  
  
  function ask(uint price, uint tokenID) 
  public {
      address temp = ownerOf(tokenID);
      require(temp== msg.sender||getApproved(tokenID)==msg.sender||isApprovedForAll(temp,msg.sender),"Not authorized or operator or owner");
      _nftToPrice[tokenID] = price;
  }
  function bid(uint _tokenId , uint _price) payable
  public {
      
      require(_nftToOwner[_tokenId]!=address(0),"This NFT does not exist in the market place");
      require(_price >= _nftToPrice[_tokenId],"value of token is higher than what you are paying");
      require(msg.value == _price,"Increase payment");
      transferFrom(_nftToOwner[_tokenId],msg.sender,_tokenId);
           (bool sent,) =  payable(_nftToOwner[_tokenId]).call{value: msg.value}("");
      require(sent==true,"Transaction Failed");
      
      
      
  }
    
}
