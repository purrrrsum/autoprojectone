export interface EncryptionKey {
  publicKey: string;
  privateKey: string;
  sharedSecret?: string;
}

export interface EncryptedMessage {
  encryptedData: string;
  iv: string;
  tag: string;
}

class EncryptionService {
  private keyPair: CryptoKeyPair | null = null;
  private sharedSecret: CryptoKey | null = null;

  async initialize(): Promise<EncryptionKey> {
    try {
      this.keyPair = await window.crypto.subtle.generateKey(
        {
          name: 'ECDH',
          namedCurve: 'P-256'
        },
        true,
        ['deriveKey']
      );

      const publicKeyBuffer = await window.crypto.subtle.exportKey(
        'spki',
        this.keyPair.publicKey
      );
      const publicKey = this.arrayBufferToBase64(publicKeyBuffer);

      const privateKeyBuffer = await window.crypto.subtle.exportKey(
        'pkcs8',
        this.keyPair.privateKey
      );
      const privateKey = this.arrayBufferToBase64(privateKeyBuffer);

      return { publicKey, privateKey };
    } catch (error) {
      console.error('Encryption initialization failed:', error);
      throw new Error('Failed to initialize encryption');
    }
  }

  async deriveSharedSecret(partnerPublicKey: string): Promise<void> {
    try {
      const partnerPublicKeyBuffer = this.base64ToArrayBuffer(partnerPublicKey);
      const importedPublicKey = await window.crypto.subtle.importKey(
        'spki',
        partnerPublicKeyBuffer,
        {
          name: 'ECDH',
          namedCurve: 'P-256'
        },
        false,
        []
      );

      this.sharedSecret = await window.crypto.subtle.deriveKey(
        {
          name: 'ECDH',
          public: importedPublicKey
        },
        this.keyPair!.privateKey,
        {
          name: 'AES-GCM',
          length: 256
        },
        false,
        ['encrypt', 'decrypt']
      );
    } catch (error) {
      console.error('Shared secret derivation failed:', error);
      throw new Error('Failed to derive shared secret');
    }
  }

  async encrypt(message: string): Promise<EncryptedMessage> {
    if (!this.sharedSecret) {
      throw new Error('Shared secret not established');
    }

    try {
      const iv = window.crypto.getRandomValues(new Uint8Array(12));
      const encodedMessage = new TextEncoder().encode(message);
      const encryptedBuffer = await window.crypto.subtle.encrypt(
        {
          name: 'AES-GCM',
          iv: iv
        },
        this.sharedSecret,
        encodedMessage
      );

      return {
        encryptedData: this.arrayBufferToBase64(encryptedBuffer),
        iv: this.arrayBufferToBase64(iv),
        tag: ''
      };
    } catch (error) {
      console.error('Encryption failed:', error);
      throw new Error('Failed to encrypt message');
    }
  }

  async decrypt(encryptedMessage: EncryptedMessage): Promise<string> {
    if (!this.sharedSecret) {
      throw new Error('Shared secret not established');
    }

    try {
      const encryptedData = this.base64ToArrayBuffer(encryptedMessage.encryptedData);
      const iv = this.base64ToArrayBuffer(encryptedMessage.iv);
      
      const decryptedBuffer = await window.crypto.subtle.decrypt(
        {
          name: 'AES-GCM',
          iv: new Uint8Array(iv)
        },
        this.sharedSecret,
        encryptedData
      );

      return new TextDecoder().decode(decryptedBuffer);
    } catch (error) {
      console.error('Decryption failed:', error);
      throw new Error('Failed to decrypt message');
    }
  }

  private arrayBufferToBase64(buffer: ArrayBuffer): string {
    const bytes = new Uint8Array(buffer);
    let binary = '';
    for (let i = 0; i < bytes.byteLength; i++) {
      binary += String.fromCharCode(bytes[i]);
    }
    return btoa(binary);
  }

  private base64ToArrayBuffer(base64: string): ArrayBuffer {
    const binary = atob(base64);
    const bytes = new Uint8Array(binary.length);
    for (let i = 0; i < binary.length; i++) {
      bytes[i] = binary.charCodeAt(i);
    }
    return bytes.buffer;
  }

  generateSessionId(): string {
    return Math.random().toString(36).substring(2, 15) + Math.random().toString(36).substring(2, 15);
  }

  isSupported(): boolean {
    return typeof window !== 'undefined' && 
           window.crypto && 
           window.crypto.subtle &&
           typeof window.crypto.subtle.generateKey === 'function';
  }
}

export const encryptionService = new EncryptionService(); 