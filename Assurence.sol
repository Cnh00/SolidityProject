pragma solidity ^0.8.0  ; 

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract CryptoInsurance {


    IERC20 public usdtToken ; 
    uint256 public totalInsuredAmount ; 
    uint256 public monthlyPremium ; 
    uint256 public  payoutPercentage ; 
    uint256 public minimumPayout ; 
    uint256 public lastPayoutTimestamp ; 
    address public owner ; //andressna 


    mapping(address => uint256 ) public insuredAmounts ; 
    mapping(address => uint256 ) public totalpaidPremium ; 
    mapping(address => uint256 ) public totalClaimCount ; 
    mapping(address => uint256 ) public totalClaim ; 


    event Insured(address indexed user , uint256 amount); 
    event PremiumPaid(address indexed user , uint256 amount) ; 
    event Claimed(address indexed user , uint256 amount ) ; 


    constructor (
        address _usdtToken , 
        uint256 _monthlypremium , 
        uint256 _payoutPercentage , 
        uint256 _minimumPayout 

    ) 
    {
        usdtToken = IERC20(_usdtToken);
        monthlyPremium = _monthlypremium ; 
        payoutPercentage =_payoutPercentage ; 
        minimumPayout = _minimumPayout ; 
        owner = address(this)  ; //address mtena ahna  

    }

    function insure(uint256 _amount ) external {
        require ( _amount > 0 ,"flous li bch tassureha lezem akbar m 0 ") ; 
        usdtToken.transferFrom(msg.sender,owner, _amount);
        insuredAmounts[msg.sender]+=_amount;
        totalInsuredAmount +=_amount ;
        emit Insured(msg.sender,_amount) ;

    }

    function payPremium() external {
        require(insuredAmounts[msg.sender]>0,"mafamech flous assure lsayed hedha "); 
        uint256 premium =calculateMonthlyPremium(msg.sender);
        usdtToken.transfer(owner,premium);
        totalpaidPremium[msg.sender]+=premium;
        emit PremiumPaid(msg.sender , premium);

    }

    function claim() external {
        require(insuredAmounts[msg.sender]>0, " mandkch flous ha nami ") ; 
        require(block.timestamp >= lastPayoutTimestamp+30 days,"mara fchhar kahaw nraj3oulek flous");
        uint256 payout = (insuredAmounts[msg.sender]*payoutPercentage/100 ); 
        if ( payout < minimumPayout ){
            payout = minimumPayout;

        }
        require(usdtToken.balanceOf(address(this))>=payout , "maanech flous bch nkhalsouk ");
        usdtToken.transfer(msg.sender , payout) ; 
        insuredAmounts[msg.sender]=0; 
        totalInsuredAmount-=payout ; 
        lastPayoutTimestamp=block.timestamp ; 
        totalClaimCount[msg.sender]+=1; 
        totalClaimCount[msg.sender]+=payout; 
        emit Claimed(msg.sender, payout) ; 

    }

    function setMonthlyPremium(uint256 _monthlypremium ) external {
        require(msg.sender== owner , "ken moula charika ymes el function hedhi "); 
        monthlyPremium=_monthlypremium ; 

    }

    function calculateMonthlyPremium(address client) public views returns ( uint256) {
        uint256 totalClaims = totalClaim[client] ; 
        uint256 volatilityFactor = getVolatilityFactor() ;
        uint256 baseMonthlyPremium = insuredAmounts[client]*volatilityFactor/10000;

        uint256 finalMonthlyPremium = baseMonthlyPremium + totalClaims*volatilityFactor/10000 ;  // whedhi zeda nzidou nrakhouha  
        return finalMonthlyPremium ; 
    }

    function calculateClaim(address client) public view returns (uint256) {
        uint256 totalClaims=totalClaim[client] ; 
        uint256 volatilityFactor=getVolatilityFactor(); 
        uint256 totalPremium=totalpaidPremium[client] ; 
        uint256 totalinsured = insuredAmounts[client]; 

        uint256 finalClaim = totalinsured*volatilityFactor/10000 - ( totalinsured/ totalClaims) // ta nzidou nrakhouha hedhi 
    

    }
    
    function getVolatilityFactor() public view returns (uint256) {
        
    }








}