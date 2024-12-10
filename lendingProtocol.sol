
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IInflationOracle {
    function getInflationRate() external view returns (uint256);
}

contract JanusLending is Ownable {
    IERC20 public flatcoin; // JFT token
    IInflationOracle public inflationOracle; // Oracle for inflation data

    struct Loan {
        uint256 collateral; // Collateral amount in ETH
        uint256 debt; // Debt in JFT (adjusted for inflation)
        uint256 lastUpdated; // Timestamp of the last debt update
    }


mapping(address => Loan) public loans;
    uint256 public collateralizationRatio = 15000; // 150% collateralization (basis points)
    uint256 public liquidationThreshold = 11000; // 110% collateralization
    uint256 public totalDebt;

    event LoanCreated(address indexed borrower, uint256 collateral, uint256 debt);
    event LoanRepaid(address indexed borrower, uint256 amount);
    event CollateralWithdrawn(address indexed borrower, uint256 amount);
    event Liquidated(address indexed borrower, uint256 debt);

construct (address _flatcoin, address _inflationOracle) {
        flatcoin = IERC20(_flatcoin);
        inflationOracle = IInflationOracle(_inflationOracle);
    }


// Deposit collateral and take out a loan
    function depositAndBorrow(uint256 debtAmount) external payable {
        require(msg.value > 0, "Collateral must be greater than zero");
        require(debtAmount > 0, "Debt must be greater than zero");

        uint256 inflationRate = inflationOracle.getInflationRate();
        uint256 requiredCollateral = (debtAmount * collateralizationRatio) / 10000;

        require(msg.value >= requiredCollateral, "Insufficient collateral");

        // Create or update the loan
        Loan storage loan = loans[msg.sender];
        loan.collateral += msg.value;
        loan.debt += debtAmount;
        loan.lastUpdated = block.timestamp;

        totalDebt += debtAmount;

        // Mint flatcoins to the borrower
        flatcoin.transfer(msg.sender, debtAmount);

        emit LoanCreated(msg.sender, msg.value, debtAmount);
    }

    // Repay the loan
    function repayLoan(uint256 repaymentAmount) external {
        Loan storage loan = loans[msg.sender];
        require(loan.debt > 0, "No debt to repay");
        require(repaymentAmount <= loan.debt, "Repayment exceeds debt");

        // Adjust debt based on inflation
        uint256 inflationRate = inflationOracle.getInflationRate();
        loan.debt = adjustForInflation(loan.debt, inflationRate);

        // Deduct repayment
        loan.debt -= repaymentAmount;
        totalDebt -= repaymentAmount;

        // Burn flatcoins from the borrower
        flatcoin.transferFrom(msg.sender, address(this), repaymentAmount);

        emit LoanRepaid(msg.sender, repaymentAmount);
    }

    // Withdraw collateral
    function withdrawCollateral(uint256 amount) external {
        Loan storage loan = loans[msg.sender];
        require(loan.collateral >= amount, "Insufficient collateral");

        uint256 inflationRate = inflationOracle.getInflationRate();
        uint256 requiredCollateral = (loan.debt * collateralizationRatio) / 10000;

        require(
            loan.collateral - amount >= requiredCollateral,
            "Withdrawal would breach collateralization ratio"
        );

        loan.collateral -= amount;
        payable(msg.sender).transfer(amount);

        emit CollateralWithdrawn(msg.sender, amount);
    }

    // Liquidate undercollateralized positions
    function liquidate(address borrower) external onlyOwner {
        Loan storage loan = loans[borrower];
        require(loan.debt > 0, "No debt to liquidate");

        uint256 inflationRate = inflationOracle.getInflationRate();
        uint256 requiredCollateral = (loan.debt * liquidationThreshold) / 10000;

        require(loan.collateral < requiredCollateral, "Loan is not undercollateralized");

        // Seize collateral and reduce debt
        totalDebt -= loan.debt;
        loan.debt = 0;

        emit Liquidated(borrower, loan.debt);
    }

    // Adjust debt for inflation
    function adjustForInflation(uint256 debt, uint256 inflationRate) internal pure returns (uint256) {
        return (debt * (10000 + inflationRate)) / 10000;
    }
}
