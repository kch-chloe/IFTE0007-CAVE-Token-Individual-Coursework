# CAVE Token — Chateau Access and Vintage Entitlement 

**Module:** IFTE0007 Decentralised Finance and Blockchain, UCL 

## Overview

CAVE is an ERC-20 fungible token representing a tokenised claim on the annual wine revenue stream and direct purchase entitlement rights of Château Margaux, Bordeaux, France. It embeds two independent economic rights within a single token:

- **Revenue distribution right** — pro-rata share of 30% of total annual estate revenue
- **Wine purchase entitlement right** — 20% direct purchase discount for holders of 100+ tokens

Both parameters are hardcoded as immutable constants and cannot be altered after deployment.

## Deployment

|||
|---|---|
| **Network** | Sepolia Testnet |
| **Standard** | ERC-20 (OpenZeppelin) |
| **Solidity Version** | ^0.8.0 |
| **Contract Address** | 0x8b02a78a192fc84c8E4Df8AbE756917Ddc732956 |
| **Token Symbol** | CAVE |
| **Total Supply** | 298,000 |
| **Decimals** | 0 |

## Key Design Features

- **OpenZeppelin ERC-20** — standard transfer, approve, allowance, and balanceOf functions inherited automatically
- **Decimals = 0** — no fractional tokens
- **Vintage year stamping** — `_update()` override stamps each recipient with the current vintage year on every token transfer, preventing previous cycle tokens from claiming current cycle rights
- **Independent rights activation** — entitlement right activated separately from revenue loading via `activateEntitlement()`
- **Immutable constants** — `DISTRIBUTION_PERCENTAGE = 30` and `DISCOUNT_BPS = 2000` cannot be changed by anyone after deployment

## Contract Functions

| Function | Caller | Description |
|---|---|---|
| `mintVintage(year, supply)` | Admin | Opens a new vintage cycle and mints fixed supply after harvest confirmation |
| `activateEntitlement()` | Admin | Activates wine purchase entitlement right independently of revenue loading |
| `loadRevenue(totalAmount)` | Admin | Loads verified estate revenue — 30% holder distribution calculated automatically |
| `claimDistribution()` | Token holder | Emits on-chain proof of pro-rata revenue claim — once per wallet per cycle |
| `useEntitlement()` | Token holder | Records entitlement activation as on-chain proof of discount eligibility — once per wallet per cycle |
| `closeVintage()` | Admin | Burns all remaining admin-held tokens and closes the vintage cycle |

## Vintage Cycle

Each cycle mirrors Château Margaux's natural production calendar:

1. Admin calls `mintVintage()` after harvest — 298,000 tokens minted to admin wallet
2. Admin distributes tokens to investors via standard ERC-20 `transfer()`
3. Admin calls `activateEntitlement()` — eligible holders can exercise their discount
4. Admin calls `loadRevenue()` after vintage sale — distribution right activated
5. Holders call `claimDistribution()` to generate on-chain proof of their revenue claim
6. Admin calls `closeVintage()` — remaining admin tokens permanently burned

## Disclaimer

This contract is a proof-of-concept submitted for academic purposes as part of IFTE0007 at UCL. It is deployed on the Sepolia testnet only and is not intended for production use.
