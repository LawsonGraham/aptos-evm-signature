# USAGE

This example is used to show how a user can relay an ETH signed message onto Aptos and verify.

## EVM SIDE

Go into `evm/` and then create `.env` from the `.env.example`. Put in your ethereum wallet Private Key (with `0x`), and your aptos address (with `0x`).

from root, run:

`make install`

then 

`make sign`

In the logs, see the signature information, and copy the `For testing` block.

## APTOS SIDE

see the test `test_verify_accounts` in `aptos/signature_verifier/sources/eth_verifier.move`.

Paste the block of variables logged in `For testing` over the current values

finally, run

`make test`
