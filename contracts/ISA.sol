//SPDX-License-Identifier: Unlicense
pragma solidity ^0.7.0;

//import open zeppelin helpers
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

//import superfluid dependencies

import {
    ISuperfluid,
    ISuperToken,
    ISuperApp,
    ISuperAgreement,
    SuperAppDefinitions
} from "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperfluid.sol";

import {
    IConstantFlowAgreementV1
} from "@superfluid-finance/ethereum-contracts/contracts/interfaces/agreements/IConstantFlowAgreementV1.sol";

import {
    SuperAppBase
} from "@superfluid-finance/ethereum-contracts/contracts/apps/SuperAppBase.sol";

contract ISA is SuperAppBase, Ownable {

    //is owner the creator of this contract?

    ISuperfluid private host; //host
    IConstantFlowAgreementV1 private cfa; // the stored constant flow agreement class address
    ISuperToken private acceptedToken; // accepted token

    //agreement items to set in constructor
    uint public stakeRequirement;
    uint16 public repaymentPercent;
    uint public repaymentPeriodLength;
    uint public maxRepaymentAmount;
    uint private gracePeriod;
    address private payDestination;

    //set in stakeAndBegin()
    address private borrower;
    uint private activeStakedAmount;
    uint private agreementStartDate;
    uint private currentValuePaidBack;
    bool private payingBack;
    bool private open;
    uint private valueOutstanding;
    uint private timeNotPaying;

    constructor(
        ISuperfluid _host,
        IConstantFlowAgreementV1 _cfa,
        ISuperToken _acceptedToken,
        uint _stakeRequirement,
        uint16 _repaymentPercent,
        uint _repaymentPeriodLength,
        uint _maxRepaymentAmount,
        uint _gracePeriod) {
        
        require(_repaymentPercent >= 1 && _repaymentPercent <= 10000, "% Must be between 1 & 10000");
        require(address(_host) != address(0), "cannot be zero address");
        require(address(_cfa) != address(0), "cannot be zero address");
        require(address(_acceptedToken) != address(0), "cannot be zero address");


        host = _host;
        cfa = _cfa;
        acceptedToken = _acceptedToken;
        stakeRequirement = _stakeRequirement;
        repaymentPercent = _repaymentPercent;
        repaymentPeriodLength = _repaymentPeriodLength;
        maxRepaymentAmount = _maxRepaymentAmount;
        gracePeriod = _gracePeriod;

        //the payments from the students will go to the owner of this contract
        payDestination = msg.sender;

        uint256 configWord =
            SuperAppDefinitions.APP_LEVEL_FINAL |
            SuperAppDefinitions.BEFORE_AGREEMENT_CREATED_NOOP |
            SuperAppDefinitions.BEFORE_AGREEMENT_UPDATED_NOOP |
            SuperAppDefinitions.BEFORE_AGREEMENT_TERMINATED_NOOP;

        _host.registerApp(configWord);
    }

    function stakeAndBegin() external {
        require (acceptedToken.balanceOf(msg.sender) >= stakeRequirement, "Not enough tokens");

        borrower = msg.sender;
        agreementStartDate = block.timestamp;
        currentValuePaidBack = 0;
        payingBack = false;
        open = true;
        valueOutstanding = maxRepaymentAmount;
        timeNotPaying = 0;

        activeStakedAmount+= stakeRequirement;
        acceptedToken.transfer(address(this), stakeRequirement);
    }

    //getter functions

    function getAgreementStatus() public view returns (address, uint, uint, uint, uint, bool, bool) {
        return (borrower, agreementStartDate, currentValuePaidBack, valueOutstanding, timeNotPaying, payingBack, open);
    }

    function getAgreementInfo() public view returns (address, uint, uint16, uint, uint, uint) {
        return (payDestination, stakeRequirement, repaymentPercent, repaymentPeriodLength, maxRepaymentAmount, gracePeriod);
    }

}