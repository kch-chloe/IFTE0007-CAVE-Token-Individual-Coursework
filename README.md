# CAVE Token — Chateau Access and Vintage Entitlement

**Module:** IFTE0007 Decentralised Finance and Blockchain, UCL  
**Network:** Sepolia Testnet  
**Compiler:** Solidity 0.4.21  

---

## Overview

CAVE is an ERC-20 fungible token representing a tokenised claim on the annual wine revenue stream and direct purchase entitlement rights of Château Margaux, Bordeaux, France. It embeds two independent economic rights within a single token:

- **Revenue distribution right** — pro-rata share of 30% of total annual estate revenue
- **Wine purchase entitlement right** — 20% direct purchase discount for holders of 100+ tokens

Both parameters are hardcoded as immutable constants and cannot be altered after deployment.

---

## Contract Files

| File | Description |
|---|---|
| `contracts/EIP20_CAVE.sol` | Main CAVE token contract |
| `contracts/EIP20Interface.sol` | EIP-20 interface inherited by CAVE |

---

## Custom Functions

| Function | Caller | Description |
|---|---|---|
| `mintVintage(year, supply)` | Admin | Mints fixed supply after harvest confirmation |
| `activateEntitlement()` | Admin | Makes wine discount available to eligible holders |
| `loadRevenue(totalAmount)` | Admin | Loads confirmed revenue — 30% calculated automatically |
| `claimDistribution()` | Investor | Claims pro-rata revenue share |
| `useEntitlement()` | Investor | Exercises 20% wine discount — verified on-chain |
| `closeVintage()` | Admin | Burns remaining admin tokens — cycle ends |

---

## Disclaimer

This contract is a proof-of-concept submitted for academic purposes as part of IFTE0007 at UCL. It is deployed on the Sepolia testnet only and is not intended for production use. 
