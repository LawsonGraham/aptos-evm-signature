const { ethers, Signature, sha256, toUtf8Bytes} = require('ethers');
require('dotenv').config();

// Define the user's Ethereum private key (secure this in a real environment)
const privateKey = process.env.ETHEREUM_PRIVATE_KEY;
const wallet = new ethers.Wallet(privateKey);

// The message you want to sign (in this case, the Aptos address)
const aptosAddress = process.env.APTOS_ADDRESS;

// Function to hash the message using SHA2-256
function hashMessage(message) {
    return sha256(message); // SHA2-256 hashing
}

// Function to sign the message using the Ethereum wallet
async function signMessage() {
    // Hash the Aptos address before signing it
    const hashedMessage = hashMessage(aptosAddress);
    console.log('Hashed Aptos Address (SHA2-256):', hashedMessage);

    // Sign the hashed message
    const signature = await wallet.signMessage(hashedMessage);
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
