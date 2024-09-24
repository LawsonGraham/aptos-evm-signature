# USAGE

## EVM SIDE

Go into `evm/` and then create `.env` from the `.env.example`. Put in your ethereum wallet Private Key (with `0x`), and your aptos address (with `0x`).

from root, run:

`make install`

then 

`make sign`

In the logs, see the signature information.

## APTOS SIDE

see the test `test_verify_accounts` in `aptos/signature_verifier/sources/eth_verifier.move`.

update the values to:

```
let eth_address = x"<YOUR ETH ADDRESS WITHOUT 0x>"; // Your Ethereum address
let message = x"<YOUR APTOS ADDRESS WITHOUT 0x>";
let signature_bytes = x"<R without 0x + S withough 0x>"; // r + s combined (64 bytes)
let recovery_id = 0 or 1; (0 if v == 27 and 1 if v == 28)
```

finally, run

`make test`