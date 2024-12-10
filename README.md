# tokenPricing

How It Works

1. Minting/Burning:

The owner (protocol governance or AI agent) mints or burns tokens based on inflation data fetched from the oracle.



2. Dynamic Reserves:

Reserves can be adjusted manually (later replaced with AI-managed contracts).

Transaction fees can be redirected to the treasury.



3. Oracle Integration:

The oracle contract allows updates to the inflation rate (mocked here; can be replaced with Chainlink oracles).


**Lending Protocol:**


Features in the Contract

1. Collateralization Ratio:

Ensures users deposit sufficient collateral (e.g., 150% of the loan amount).



2. Inflation Adjustment:

Debt is adjusted dynamically based on inflation using the oracle's data.



3. Repayment:

Borrowers can repay their loans partially or fully.



4. Collateral Withdrawal:

Borrowers can withdraw collateral as long as the collateralization ratio is maintained.



5. Liquidation:

Positions are liquidated if collateral falls below the liquidation threshold (e.g., 110%).





---
Examples:

1. Deposit Collateral and Borrow:

const tx = await lendingContract.depositAndBorrow(debtAmount, { value: collateralAmount });


2. Repay Loan:

await flatcoin.approve(lendingContract.address, repaymentAmount);
const tx = await lendingContract.repayLoan(repaymentAmount);


3. Withdraw Collateral:

const tx = await lendingContract.withdrawCollateral(collateralAmount);


4. Liquidate a Position:

const tx = await lendingContract.liquidate(borrowerAddress);
