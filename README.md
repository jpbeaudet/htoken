# htoken
re-enactment of htoken project
## Overview
The HToken is an ERC20 token with additional functionality. It starts with a total supply of 0 and can only be "minted" by exchanging PaxGold tokens. The HToken can also be "burned" to receive its corresponding value in PaxGold. When transferring HToken, a small burn fee is applied to the transferred amount.
## Functions
####  mint
Mints new HToken in exchange for PaxGold.

## Parameters
_value: The amount of PaxGold to exchange for HToken.
## Requirements
The caller must have sufficient PaxGold balance.
#### burn
Burns HToken in exchange for PaxGold.

## Parameters
_value: The amount of HToken to burn.
## Requirements
The caller must have sufficient HToken balance.
#### transfer
Transfers HToken from the sender to the recipient. A burn fee is applied to the transferred amount.

## Parameters
recipient: The address of the recipient.
amount: The amount of HToken to transfer.
## Variables
totalSupply
The total supply of HToken.

## totalReserve
The total reserve of PaxGold.

## value
The current value of 1 HToken in PaxGold.

## burnFee
The burn fee, expressed as a percentage of the transferred amount.

## paxGold
The PaxGold contract.

## Constructor
## HToken
Creates a new HToken contract.

## Parameters
_paxGold: The address of the PaxGold contract.
_burnFee: The burn fee, expressed as a percentage of the transferred amount.
