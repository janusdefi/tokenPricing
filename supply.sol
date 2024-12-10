// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IInflationOracle {
    function getInflationRate() external view returns (uint256);
}

contract JanusFlatcoin is ERC20, Ownable {
    uint256 public targetInflationRate; // Inflation target in basis points (e.g., 200 = 2%)
    address public inflationOracle; // Oracle providing inflation rate
    address public treasury; // Address for treasury management
    uint256 public reserve; // Protocol reserves in ETH or other assets
    uint256 public constant BASIS_POINTS = 10000;

    event Minted(address indexed user, uint256 amount);
    event Burned(address indexed user, uint256 amount);
    event TargetInflationRateUpdated(uint256 newRate);
    event ReserveUpdated(uint256 newReserve);

construct(address _inflationOracle, address _treasury) ERC20("Janus Flatcoin", "JFT"){

require(_inflationOracle != address(0), "Invalid oracle address");
        require(_treasury != address(0), "Invalid treasury address");
        inflationOracle = _inflationOracle;
        treasury = _treasury;
        targetInflationRate = 200; // Default to 2%
 }


// Mint new flatcoins based on inflation data
    function mint(uint256 amount) external onlyOwner {
        uint256 currentInflationRate = _getInflationRate();
        require(currentInflationRate <= targetInflationRate, "Inflation exceeds target");

        _mint(msg.sender, amount);
        emit Minted(msg.sender, amount);
    }


    // Burn flatcoins to reduce supply
    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
        emit Burned(msg.sender, amount);
    }

    // Adjust target inflation rate
    function updateTargetInflationRate(uint256 newRate) external onlyOwner {
        require(newRate <= BASIS_POINTS, "Rate exceeds 100%");
        targetInflationRate = newRate;
        emit TargetInflationRateUpdated(newRate);
    }

    // Update reserves (e.g., ETH, RWAs) in treasury
    function updateReserve(uint256 newReserve) external onlyOwner {
        reserve = newReserve;
        emit ReserveUpdated(newReserve);
    }

    // Fetch inflation rate from oracle
    function _getInflationRate() internal view returns (uint256) {
        return IInflationOracle(inflationOracle).getInflationRate();
    }

    // Treasury management: Transfer fees to the treasury
    function transferToTreasury(uint256 amount) external onlyOwner {
        require(amount <= reserve, "Insufficient reserve");
        reserve -= amount;
        payable(treasury).transfer(amount);
    }

    // Allow the contract to receive ETH for reserves
    receive() external payable {
        reserve += msg.value;
        emit ReserveUpdated(reserve);
    }
}













    
