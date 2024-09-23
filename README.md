cd evm

yarn sign

output:
Signature: 0x5dbc50bc3d6ab719d865f568ec5e70def5d431fa7d41c871ff7f89e04346998727ba665c3689b193f83f574829408c2fc2396f54c942d5f095f74b56428f24631c
r: 0x5dbc50bc3d6ab719d865f568ec5e70def5d431fa7d41c871ff7f89e043469987
s: 0x27ba665c3689b193f83f574829408c2fc2396f54c942d5f095f74b56428f2463
v: 28
Signature components: Signature { r: "0x5dbc50bc3d6ab719d865f568ec5e70def5d431fa7d41c871ff7f89e043469987", s: "0x27ba665c3689b193f83f574829408c2fc2396f54c942d5f095f74b56428f2463", yParity: 1, networkV: null }

cd ..

cd aptos

(update data in the test given the output from signature)

aptos move test --package-dir signature_verifier
