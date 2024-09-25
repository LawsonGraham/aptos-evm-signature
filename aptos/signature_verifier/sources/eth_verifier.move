module signature_verifier::eth_verifier {
    use std::signer;
    use std::option;
    use std::vector;

    use aptos_std::secp256k1::{Self, ECDSASignature};
    use aptos_std::aptos_hash;

    use aptos_framework::from_bcs;

    // Constants
    const SIGNATURE_NUM_BYTES: u64 = 64;
    const ETH_ADDRESS_SIZE: u64 = 20;
    const APTOS_ADDRESS_SIZE: u64 = 32;

    // Prefix for Ethereum signed messages is "\x19Ethereum Signed Message:\n + APTOS_ADDRESS_SIZE"
    const ETH_MESSAGE_PREFIX: vector<u8> = b"\x19Ethereum Signed Message:\n32";

    // Errors
    const ERR_MALFORMED_APTOS_ADDRESS: u64 = 1;
    const ERR_MALFORMED_ETH_ADDRESS: u64 = 2;
    const ERR_MALFORMED_SIGNATURE: u64 = 3;
    const ERR_APTOS_ADDRESS_MISMATCH: u64 = 4;
    const ERR_ETH_ADDRESS_MISMATCH: u64 = 5;
    const ERR_SIGNATURE_RECOVERY_FAILED: u64 = 6;
    const ERR_INVALID_RECOVERY_ID: u64 = 7;

    public entry fun verify_accounts_entry(
        aptos_address: &signer,
        message: vector<u8>,
        recovery_id: u8,
        signature_bytes: vector<u8>,
        eth_address: vector<u8>
    ) {
        // Ensure the signature is 64 bytes (r + s)
        assert!(std::vector::length(&signature_bytes) == SIGNATURE_NUM_BYTES, ERR_MALFORMED_SIGNATURE);

        let signature = secp256k1::ecdsa_signature_from_bytes(signature_bytes);
        verify_accounts(aptos_address, message, recovery_id, &signature, eth_address);
    }

    /// Function to link Ethereum address with Aptos account
    public fun verify_accounts(
        user: &signer,  // The Aptos account (as the caller)
        aptos_address: vector<u8>,     // The message to be signed (Aptos address)
        recovery_id: u8,         // The 'v' value from the Ethereum signature (recovery id)
        signature: &ECDSASignature,  // The signature (r + s) from the Ethereum signature
        eth_address_bytes: vector<u8>      // The expected Ethereum address (20 bytes)
    ) {
        // Ensure the Ethereum address is 20 bytes
        assert!(vector::length(&eth_address_bytes) == ETH_ADDRESS_SIZE, ERR_MALFORMED_ETH_ADDRESS);
        assert!(vector::length(&aptos_address) == APTOS_ADDRESS_SIZE, ERR_MALFORMED_APTOS_ADDRESS);
        assert!(recovery_id == 0 || recovery_id == 1, ERR_INVALID_RECOVERY_ID);

        // Construct and hash the message (Aptos address) using Keccak-256
        let full_message = vector::empty();
        vector::append(&mut full_message, ETH_MESSAGE_PREFIX);
        vector::append(&mut full_message, aptos_address);
        let hashed_message = aptos_hash::keccak256(full_message);

        // Recover and extract the public key from the hashed message and signature
        let recovered_key_option = secp256k1::ecdsa_recover(hashed_message, recovery_id, signature);
        assert!(option::is_some(&recovered_key_option), ERR_SIGNATURE_RECOVERY_FAILED);
        let recovered_key = option::extract(&mut recovered_key_option);

        // Hash the recovered public key using keccak256 to derive the Ethereum address
        let recovered_eth_address_bytes = aptos_hash::keccak256(secp256k1::ecdsa_raw_public_key_to_bytes(&recovered_key));
        let recovered_eth_address_bytes_slice = vector::slice(&recovered_eth_address_bytes, 12, 32);  // Extract last 20 bytes of keccak hash
        
        // Assert equality of both Ethereum address and Aptos address
        vector::zip(recovered_eth_address_bytes_slice, eth_address_bytes, |recovered_byte, address_byte| {
            assert!((recovered_byte as u8) == (address_byte as u8), ERR_ETH_ADDRESS_MISMATCH);
        });
        assert!(signer::address_of(user) == from_bcs::to_address(aptos_address), ERR_APTOS_ADDRESS_MISMATCH);
    }

    #[test_only]
    use aptos_framework::account;

    #[test(user = @0x2930f2c0c4893773f86a66eb8eada5eedd6495566e30e54b1a484eeaeb366c99)]
    public fun test_verify_accounts(user: &signer) {
        let aptos_account = account::create_account_for_test(signer::address_of(user));
        let eth_address = x"1915267aeF02ED299b0347a3C70c2B6D82D62f46"; // User Ethereum address
        let aptos_address = x"2930f2c0c4893773f86a66eb8eada5eedd6495566e30e54b1a484eeaeb366c99"; // User Aptos address
        let signature_bytes = x"2237a42f49806d7cfb7442008d7701a1548976e0881640d53aa731f9b98ebd29753e67371ff3b4655ec16f4dcfa1c658e23c78e155822fb95aadb8ae12764d3e"; // r + s combined
        let recovery_id = 1; // Recovery ID

        verify_accounts_entry(&aptos_account, aptos_address, recovery_id, signature_bytes, eth_address);
    }
}
