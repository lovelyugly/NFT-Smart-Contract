//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract RussainDolls is ERC721Enumerable, Ownable {

    uint public constant PRICE = 0.001 ether;
    string public baseTokenURI;
    uint[] soldedTokenIds;
    mapping (address => uint[]) nftOwner;
    event MintNft(address senderAddress, uint256 nftToken);

    constructor(string memory baseURI)  ERC721("Russian Dolls", "RUD") {
        setBaseURI(baseURI);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    function setBaseURI(string memory _baseTokenURI) public onlyOwner {
        baseTokenURI = _baseTokenURI;
    }

     modifier checkTokenStatus(uint _tokenId) {
        bool isTokenSold = false;
        for (uint i = 0; i < soldedTokenIds.length; i++) {
            if(soldedTokenIds[i] == _tokenId) {
                isTokenSold = true;
                break;
            }
        }
        require(!isTokenSold, "Token is sold");
        _;
    }

    function reserveNFT(uint _tokenId) public onlyOwner checkTokenStatus(_tokenId) {
        _safeMint(msg.sender, _tokenId);
        nftOwner[msg.sender].push(_tokenId);
        soldedTokenIds.push(_tokenId);
        emit MintNft(msg.sender, _tokenId);
    }

    function mintNFT(uint _tokenId) public payable checkTokenStatus(_tokenId) {
        require(msg.value >= PRICE, "Not enough ETH to purchase NFTs.");
        _safeMint(msg.sender, _tokenId);
        soldedTokenIds.push(_tokenId);
        emit MintNft(msg.sender, _tokenId);
    }

    function tokensOfOwner(address _owner) external view returns (uint[] memory) {
        return nftOwner[_owner];
    }

    function withdraw() public payable onlyOwner {
        uint balance = address(this).balance;
        require(balance > 0, "No ETH left to withdraw");
        (bool success, ) = (msg.sender).call{value: balance}("");
        require(success, "Transfer failed.");
    }
}