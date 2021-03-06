//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

//eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJkaWQ6ZXRocjoweDczMzE5ZEQ2RkQ5MkJCMTlEZWYzNTMyNENDODQzNTFjMkRhODcwYTgiLCJpc3MiOiJuZnQtc3RvcmFnZSIsImlhdCI6MTYzMzEwNTg5MzI2NiwibmFtZSI6ImVuY29kZV9rZXkifQ.YnG2DMFB5SiQ1dfXPkZCn3q-QgTXEIKuj-IxSXceFP0

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract WeMint is ERC721('WeMint','WMT'), Ownable {
    uint256 tokenID;
    
    struct Metadata{
        uint256 tokenID;
        uint256 timestamp;
        string tokenURI;
        string tokenDescription;
        string tokenName;
    }
    
    mapping(uint256 => uint256) private salePrice;
    
    mapping(address => Metadata[]) public tokenOwners;
    
     function getTokenID() internal returns (uint256) {
        uint256 newTokenID = tokenID;
        tokenID++;
        return newTokenID;
    }
    
       function purgeMetadata(uint256 tokenID) internal {
       for(uint256 i=0; i<tokenOwners[msg.sender].length; i++) {
            if(tokenOwners[msg.sender][i].tokenID == tokenID) {
                delete tokenOwners[msg.sender][i];
            }
        }
    }
    
    function setSale(uint256 tokenId, uint256 price) public {
		address owner = ownerOf(tokenId);
        require(owner == msg.sender, "setSale: msg.sender is not the owner of the token");
		salePrice[tokenId] = price;
	}
	
	function buyTokenOnSale(uint256 tokenId) public payable {
    	uint256 price = salePrice[tokenId];
        require(price != 0, "buyToken: price equals 0");
        require(msg.value == price, "buyToken: price doesn't equal salePrice[tokenId]");
        address owner = address(ownerOf(tokenId));
	    salePrice[tokenId] = 0;
	    transferFrom(owner, msg.sender, tokenId);
        payable (owner).transfer(msg.value);
}

    function safemint(string memory tokenURI, string memory nftName, string memory tokenDescription) public {
        uint256 tokenID = getTokenID();
        _safeMint(msg.sender, tokenID);

        tokenOwners[msg.sender].push(
            Metadata({timestamp: block.timestamp, tokenID: tokenID, tokenURI: tokenURI, tokenName: nftName, tokenDescription: tokenDescription})
        );
    }
    
    function getNfts() public view returns (Metadata[] memory){
        return tokenOwners[msg.sender];
    }
    
    function getTokenSellerAddress(uint256 _tokenId) public view returns(address) {
        return ownerOf(_tokenId);
    }

    function burnToken(uint256 tokenID) public {
        require(ownerOf(tokenID) == msg.sender, "Only owner is  allowed");
        _burn(tokenID);
        purgeMetadata(tokenID);
    }

 
    
}