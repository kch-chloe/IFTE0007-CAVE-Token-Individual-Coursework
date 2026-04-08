// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// CAVE Token — Chateau Access and Vintage Entitlement
// Underlying asset: Chateau Margaux annual wine revenue stream
// Dual-value mechanism: revenue distribution right + wine purchase entitlement right
// Revenue sharing: 30% of total annual estate revenue is permanently allocated
// to token holders — this percentage is hardcoded and cannot be changed by anyone

contract CAVE is ERC20 {

    address public admin;

    // Minimum token holding required to unlock wine purchase discount
    uint256 public constant ENTITLEMENT_THRESHOLD = 100;

    // Distribution percentage permanently fixed at 30%
    uint256 public constant DISTRIBUTION_PERCENTAGE = 30;

    // Discount rate permanently fixed at 20% — 2000 basis points
    uint256 public constant DISCOUNT_BPS = 2000;

    // Stores the current harvest year e.g. 2024
    uint256 public vintageYear;

    // Stores the portion of total revenue allocated to token holders
    uint256 public totalRevenue;

    // Switch — becomes true when admin calls loadRevenue()
    bool public distributionReady;

    // Switch — becomes true when admin calls activateEntitlement()
    // Activated independently of revenue loading
    bool public entitlementActive;

    // Prevents claiming more than once per vintage cycle
    mapping(address => uint256) public lastClaimedCycle;

    // Prevents using entitlement more than once per vintage cycle
    mapping(address => uint256) public lastEntitlementCycle;

    // Blocks previous cycle token holders from claiming current cycle rights
    mapping(address => uint256) public tokenVintageYear;

    // Events — recorded permanently on-chain for audit purposes
    event RevenueDistributed(address indexed holder, uint256 amount);
    event EntitlementUsed(address indexed holder, uint256 discount);
    event VintageStarted(uint256 year, uint256 supply);
    event VintageEnded(uint256 year);
    event EntitlementActivated(uint256 year);

    // Records total revenue loaded, amount distributed, and fixed percentage
    // Provides full on-chain transparency for token holders to verify
    event RevenueLoaded(uint256 totalAmount, uint256 distributionAmount, uint256 percentage);

    // Restricts certain functions to admin wallet only
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }

    constructor() ERC20("Chateau Access and Vintage Entitlement", "CAVE") {
        admin = msg.sender;
    }

    // Zero decimals — each token is an indivisible participation unit
    function decimals() public pure override returns (uint8) {
        return 0;
    }

    // FUNCTION 1: mintVintage
    // Opens a new vintage cycle — mints fixed supply tied to annual production volume
    // Input 1 — year: enter the harvest year e.g. 2024
    // Input 2 — supply: enter total token supply matching confirmed production volume e.g. 298000
    function mintVintage(uint256 year, uint256 supply) public onlyAdmin {
        vintageYear = year;
        distributionReady = false;      // resets distribution switch for new cycle
        entitlementActive = false;      // resets entitlement switch for new cycle
        _mint(admin, supply);         
        tokenVintageYear[admin] = year; // stamps admin tokens with current vintage year
        emit VintageStarted(year, supply);
    }

    // FUNCTION 2: activateEntitlement
    // Activates wine purchase entitlement right independently of revenue loading
    function activateEntitlement() public onlyAdmin {
        entitlementActive = true;
        emit EntitlementActivated(vintageYear);
    }

    // FUNCTION 3: loadRevenue
    // Loads verified estate revenue and calculates the 30% holder distribution
    // Input — totalAmount: enter TOTAL annual estate revenue across all wine lines
    // e.g. loadRevenue(5000000) for £5,000,000 total revenue
    function loadRevenue(uint256 totalAmount) public onlyAdmin {
        require(totalAmount > 0, "Revenue must be greater than zero");

    
        totalRevenue = (totalAmount * DISTRIBUTION_PERCENTAGE) / 100;

        distributionReady = true;       

        emit RevenueLoaded(totalAmount, totalRevenue, DISTRIBUTION_PERCENTAGE);
    }

    // FUNCTION 4: claimDistribution
    // Formula: holderShare = (balanceOf(holder) x totalRevenue) / totalSupply()
    // Emits on-chain proof of pro-rata revenue claim — one per wallet per cycle
    function claimDistribution() public {
        require(distributionReady, "Distribution not yet activated");
        require(lastClaimedCycle[msg.sender] != vintageYear, "Already claimed this cycle");
        require(balanceOf(msg.sender) > 0, "No tokens held");
        require(tokenVintageYear[msg.sender] == vintageYear, "Tokens not from current vintage");

        uint256 holderShare = (balanceOf(msg.sender) * totalRevenue) / totalSupply();
        lastClaimedCycle[msg.sender] = vintageYear;  // records this cycle as claimed
        emit RevenueDistributed(msg.sender, holderShare);
    }

    // FUNCTION 5: useEntitlement
    // Records entitlement activation as on-chain proof of discount eligibility
    function useEntitlement() public {
        require(entitlementActive, "Entitlement not yet activated");
        require(lastEntitlementCycle[msg.sender] != vintageYear, "Already used entitlement this cycle");
        require(balanceOf(msg.sender) >= ENTITLEMENT_THRESHOLD, "Insufficient tokens");
        require(tokenVintageYear[msg.sender] == vintageYear, "Tokens not from current vintage");

        lastEntitlementCycle[msg.sender] = vintageYear;  // records this cycle as used
        emit EntitlementUsed(msg.sender, DISCOUNT_BPS);
    }

    // FUNCTION 6: closeVintage
    // Burns all remaining admin-held tokens and closes the vintage cycle
    function closeVintage() public onlyAdmin {
        uint256 adminBalance = balanceOf(admin);
        _burn(admin, adminBalance);     
        emit VintageEnded(vintageYear);
    }

    // Override _update — stamps recipient with current vintage year on every token movement
    function _update(address from, address to, uint256 value) internal override {
        super._update(from, to, value);
        if (to != address(0) && from != address(0)) {
            tokenVintageYear[to] = vintageYear;  // stamps recipient with current vintage year
        }
    }
}