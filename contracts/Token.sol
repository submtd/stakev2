// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface ITaxHandler {
    function distribute() external;
}

import "./BaseContract.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";

error MintingNotAllowed();
error ProtocolAlreadyLaunched();
error ProtocolNotLaunched();
error TransferFailed();
error NotEnoughPairTokenBalance();

contract Token is BaseContract, ERC20
{
    /**
     * Presale.
     */
    uint256 public presaleTokens;
    mapping(address => uint256) public presaleBalance;
    mapping(address => bool) public presaleClaimed;
    event PresalePurchased(address participant, uint256 amount);
    event PresaleClaimed(address participant, uint256 amount);

    /**
     * Launch.
     */
    uint256 public initialLPTokens;
    uint256 public initialLPPairTokens;
    uint256 public launchTime;
    uint256 private _launchPrice;
    address private _pair;
    event ProtocolLaunched(uint256 launchTime, uint256 launchPrice);

    /**
     * Taxes.
     */
    uint256 public swapTax = 5; // 5% tax on swaps.

    /**
     * Contract constructor.
     * @param name_ Token name.
     * @param symbol_ Token symbol.
     * @param registry_ Registry address.
     * @param maxSupply_ Maximum supply of tokens.
     * @param launchTime_ Block timestamp for protocol launch.
     * @notice Max supply is minted to this contract when it is deployed. No more tokens will ever be minted.
     */
    constructor(string memory name_, string memory symbol_, address registry_, uint256 maxSupply_, uint256 launchTime_)
        BaseContract(registry_)
        ERC20(name_, symbol_)
    {
        _mint(address(this), maxSupply_);
        initialLPTokens = maxSupply_ * 45 / 100; // 45% of minted tokens go to LP.
        presaleTokens = maxSupply_ - initialLPTokens; // Remainder got to presale participants.
        if(launchTime_ == 0) launchTime_ = block.timestamp + 1 hours;
        launchTime = launchTime_;
    }

    /**
     * Seconds until launch.
     * @return uint256 Seconds remaining until protocol launch time.
     */
    function secondsUntilLaunch() public view returns (uint256)
    {
        if(launchTime < block.timestamp) return 0;
        return launchTime - block.timestamp;
    }

    /**
     * Launch price.
     * @return uint256 Launch price.
     */
    function launchPrice() external view returns (uint256)
    {
        if(_launchPrice > 0) return _launchPrice;
        if(initialLPPairTokens == 0) return 0;
        return initialLPPairTokens * 1e18 / initialLPTokens;
    }


    /**
     * Presale.
     * @param amount_ Amount of pair token to spend.
     */
    function presale(uint256 amount_) external whenNotLaunched
    {
        IERC20 _pairToken_ = IERC20(_getContract("PairToken"));
        if(!_pairToken_.transferFrom(msg.sender, address(this), amount_)) revert TransferFailed();
        initialLPPairTokens += amount_;
        presaleBalance[msg.sender] += amount_;
        emit PresalePurchased(msg.sender, amount_);
    }

    /**
     * Launch.
     */
    function launch() external whenNotLaunched
    {
        if(secondsUntilLaunch() > 0) revert ProtocolNotLaunched();
        if(initialLPPairTokens == 0) revert NotEnoughPairTokenBalance();
        IERC20 _pairToken_ = IERC20(_getContract("PairToken"));
        IUniswapV2Router02 _router_ = IUniswapV2Router02(_getContract("Router"));
        _approve(address(this), address(_router_), initialLPTokens);
        _pairToken_.approve(address(_router_), initialLPPairTokens);
        _router_.addLiquidity(
            address(this),
            address(_pairToken_),
            initialLPTokens,
            initialLPPairTokens,
            0,
            0,
            address(0), // Send LP tokens to hell!
            block.timestamp
        );
        // Get LP details.
        _pair = IUniswapV2Factory(_router_.factory()).getPair(address(this), address(_pairToken_));
        launchTime = block.timestamp;
        _launchPrice = initialLPPairTokens * 1e18 / initialLPTokens;
        emit ProtocolLaunched(launchTime, _launchPrice);
    }

    /**
     * Transfer override.
     * @param from_ Address to transfer from.
     * @param to_ Address to transfer to.
     * @param amount_ Amount to transfer.
     * @dev Determine if it's a buy or sell, and tax accordingly.
     */
    function _transfer(
        address from_,
        address to_,
        uint256 amount_
    ) internal override {
        // If the pair address isn't set yet, just transfer.
        if(_pair == address(0)) return super._transfer(from_, to_, amount_);
        // If it's not a buy or sell, distribute taxes and transfer.
        if (to_ != _pair && from_ != _pair) {
            ITaxHandler(_getContract("TaxHandler")).distribute();
            return super._transfer(from_, to_, amount_);
        }
        // Otherwise, tax it.
        uint256 _taxAmount_ = amount_ * swapTax / 100;
        uint256 _sendAmount_ = amount_ - _taxAmount_;
        super._transfer(from_, _getContract("TaxHandler"), _taxAmount_);
        // Finally, transfer the amount.
        super._transfer(from_, to_, _sendAmount_);
    }


    /**
     * When not launched modifier.
     */
    modifier whenNotLaunched()
    {
        if(_pair != address(0)) revert ProtocolAlreadyLaunched();
        _;
    }

    /**
     * When launched modifier.
     */
    modifier whenLaunched()
    {
        if(_pair == address(0)) revert ProtocolNotLaunched();
        _;
    }
}