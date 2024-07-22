// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

contract TaxSwap is Ownable {
    address public feesReceiver;
    address public token;
    address public pairToken;
    IUniswapV2Router02 public router; // PCS Router

    event SetRouter(address _address);
    event SetToken(address _address);
    event SetPairToken(address _address);
    event SetFeesReceiver(address _address);
    event Withdraw(uint256 _balance);
    event WithdrawTokensToFeesReceiver(uint256 _balance);
    event DistributeFees(uint256 _balance);
    event Error(string reason);

    constructor(
        address initialOwner,
        address _router,
        address _token,
        address _pairToken,
        address _feesReceiver
    ) payable Ownable(initialOwner) {
        feesReceiver = _feesReceiver;
        token = _token;
        pairToken = _pairToken;
        router = IUniswapV2Router02(_router);

        IERC20(token).approve(address(router), type(uint256).max);
    }

    modifier validAddress(address _address) {
        require(_address != address(0x0), "Invalid address");
        _;
    }

    receive() external payable {}

    /** Swaps all the tokens inside the contract into BNB and transfers the resulting BNB to a treasury/fees wallet. */
    function _swapFeesAndSendToFeesReceiver(uint256 _amount) private {
        address[] memory path = new address[](2);
        path[0] = address(token);
        path[1] = pairToken;

        if (IERC20(token).allowance(address(this), address(router)) < _amount) {
            IERC20(token).approve(address(router), type(uint256).max);
        }

        try
            router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                _amount,
                0,
                path,
                feesReceiver,
                block.timestamp
            )
        {} catch Error(string memory reason) {
            IERC20(token).transfer(feesReceiver, _amount);
            emit Error(reason);
        }

        emit DistributeFees(_amount);
    }

    function setRouter(
        address _address
    ) external onlyOwner validAddress(_address) {
        router = IUniswapV2Router02(_address);
        emit SetRouter(_address);
    }

    function setFeesReceiver(
        address _address
    ) external onlyOwner validAddress(_address) {
        feesReceiver = _address;
        emit SetFeesReceiver(_address);
    }

    function setToken(
        address _address
    ) external onlyOwner validAddress(_address) {
        token = _address;
        emit SetToken(_address);
    }

    function setPairToken(
        address _address
    ) external onlyOwner validAddress(_address) {
        pairToken = _address;
        emit SetPairToken(_address);
    }

    /** Withdraw all BNB to the deployer/owner wallet. */
    function withdraw() public onlyOwner {
        uint256 _balance = address(this).balance;
        if (_balance == 0) {
            revert("Insufficient funds");
        }
        payable(msg.sender).transfer(_balance);
        emit Withdraw(_balance);
    }

    /** Withdraw all contract tokens (this) to the fees receiver without swapping them to BNB */
    function withdrawTokensToFeesReceiver() public onlyOwner {
        uint256 _balance = IERC20(token).balanceOf(address(this));
        if (_balance == 0) {
            revert("Insufficient funds");
        }
        IERC20(token).transfer(feesReceiver, _balance);
        emit WithdrawTokensToFeesReceiver(_balance);
    }

    function distributeFees() public onlyOwner {
        uint256 _balance = IERC20(token).balanceOf(address(this));
        if (_balance == 0) {
            revert("Insufficient funds");
        }
        _swapFeesAndSendToFeesReceiver(_balance);
        emit DistributeFees(_balance);
    }
}
