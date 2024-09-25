const { ethers, Signature, SigningKey, hashMessage, keccak256, concat, toUtf8Bytes, MessagePrefix, sha256, hexlify, getBytes} = require('ethers');
require('dotenv').config();

// Define the user's Ethereum private key (secure this in a real environment)
const privateKey = process.env.ETHEREUM_PRIVATE_KEY;
const wallet = new ethers.Wallet(privateKey);

// The message you want to sign (in this case, the Aptos address) WITH `0x` prefix
const aptosAddress = process.env.APTOS_ADDRESS;

// Function to manually construct Uint8Array
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
    // Sign the message (this implcitly hashes the message)
    const publicKey = SigningKey.computePublicKey(process.env.ETHEREUM_PRIVATE_KEY);

    console.log("Pub key: ", publicKey);
    console.log("Address: ", wallet.address)
    console.log("Message: ", aptosAddress);
    let message = hexStringToBytes(aptosAddress);
    
    console.log("MessagePrefix: ", MessagePrefix);
    console.log("Hashed Message Raw: ", keccak256(concat([
        toUtf8Bytes(MessagePrefix),
        toUtf8Bytes(String(message.length)),
        message
    ])));
    console.log("Hashed Message: ", hashMessage(message));


    const signature = await wallet.signMessage(message);
    console.log('Signature:', signature);

    // Split the signature into r, s, and v components
    const signatureSplit = Signature.from(signature);
    console.log('r:', signatureSplit.r);
    console.log('s:', signatureSplit.s);
    console.log('v:', signatureSplit.v);  // Recovery ID (1 or 0, typically)

    return signatureSplit;
}

// Call the function
signMessage().then((signature) => {
    console.log('Signature components:', signature);
}).catch((error) => {
    console.error('Error signing message:', error);
});
