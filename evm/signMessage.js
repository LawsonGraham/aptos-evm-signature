const { ethers, Signature, SigningKey, hashMessage, keccak256, concat, toUtf8Bytes, MessagePrefix, sha256, hexlify, getBytes} = require('ethers');
require('dotenv').config();

// Define the user's Ethereum private key WITH `0x` prefix
const privateKey = process.env.ETHEREUM_PRIVATE_KEY;
const wallet = new ethers.Wallet(privateKey);

// The message you want to sign (in this case, the Aptos address) WITH `0x` prefix
const aptosAddress = process.env.APTOS_ADDRESS;

// Function to manually construct Uint8Array in the same way Aptos does
function hexStringToBytes(hexString) {
    // Remove '0x' if present
    if (hexString.startsWith('0x')) {
        hexString = hexString.slice(2);
    }

    // Ensure even length for the hex string
    if (hexString.length % 2 !== 0) {
        throw new Error('Invalid hex string: must have an even number of characters.');
    }

    // Convert hex string to Uint8Array
    const byteArray = new Uint8Array(hexString.length / 2);
    for (let i = 0; i < hexString.length; i += 2) {
        byteArray[i / 2] = parseInt(hexString.substr(i, 2), 16);
    }

    return byteArray;
}

// Function to sign the message using the Ethereum wallet
async function signMessage() {
    console.log(`Signing the Aptos Address ${aptosAddress} with the Ethereum Wallet ${wallet.address}`);

    // Sign the message (this implcitly hashes the message)
    const message = hexStringToBytes(aptosAddress);
    const signature = await wallet.signMessage(message);

    // Split the signature into r, s, and v components
    const signatureSplit = Signature.from(signature);

    console.log(`For testing:
        let eth_address = x"${wallet.address.slice(2)}"; // User Ethereum address
        let aptos_address = x"${aptosAddress.slice(2)}"; // User Aptos address
        let signature_bytes = x"${signature.slice(2, 130)}"; // r + s combined
        let recovery_id = ${signatureSplit.v % 27}; // Recovery ID
    `);
    
    return signatureSplit;
}

// Call the function
signMessage().then((signature) => {
    console.log('Signature components:', signature);
}).catch((error) => {
    console.error('Error signing message:', error);
});
