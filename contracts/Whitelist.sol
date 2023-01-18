// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Whitelist {
    uint8 public maxWhitelistedAddresses;
    
    address owner;

    mapping(address => bool) public whitelistedAddresses;
    uint8 public numAddressesWhitelisted;

    constructor(uint8 _maxWhitelistedAddresses) {
      owner = msg.sender;
      maxWhitelistedAddresses =  _maxWhitelistedAddresses;
    }

    modifier onlyOwner() {
      require(msg.sender == owner, "Owner only");
      _;
    }

    modifier isWhitelisted(address _address) {
      require(whitelistedAddresses[_address], "Whitelist: You need to be whitelisted");
      _;
    }

    function addUser(address _addressToWhitelist) public onlyOwner {
      require(numAddressesWhitelisted < maxWhitelistedAddresses, "WhiteList Limit reached");
      whitelistedAddresses[_addressToWhitelist] = true;
      numAddressesWhitelisted += 1;
    }

    function verifyUser(address _whitelistedAddress) public view returns(bool) {
      bool userIsWhitelisted = whitelistedAddresses[_whitelistedAddress];
      return userIsWhitelisted;
    }

    function whitelistedAddressesL() public view isWhitelisted(msg.sender) returns(bool){
      return (true);
    }
}