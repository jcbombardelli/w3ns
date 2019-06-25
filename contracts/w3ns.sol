pragma solidity ^0.5.0;

import "./common/Ownable.sol";
import "./common/Destructible.sol";
import "./libs/SafeMath.sol";

contract W3NS is Destructible {

    /** USINGS */
    using SafeMath for uint256;

    struct TopLevelDomainDetails{
        bytes12 name;
        address owner;
    }

    struct Receipt {
        uint amountPaidWei;
        uint timestamp;
        uint expires;
    }

    /** CONSTANTS */
    bytes1 constant public BYTES_DEFAULT_VALUE = bytes1(0x00);
    uint constant public TOP_LEVEL_DOMAIN_COST = 10 ether;
    uint8 constant public TOP_LEVEL_DOMAIN_MIN_LENGTH = 1;
    uint constant public TOP_LEVEL_DOMAIN_EXPIRATION_DATE = 365 days;



    /** STATE VARIABLES */

    // @dev - storing the TopLevelDomainDetails (bytes12) to its details
    mapping (bytes12 => TopLevelDomainDetails) public topLevelDomainNames;

    // @dev - all the receipt hashes/keys/ids for certain address
    mapping(address => bytes32[]) public paymentReceipts;

    // @dev - the details for a receipt by its hash/key/id
    mapping(bytes32 => Receipt) public receiptDetails;

    /**
     * @dev - Constructor of the contract
     */
    constructor() public {
    }


    modifier isTopLevelLengthAllowed(bytes12 topLevel) {
        // @dev - require the TLD lenght to be equal or greater than `TOP_LEVEL_DOMAIN_MIN_LENGTH` constant
        require(topLevel.length >= TOP_LEVEL_DOMAIN_MIN_LENGTH, "The provided TLD is too short.");
        _;
    }

    /**
     *  EVENTS
     */
    event LogTopLevelDomainNameRegistered(uint indexed timestamp, bytes12 topLevel );
    event LogReceipt(uint indexed timestamp, bytes domainName, uint amountInWei, uint expires);

    function registerTopLevelDomain(bytes12 topLevel) public payable {
        require(topLevelDomainNames[topLevel].expires < block.timestamp, "Domain name is not available.");

        // create a new domain entry with the provided fn parameters
        TopLevelDomainDetails memory newTLD = TopLevelDomainDetails(
            {
                name: topLevel,
                owner: msg.sender,
                expires: block.timestamp + TOP_LEVEL_DOMAIN_EXPIRATION_DATE
            }
        );

        // save the domain to the storage
        topLevelDomainNames[topLevel] = newTLD;

        // create an receipt entry for this domain purchase
        Receipt memory newReceipt = Receipt(
            {
                amountPaidWei: TOP_LEVEL_DOMAIN_COST,
                timestamp: block.timestamp,
                expires: block.timestamp + TOP_LEVEL_DOMAIN_EXPIRATION_DATE
            }
        );

        // calculate the receipt hash/key
        bytes32 receiptKey = getReceiptKey('', topLevel);

        // save the receipt key for this `msg.sender` in storage
        paymentReceipts[msg.sender].push(receiptKey);

        // save the receipt entry/details in storage
        receiptDetails[receiptKey] = newReceipt;

        emit LogReceipt(block.timestamp, topLevel, TOP_LEVEL_DOMAIN_COST, block.timestamp + TOP_LEVEL_DOMAIN_EXPIRATION_DATE);
        emit LogTopLevelDomainNameRegistered(block.timestamp, topLevel);
    }

    //comprar TLD
    //comprar dominio
    //registrar subdominio (precisa ter dominio)


    /**
     *  GETTERS
     */
    function getReceiptKey(bytes memory domain, bytes12 topLevel) public view returns(bytes32) {
        // @dev - tightly pack parameters in struct for keccak256
        return keccak256(abi.encodePacked(domain, topLevel, msg.sender, block.timestamp));
    }
}