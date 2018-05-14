pragma solidity ^0.4.16;

import "./STCToken.sol";
import "./STCConsts.sol";
import "./STCRateProvider.sol";
import "./zeppelin/crowdsale/RefundableCrowdsale.sol";

contract STCCrowdsale is usingSTCConsts, RefundableCrowdsale {
    uint constant totalTokens = 300000000 * TOKEN_DECIMAL_MULTIPLIER;
    uint constant teamTokens = 45000000 * TOKEN_DECIMAL_MULTIPLIER;
    uint constant bountyTokens = 105000000 * TOKEN_DECIMAL_MULTIPLIER;
    uint constant icoTokens = 9000000 * TOKEN_DECIMAL_MULTIPLIER;
    uint constant minimalPurchase = 0.05 ether;
    address constant totalAddress = 0xA8FF2E2991f3c99de33E968506a0192036d6EEX;
    address constant teamAddress = 0xE4F0Ff4641f3c99de342b06c06414d94A585eFfb;
    address constant bountyAddress = 0x76d4136d6EE53DB4cc087F2E2990283d5317A5e9;
    address constant icoAccountAddress = 0x195610851A43E9685643A8F3b49F0F8a019204f1;

    STCRateProviderI public rateProvider;

    function STCCrowdsale(
            uint32 _startTime,
            uint32 _endTime,
            uint _softCapWei,
            uint _hardCapTokens
    )
        RefundableCrowdsale(_startTime, _endTime, _hardCapTokens * TOKEN_DECIMAL_MULTIPLIER, 0x80826b5b717aDd3E840343364EC9d971FBa3955C, _softCapWei) {

	token.mint(totalAddress,  totalTokens);
        token.mint(teamAddress,  teamTokens);
        token.mint(bountyAddress, bountyTokens);
        token.mint(icoAccountAddress, icoTokens);

	STCToken(token).addExcluded(totalAddress);
        STCToken(token).addExcluded(teamAddress);
        STCToken(token).addExcluded(bountyAddress);
        STCToken(token).addExcluded(icoAccountAddress);

        STCRateProvider provider = new STCRateProvider();
        provider.transferOwnership(owner);
        rateProvider = provider;

        // pre ICO
    }

    /**
     * @dev override token creation to integrate with STC token.
     */
    function createTokenContract() internal returns (MintableToken) {
        return new STCToken();
    }

    /**
     * @dev override getRate to integrate with rate provider.
     */
    function getRate(uint _value) internal constant returns (uint) {
        return rateProvider.getRate(msg.sender, soldTokens, _value);
    }

    function getBaseRate() internal constant returns (uint) {
        return rateProvider.getRate(msg.sender, soldTokens, minimalPurchase);
    }

    /**
     * @dev override getRateScale to integrate with rate provider.
     */
    function getRateScale() internal constant returns (uint) {
        return rateProvider.getRateScale();
    }

    /**
     * @dev Admin can set new rate provider.
     * @param _rateProviderAddress New rate provider.
     */
    function setRateProvider(address _rateProviderAddress) onlyOwner {
        require(_rateProviderAddress != 0);
        rateProvider = STCRateProviderI(_rateProviderAddress);
    }

    /**
     * @dev Admin can move end time.
     * @param _endTime New end time.
     */
    function setEndTime(uint32 _endTime) onlyOwner notFinalized {
        require(_endTime > startTime);
        endTime = _endTime;
    }

    function validPurchase(uint _amountWei, uint _actualRate, uint _totalSupply) internal constant returns (bool) {
        if (_amountWei < minimalPurchase) {
            return false;
        }
        return super.validPurchase(_amountWei, _actualRate, _totalSupply);
    }

    function finalization() internal {
        super.finalization();
        token.finishMinting();
        if (!goalReached()) {
            return;
        }
        STCToken(token).crowdsaleFinished();
        token.transferOwnership(owner);
    }
}