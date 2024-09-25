module signature_verifier::eth_verifier {
    use std::signer;
    use std::option::{Self, Option};
    use std::vector;
    use std::hash::sha2_256;

    use aptos_std::secp256k1::{Self, ECDSASignature};
    use aptos_std::aptos_hash;

    use aptos_framework::from_bcs;


    const SIGNATURE_NUM_BYTES: u64 = 64;
    const ETH_ADDRESS_SIZE: u64 = 20;

    // Errors
    const ERR_MALFORMED_ETH_ADDRESS: u64 = 1;
    const ERR_MALFORMED_SIGNATURE: u64 = 2;
    const ERR_APTOS_ADDRESS_MISMATCH: u64 = 3;
    const ERR_ETH_ADDRESS_MISMATCH: u64 = 4;
    const ERR_SIGNATURE_RECOVERY_FAILED: u64 = 5;


    struct EthLinkedAccount has key, store {
        eth_address: vector<u8>,
    }

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
        aptos_address: &signer,  // The Aptos account (as the caller)
        message: vector<u8>,     // The message to be signed (Aptos address)
        recovery_id: u8,         // The 'v' value from the Ethereum signature (recovery id)
        signature: &ECDSASignature,  // The signature (r + s) from the Ethereum signature
        eth_address_bytes: vector<u8>      // The expected Ethereum address (20 bytes)
    ) {
        // Ensure the Ethereum address is 20 bytes
        assert!(vector::length(&eth_address_bytes) == ETH_ADDRESS_SIZE, ERR_MALFORMED_ETH_ADDRESS);

        std::debug::print(&message);
        std::debug::print(&recovery_id);
        
        // Hash the message (Aptos address) using SHA2-256
        let hashed_message = aptos_hash::keccak256(message);

        std::debug::print(&hashed_message);

        // Recover the public key from the hashed message and signature
        let recovered_key_option = secp256k1::ecdsa_recover(hashed_message, recovery_id, signature);

        // Ensure the public key was recovered successfully
        assert!(option::is_some(&recovered_key_option), ERR_SIGNATURE_RECOVERY_FAILED);

        // Extract the recovered public key
        let recovered_key = option::extract(&mut recovered_key_option);

        // Hash the recovered public key using keccak256 to derive the Ethereum address
        std::debug::print(&secp256k1::ecdsa_raw_public_key_to_bytes(&recovered_key));
        let recovered_eth_address_bytes = aptos_hash::keccak256(secp256k1::ecdsa_raw_public_key_to_bytes(&recovered_key));

        // Compare the last 20 bytes of the keccak256 hash to the provided Ethereum address
        let recovered_eth_address_bytes_slice = vector::slice(&recovered_eth_address_bytes, 12, 32);  // Extract last 20 bytes of keccak hash
        vector::zip(recovered_eth_address_bytes_slice, eth_address_bytes, |recovered_byte, address_byte| {
            assert!((recovered_byte as u8) == (address_byte as u8), ERR_ETH_ADDRESS_MISMATCH);
        });

        assert!(signer::address_of(aptos_address) == from_bcs::to_address(message), ERR_APTOS_ADDRESS_MISMATCH);
    }

    #[test_only]
    use aptos_framework::account;

    #[test(user = @0x2930f2c0c4893773f86a66eb8eada5eedd6495566e30e54b1a484eeaeb366c99)]
    public fun test_verify_accounts(user: &signer) {
        let aptos_account = account::create_account_for_test(signer::address_of(user));
        let eth_address = x"1915267aeF02ED299b0347a3C70c2B6D82D62f46"; // Your Ethereum address
        let message = x"2930f2c0c4893773f86a66eb8eada5eedd6495566e30e54b1a484eeaeb366c99";
        let signature_bytes = x"7ada9ff6151fb137c153ad1e98220433fa303837ad33509a7d2645390617433060fbaf5eaaedb1f39c31aa34c28092701774f22404e67f4df3e0e014f6e9cd4e"; // r + s combined
        let recovery_id = 1; // Recovery ID

        verify_accounts_entry(&aptos_account, message, recovery_id, signature_bytes, eth_address);
    }
}
