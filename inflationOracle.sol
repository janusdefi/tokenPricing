// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract InflationOracle {


    uint256 public inflationRate; // Inflation rate in basis points



    event InflationRateUpdated(uint256 newRate);

    function updateInflationRate(uint256 newRate) external {
        require(newRate <= 10000, "Rate exceeds 100%");
        inflationRate = newRate;
        emit InflationRateUpdated(newRate);
    }

    function getInflationRate() external view returns (uint256) {
        return inflationRate;
    }
}
