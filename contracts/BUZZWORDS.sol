// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IWhitelist.sol";


contract BUZZWORDS  is ERC721Enumerable, Ownable {


    bool public revealed = false;
    string public _baseTokenURI;
    //  _price is the price of one GalleryKey
    uint256 public _price = 1 ether;
    bool public _paused;
    // max n of tokens
    uint256 public maxTokenIds = 50;
    // total number of tokenIds minted
    uint256 public tokenIds;
    // Whitelist contract instance
    IWhitelist whitelist;

    bool public presaleStarted;
    // timestamp for when presale would end
    uint256 public presaleEnded;

    modifier onlyWhenNotPaused {
        require(!_paused, "Contract currently paused");
        _;
    }


    constructor (string memory baseURI, address whitelistContract) ERC721("BUZZWORDS", "BZZ") {
        _baseTokenURI = baseURI;
        whitelist = IWhitelist(whitelistContract);
     
    }


    function startPresale() public onlyOwner {
        presaleStarted = true;
        presaleEnded = block.timestamp + 2 minutes;
    }
    /**
     * @dev presaleMint allows a user to mint one NFT per transaction during the presale.
     */
    function presaleMint() public payable onlyWhenNotPaused {
        require(presaleStarted && block.timestamp < presaleEnded, "Presale is not running");
        require(whitelist.whitelistedAddresses(msg.sender), "You are not whitelisted");
        require(tokenIds < maxTokenIds, "Exceeded maximum BUZZWORDS supply");
        require(msg.value >= _price, "Ether sent is not correct");
        tokenIds += 1;
        //_safeMint is a safer version of the _mint function as it ensures that
        // if the address being minted to is a contract, then it knows how to deal with ERC721 tokens
        // If the address being minted to is not a contract, it works the same way as _mint
        _safeMint(msg.sender, tokenIds);
    }

    function reveal() external onlyOwner {
        revealed= true;
    }


    function changeUri(string memory _newUri) public onlyOwner {
        _baseTokenURI = _newUri;
    } /** ADD only one time modifier

      /**
      * 
      */
    function mint() public payable onlyWhenNotPaused {
        require(presaleStarted && block.timestamp >=  presaleEnded, "Presale has not ended yet");
        require(tokenIds < maxTokenIds, "Exceed maximum BUZZWORDS supply");
        require(msg.value >= _price, "Ether sent is not correct");
        tokenIds += 1;
        _safeMint(msg.sender, tokenIds);
    }
    /**
    * @dev _baseURI overides the Openzeppelin's ERC721 implementation which by default
    * returned an empty string for the baseURI
    */
    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }
    /**
    * @dev setPaused makes the contract paused or unpaused
     */
    function setPaused(bool val) public onlyOwner {
        _paused = val;
    }

      /**
      * @dev withdraw sends all the ether in the contract
      * to the owner of the contract
       */
    function withdraw() public onlyOwner  {
        address _owner = owner();
        uint256 amount = address(this).balance;
        (bool sent, ) =  _owner.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }

       // Function to receive Ether. msg.data must be empty
    receive() external payable {}

      // Fallback function is called when msg.data is not empty
    fallback() external payable {}
}