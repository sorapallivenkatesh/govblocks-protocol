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
pragma solidity 0.4.24;
import "./imports/govern/Governed.sol";
import "./ProposalCategoryAdder.sol";


contract ProposalCategory is Governed {
    bool public constructorCheck;
    bool public adderCheck;
    address public officialPCA;

    struct Category {
        string name;
        uint[] memberRoleSequence;
        uint[] memberRoleMajorityVote;
        uint[] allowedToCreateProposal;
        uint[] closingTime;
    }

    struct SubCategory {
        string subCategoryName;
        string actionHash;
        uint categoryId;
        address contractAddress;
        bytes2 contractName;
        uint minStake;
        uint tokenHoldingTime;
        uint defaultIncentive;
        uint8 rewardPercProposal;
        uint8 rewardPercSolution;
        uint8 rewardPercVote; 
    }

    SubCategory[] public allSubCategory;
    Category[] internal allCategory;
    mapping(uint => uint[]) internal allSubIdByCategory;

    /// @dev Adds new category
    /// @param _name Category name
    /// @param _memberRoleSequence Voting Layer sequence in which the voting has to be performed.
    /// @param _allowedToCreateProposal Member roles allowed to create the proposal
    /// @param _memberRoleMajorityVote Majority Vote threshhold for Each voting layer
    /// @param _closingTime Vote closing time for Each voting layer
    function addNewCategory(
        string _name, 
        uint[] _memberRoleSequence,
        uint[] _memberRoleMajorityVote, 
        uint[] _allowedToCreateProposal,
        uint[] _closingTime
    ) 
        external
        onlyAuthorizedToGovern 
    {
        require(_memberRoleSequence.length == _memberRoleMajorityVote.length 
            && _memberRoleMajorityVote.length == _closingTime.length
        );
        allCategory.push(Category(
                _name, 
                _memberRoleSequence, 
                _memberRoleMajorityVote, 
                _allowedToCreateProposal,
                _closingTime
            )
        );
    }

    /// @dev Updates category details
    /// @param _categoryId Category id that needs to be updated
    /// @param _roleName Updated Role sequence to vote i.e. Updated voting layer sequence
    /// @param _majorityVote Updated Majority threshhold value against each voting layer.
    /// @param _allowedToCreateProposal Member roles allowed to create the proposal
    /// @param _closingTime Updated Vote closing time against each voting layer
    function updateCategory(
        uint _categoryId, 
        string _name, 
        uint[] _roleName, 
        uint[] _majorityVote, 
        uint[] _allowedToCreateProposal,
        uint[] _closingTime
    )
        external 
        onlyAuthorizedToGovern
    {
        require(_roleName.length == _majorityVote.length && _majorityVote.length == _closingTime.length);
        allCategory[_categoryId].name = _name;
        allCategory[_categoryId].memberRoleSequence = _roleName;
        allCategory[_categoryId].memberRoleMajorityVote = _majorityVote;
        allCategory[_categoryId].closingTime = _closingTime;
        allCategory[_categoryId].allowedToCreateProposal = _allowedToCreateProposal;  
    }

    /// @dev Add new sub category against category.
    /// @param _subCategoryName Name of the sub category
    /// @param _actionHash Automated Action hash has Contract Address and function name 
    /// i.e. Functionality that needs to be performed after proposal acceptance.
    /// @param _mainCategoryId Id of main category
    function addNewSubCategory(
        string _subCategoryName, 
        string _actionHash, 
        uint _mainCategoryId, 
        address _contractAddress,
        bytes2 _contractName,
        uint[] _stakeAndIncentive, 
        uint8[] _rewardPercentage
    ) 
        external
        onlyAuthorizedToGovern 
    {
        allSubIdByCategory[_mainCategoryId].push(allSubCategory.length);
        allSubCategory.push(SubCategory(
                _subCategoryName, 
                _actionHash, 
                _mainCategoryId, 
                _contractAddress, 
                _contractName,
                _stakeAndIncentive[0],
                _stakeAndIncentive[1],
                _stakeAndIncentive[2],
                _rewardPercentage[0],
                _rewardPercentage[1],
                _rewardPercentage[2]
            )
        );
    }

    /// @dev Update Sub category of a specific category.
    /// @param _subCategoryId Id of subcategory that needs to be updated
    /// @param _actionHash Updated Automated Action hash i.e. Either contract address or function name is changed.
    function updateSubCategory(
        string _subCategoryName, 
        string _actionHash, 
        uint _subCategoryId, 
        address _address, 
        bytes2 _contractName,
        uint[] _stakeAndIncentive, 
        uint8[] _rewardPercentage
    ) 
        external 
        onlyAuthorizedToGovern 
    {
        allSubCategory[_subCategoryId].subCategoryName = _subCategoryName;
        allSubCategory[_subCategoryId].actionHash = _actionHash;
        allSubCategory[_subCategoryId].contractAddress = _address;
        allSubCategory[_subCategoryId].contractName = _contractName;
        allSubCategory[_subCategoryId].minStake = _stakeAndIncentive[0];
        allSubCategory[_subCategoryId].tokenHoldingTime = _stakeAndIncentive[1];
        allSubCategory[_subCategoryId].defaultIncentive = _stakeAndIncentive[2];
        allSubCategory[_subCategoryId].rewardPercProposal = _rewardPercentage[0];
        allSubCategory[_subCategoryId].rewardPercSolution = _rewardPercentage[1];
        allSubCategory[_subCategoryId].rewardPercVote = _rewardPercentage[2];

    }

    /// @dev gets category details
    function getCategoryDetails(uint _id) public view returns(string, uint[], uint[], uint[], uint[]) {
        return(
            allCategory[_id].name,
            allCategory[_id].memberRoleSequence,
            allCategory[_id].memberRoleMajorityVote,
            allCategory[_id].allowedToCreateProposal,
            allCategory[_id].closingTime
        );
    } 

    /// @dev Get Sub category name 
    function getSubCategoryName(uint _subCategoryId) public view returns(uint, string) {
        return (_subCategoryId, allSubCategory[_subCategoryId].subCategoryName);
    }

    /// @dev Get contractName
    function getContractName(uint _subCategoryId) public view returns(bytes2) {
        return allSubCategory[_subCategoryId].contractName;
    }  

    /// @dev Get contractAddress 
    function getContractAddress(uint _subCategoryId) public view returns(address) {
        return allSubCategory[_subCategoryId].contractAddress;
    } 

    /// @dev Get Sub category id at specific index when giving main category id 
    /// @param _categoryId Id of main category
    /// @param _index Get subcategory id at particular index in all subcategory array
    function getSubCategoryIdAtIndex(uint _categoryId, uint _index) public view returns(uint _subCategoryId) {
        return allSubIdByCategory[_categoryId][_index];
    }

    /// @dev Get Sub categories array against main category
    function getAllSubIdsByCategory(uint _categoryId) public view returns(uint[]) {
        return allSubIdByCategory[_categoryId];
    }

    /// @dev Get Member Roles allowed to create proposal by category
    function getMRAllowed(uint _categoryId) public view returns(uint[]) {
        return allCategory[_categoryId].allowedToCreateProposal;
    }

    /// @dev Get Total number of sub categories against main category
    function getAllSubIdsLengthByCategory(uint _categoryId) public view returns(uint) {
        return allSubIdByCategory[_categoryId].length;
    }

    /// @dev Gets Main category when giving sub category id. 
    function getCategoryIdBySubId(uint _subCategoryId) public view returns(uint) {
        return allSubCategory[_subCategoryId].categoryId;
    }

    function isCategoryExternal(uint _category) public view returns(bool ext) {
        return _isCategoryExternal(_category);
    }

    function isSubCategoryExternal(uint _subCategory) public view returns(bool ext) {
        uint category = allSubCategory[_subCategory].categoryId;
        return _isCategoryExternal(category);
    }

    function getRequiredStake(uint _subCategoryId) public view returns(uint, uint) {
        return (
            allSubCategory[_subCategoryId].minStake, 
            allSubCategory[_subCategoryId].tokenHoldingTime
        );
    }

    function getTokenHoldingTime(uint _subCategoryId) public view returns(uint) {
        return allSubCategory[_subCategoryId].tokenHoldingTime;
    }

    /// @dev Gets reward percentage for Proposal to distribute stake on proposal acceptance
    function getRewardPercProposal(uint _subCategoryId) public view returns(uint) {
        return allSubCategory[_subCategoryId].rewardPercProposal;
    }

    /// @dev Gets reward percentage for Solution to distribute stake on proposing favourable solution
    function getRewardPercSolution(uint _subCategoryId) public view returns(uint) {
        return allSubCategory[_subCategoryId].rewardPercSolution;
    }

    /// @dev Gets reward percentage for Voting to distribute stake on casting vote on winning solution  
    function getRewardPercVote(uint _subCategoryId) public view returns(uint) {
        return allSubCategory[_subCategoryId].rewardPercVote;
    }

    /// @dev Gets minimum stake for sub category id
    function getMinStake(uint _subCategoryId) public view returns(uint) {
        return allSubCategory[_subCategoryId].minStake;
    }

    /// @dev Gets Majority threshold array length when giving main category id
    function getRoleMajorityVotelength(uint _categoryId) public view returns(uint index, uint majorityVoteLength) {
        index = _categoryId;
        majorityVoteLength = allCategory[_categoryId].memberRoleMajorityVote.length;
    }

    /// @dev Gets role sequence length by category id
    function getRoleSequencLength(uint _categoryId) public view returns(uint roleLength) {
        roleLength = allCategory[_categoryId].memberRoleSequence.length;
    }

    /// @dev Gets Closing time array length when giving main category id
    function getCloseTimeLength(uint _categoryId) public view returns(uint) {
        return allCategory[_categoryId].closingTime.length;
    }

    /// @dev Gets Closing time at particular index from Closing time array
    /// @param _categoryId Id of main category
    /// @param _index Current voting status againt proposal act as an index here
    function getClosingTimeAtIndex(uint _categoryId, uint _index) public view returns(uint ct) {
        return allCategory[_categoryId].closingTime[_index];
    }

    /// @dev Gets Voting layer role sequence at particular index from Role sequence array
    /// @param _categoryId Id of main category
    /// @param _index Current voting status againt proposal act as an index here
    function getRoleSequencAtIndex(uint _categoryId, uint _index) public view returns(uint roleId) {
        return allCategory[_categoryId].memberRoleSequence[_index];
    }

    /// @dev Gets Majority threshold value at particular index from Majority Vote array
    /// @param _categoryId Id of main category
    /// @param _index Current voting status againt proposal act as an index here
    function getRoleMajorityVoteAtIndex(uint _categoryId, uint _index) public view returns(uint majorityVote) {
        return allCategory[_categoryId].memberRoleMajorityVote[_index];
    }

    /// @dev Gets Default incentive to be distributed against sub category.
    function getSubCatIncentive(uint _subCategoryId) public view returns(uint) {
        return allSubCategory[_subCategoryId].defaultIncentive;
    }

    /// @dev Gets Total number of categories added till now
    function getCategoryLength() public view returns(uint) {
        return allCategory.length;
    }

    /// @dev Gets Total number of sub categories added till now
    function getSubCategoryLength() public view returns(uint) {
        return allSubCategory.length;
    }

    /// @dev Gets Cateory description hash when giving category id
    function getCategoryName(uint _categoryId) public view returns(uint, string) {
        return (_categoryId, allCategory[_categoryId].name);
    }

    /// @dev Gets Category data depending upon current voting index in Voting sequence.
    /// @param _categoryId Category id
    /// @param _currVotingIndex Current voting Id in voting seqeunce.
    /// @return Next member role to vote with its closing time and majority vote.
    function getCategoryVotingLayerData(uint _categoryId, uint _currVotingIndex) 
        public
        view 
        returns(uint , uint, uint) 
    {
        return (
            allCategory[_categoryId].memberRoleSequence[_currVotingIndex], 
            allCategory[_categoryId].memberRoleMajorityVote[_currVotingIndex], 
            allCategory[_categoryId].closingTime[_currVotingIndex]
        );
    }

    function getMRSequenceBySubCat(uint _subCategoryId, uint _currVotingIndex) public view returns (uint) {
        uint category = allSubCategory[_subCategoryId].categoryId;
        return allCategory[category].memberRoleSequence[_currVotingIndex];
    }

    function addInitialSubC(
        string _subCategoryName, 
        string _actionHash, 
        uint _mainCategoryId, 
        address _contractAddress,
        bytes2 _contractName,
        uint[] _stakeAndIncentive, 
        uint8[] _rewardPercentage
    ) 
        public 
    {
        require(allSubCategory.length <= 21);
        require(msg.sender == officialPCA || officialPCA == address(0));
        allSubIdByCategory[_mainCategoryId].push(allSubCategory.length);
        allSubCategory.push(SubCategory(
                _subCategoryName, 
                _actionHash, 
                _mainCategoryId, 
                _contractAddress, 
                _contractName,
                _stakeAndIncentive[0],
                _stakeAndIncentive[1],
                _stakeAndIncentive[2],
                _rewardPercentage[0],
                _rewardPercentage[1],
                _rewardPercentage[2]
            )
        );
    }

    /// @dev Initiates Default settings for Proposal Category contract (Adding default categories)
    function proposalCategoryInitiate(bytes32 _dAppName) public {
        require(!constructorCheck);
        dappName = _dAppName;

        if (_getCodeSize(0x31475f356a415fe6cb19e450ff8e49c9b6ef9819) > 0)        //kovan testnet
            officialPCA = 0x31475f356a415fe6cb19e450ff8e49c9b6ef9819;

        constructorCheck = true;
    }

    function addDefaultCategories() public {
        require(!adderCheck);
        uint[] memory rs = new uint[](1);
        uint[] memory al = new uint[](2);
        uint[] memory alex = new uint[](1);
        uint[] memory mv = new uint[](1);
        uint[] memory ct = new uint[](1);
        
        rs[0] = 1;
        mv[0] = 50;
        al[0] = 1;
        al[1] = 2;
        alex[0] = 0;
        ct[0] = 72000;
        
        allCategory.push(Category("Uncategorized", rs, mv, al, ct));
        allCategory.push(Category("Member role", rs, mv, al, ct));
        allCategory.push(Category("Categories", rs, mv, al, ct));
        allCategory.push(Category("Parameters", rs, mv, al, ct));
        allCategory.push(Category("Transfer Assets", rs, mv, al, ct));
        allCategory.push(Category("Critical Actions", rs, mv, al, ct));
        allCategory.push(Category("Immediate Actions", rs, mv, al, ct));
        allCategory.push(Category("External Feedback", rs, mv, alex, ct));
        allCategory.push(Category("Others", rs, mv, al, ct));

        allSubIdByCategory[0].push(0);
        allSubCategory.push(SubCategory(
                "Uncategorized",
                "", 
                0, 
                address(0), 
                "EX", 
                0,
                0,
                0,
                0,
                0,
                0
            )
        );

        adderCheck = true;
    }

    ///@dev just to follow the interface
    function updateDependencyAddresses() public pure { //solhint-disable-line
    }

    /// @dev just to adhere to GovBlockss' Upgradeable interface
    function changeMasterAddress(address _masterAddress) public pure { //solhint-disable-line
    }

    function _getCodeSize(address _addr) internal view returns(uint _size) {
        assembly { //solhint-disable-line
            _size := extcodesize(_addr)
        }
    }

    function _isCategoryExternal(uint _category) internal view returns(bool ext) {
        for (uint i = 0; i < allCategory[_category].allowedToCreateProposal.length; i++) {
            if (allCategory[_category].allowedToCreateProposal[i] == 0)
                ext = true;
        }
        
    }
}