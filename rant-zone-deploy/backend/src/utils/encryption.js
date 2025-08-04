const crypto = require('crypto');

const ALGORITHM = 'aes-256-gcm';
const IV_LENGTH = 16;
const TAG_LENGTH = 16;

function encryptMessage(message) {
  const iv = crypto.randomBytes(IV_LENGTH);
  const cipher = crypto.createCipher(ALGORITHM, process.env.ENCRYPTION_KEY);
  
  let encrypted = cipher.update(message, 'utf8', 'hex');
  encrypted += cipher.final('hex');
  
  const tag = cipher.getAuthTag();
  
  return {
    encryptedData: encrypted,
    iv: iv.toString('hex'),
    tag: tag.toString('hex')
  };
}

function decryptMessage(encryptedData, iv, tag) {
  const decipher = crypto.createDecipher(ALGORITHM, process.env.ENCRYPTION_KEY);
  decipher.setAuthTag(Buffer.from(tag, 'hex'));
  
  let decrypted = decipher.update(encryptedData, 'hex', 'utf8');
  decrypted += decipher.final('utf8');
  
  return decrypted;
}

function generateKeyPair() {
  const { publicKey, privateKey } = crypto.generateKeyPairSync('ec', {
    namedCurve: 'P-256',
    publicKeyEncoding: {
      type: 'spki',
      format: 'pem'
    },
    privateKeyEncoding: {
      type: 'pkcs8',
      format: 'pem'
    }
  });
  
  return { publicKey, privateKey };
}

function deriveSharedSecret(privateKey, publicKey) {
  const sharedSecret = crypto.diffieHellman({
    privateKey: privateKey,
    publicKey: publicKey
  });
  
  return crypto.createHash('sha256').update(sharedSecret).digest('hex');
}

module.exports = {
  encryptMessage,
  decryptMessage,
  generateKeyPair,
  deriveSharedSecret
}; 