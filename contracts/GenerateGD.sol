/* Copyright (C) 2017 GovBlocks.io

  This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

  This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
    along with this program.  If not, see http://www.gnu.org/licenses/ */

pragma solidity ^0.4.8;

import "./governanceData.sol";

contract GenerateGD
{
    // create governanceData Contract
    mapping(bytes32=>address) contractAddress;
    function getAddress(bytes32 _gbUserName)constant returns(address)
    {
        return (contractAddress[_gbUserName]);
    }
  
    function GenerateContract(bytes32 _gbUserName)
    {
       contractAddress[_gbUserName] = new governanceData();
    }
  
}