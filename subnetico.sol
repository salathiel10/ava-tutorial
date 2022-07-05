pragma solidity ^0.5.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/GSN/Context.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/math/SafeMath.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/utils/ReentrancyGuard.sol";

contract SubNetICO is Context, ReentrancyGuard{
    using SafeMath for uint256;

    // How many token units a buyer gets per wei.
    uint256 private _rate;

    // Address where funds are collected
    address payable private _wallet;

    // List buyers 
    mapping(uint32 => address) private _buyers;

    // Map buyer address and how much he/she bought 
    mapping(address => uint256) private _buyers_values;

    // Control buyer index variable
    uint32 private _buyer_index;

    /**
     * Contract constructor
     * @param rate Number of token units a buyer gets per wei. The rate is the conversion between wei and the smallest and indivisible
     * token unit.
     * @param wallet Address where collected funds will be forwarded to
     */
    constructor (uint256 rate, address payable wallet) public {
        require(rate > 0, "Crowdsale: rate is 0");
        require(wallet != address(0), "Crowdsale: wallet is the zero address");

        _buyer_index = 0;
        _rate = rate;
        _wallet = wallet;
    }

    /**
     * This function is called every time the contract receive a transaction
     */
    function () external payable {
        buyTokens(_msgSender());
    }

    /**
     * Buy the tokens. Add the beneficiary in _buyers map in the current _buyer_index position.
     * Register the transaction value in _buyers_values 
     * @param beneficiary Address performing the token purchase
     */
    function buyTokens(address beneficiary) public nonReentrant payable {
        uint256 weiAmount = msg.value;
        _preValidatePurchase(beneficiary, weiAmount);

        // calculate token amount to be created
        uint256 tokens = _getTokenAmount(weiAmount);

        _buyers[_buyer_index] = beneficiary;
        _buyers_values[beneficiary] = tokens;
        _buyer_index += 1;

        _forwardFunds();
    }

    /**
     * Validation of an incoming purchase. Use require statements to revert state when conditions are not met.
     * @param beneficiary Address performing the token purchase
     * @param weiAmount Value in wei involved in the purchase
     */
    function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal view {
        require(beneficiary != address(0), "Crowdsale: beneficiary is the zero address");
        require(weiAmount != 0, "Crowdsale: weiAmount is 0");
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    }

    /**
     * @param weiAmount Value in wei to be converted into tokens
     * @return Number of tokens that can be purchased with the specified _weiAmount
     */
    function _getTokenAmount(uint256 weiAmount) internal view returns (uint256) {
        return weiAmount.mul(_rate);
    }

    /**
     * Determines how ETH is stored/forwarded on purchases.
     */
    function _forwardFunds() internal {
        _wallet.transfer(msg.value);
    }

    /**
     * Return a buyer address given a index
     * @param index Index for buyer address
     */
    function getBuyerAddress(uint32 index) public view returns (address) {
        return _buyers[index];
    }

    /**
     * Return a buyer value given a address
     * @param buyer_address Buyer address
     */
    function getBuyerValue(address buyer_address) public view returns (uint256) {
        return _buyers_values[buyer_address];
    }

}