pragma solidity ^0.7.6;

contract Challenge7{
    
    /* Signature Verification

How to Sign and Verify
# Signing
1. Create message to sign
2. Hash the message
3. Sign the hash (off chain, keep your private key secret)

# Verify
1. Recreate hash from the original message
2. Recover signer from signature and hash
3. Compare recovered signer to claimed signer
*/
///@dev takes address of recipient , amount,arbitary message and nonce and returns a bytes32 hash
    function getMessageHash(address _to, 
    uint amount,
    string memory message,
    uint nonce) 
    public pure
    returns(bytes32) {
        return keccak256(abi.encodePacked(_to,amount,message,nonce));
    }
    function getEthSignedMessageHash(bytes32 messageHash)
    public pure 
    returns(bytes32){
        
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32",messageHash));
    }
    
    function verifySIG(address _to, 
    uint amount,
    string memory message,
    uint nonce,
    address _signer,
    bytes memory _claimedSignature)
    public pure returns(bool)
    {
    bytes32 hash = getMessageHash(_to,amount,message,nonce);
    bytes32 ethHash = getEthSignedMessageHash(hash);
    return recoverSigner(ethHash,_claimedSignature) == _signer;
    }
    
    function recoverSigner(bytes32 ethSigHash,
    bytes memory claimSig)
    public pure 
    returns(address) {
         (bytes32 r, bytes32 s, uint8 v) = splitSignature(claimSig);
        return ecrecover(ethSigHash,v,r,s);
    }
    
    
  function splitSignature(bytes memory claimSig)
        public pure returns (bytes32 r, bytes32 s, uint8 v)
    {
        require(claimSig.length == 65, "invalid signature length");

        assembly {
             r := mload(add(claimSig, 32))
             s := mload(add(claimSig, 64))
             v := byte(0,mload(add(claimSig, 96)))
           
        }
    }
    
   
   

}
