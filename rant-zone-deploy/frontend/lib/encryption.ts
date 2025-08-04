export interface EncryptionKey {
  publicKey: string;
  privateKey: string;
  sharedSecret?: string;
}

class EncryptionService {
  private keys: EncryptionKey | null = null;

  isSupported(): boolean {
    return typeof window !== 'undefined' && 
           'crypto' in window && 
           'subtle' in window.crypto &&
           'getRandomValues' in window.crypto;
  }

  async initialize(): Promise<EncryptionKey> {
    if (!this.isSupported()) {
      throw new Error('Web Crypto API not supported');
    }

    const keyPair = await this.generateKeyPair();
    this.keys = keyPair;
    return keyPair;
  }

  private async generateKeyPair(): Promise<EncryptionKey> {
    const keyPair = await crypto.subtle.generateKey(
      {
        name: 'ECDH',
        namedCurve: 'P-256',
      },
      true,
      ['deriveKey', 'deriveBits']
    );

    const publicKeyBuffer = await crypto.subtle.exportKey('spki', keyPair.publicKey);
    const privateKeyBuffer = await crypto.subtle.exportKey('pkcs8', keyPair.privateKey);

    return {
      publicKey: this.arrayBufferToBase64(publicKeyBuffer),
      privateKey: this.arrayBufferToBase64(privateKeyBuffer),
    };
  }

  async deriveSharedSecret(publicKeyBase64: string): Promise<string> {
    if (!this.keys?.privateKey) {
      throw new Error('Private key not available');
    }

    const publicKeyBuffer = this.base64ToArrayBuffer(publicKeyBase64);
    const privateKeyBuffer = this.base64ToArrayBuffer(this.keys.privateKey);

    const publicKey = await crypto.subtle.importKey(
      'spki',
      publicKeyBuffer,
      { name: 'ECDH', namedCurve: 'P-256' },
      false,
      []
    );

    const privateKey = await crypto.subtle.importKey(
      'pkcs8',
      privateKeyBuffer,
      { name: 'ECDH', namedCurve: 'P-256' },
      false,
      ['deriveKey', 'deriveBits']
    );

    const sharedSecret = await crypto.subtle.deriveBits(
      { name: 'ECDH', public: publicKey },
      privateKey,
      256
    );

    return this.arrayBufferToBase64(sharedSecret);
  }

  async encryptMessage(message: string, sharedSecret: string): Promise<{ encrypted: string; iv: string; tag: string }> {
    const key = await this.importSharedSecret(sharedSecret);
    const iv = crypto.getRandomValues(new Uint8Array(12));
    
    const encodedMessage = new TextEncoder().encode(message);
    
    const encrypted = await crypto.subtle.encrypt(
      { name: 'AES-GCM', iv },
      key,
      encodedMessage
    );

    const encryptedArray = new Uint8Array(encrypted);
    const tag = encryptedArray.slice(-16);
    const ciphertext = encryptedArray.slice(0, -16);

    return {
      encrypted: this.arrayBufferToBase64(ciphertext),
      iv: this.arrayBufferToBase64(iv),
      tag: this.arrayBufferToBase64(tag),
    };
  }

  async decryptMessage(encrypted: string, iv: string, tag: string, sharedSecret: string): Promise<string> {
    const key = await this.importSharedSecret(sharedSecret);
    
    const encryptedBuffer = this.base64ToArrayBuffer(encrypted);
    const ivBuffer = this.base64ToArrayBuffer(iv);
    const tagBuffer = this.base64ToArrayBuffer(tag);
    
    const combined = new Uint8Array(encryptedBuffer.byteLength + tagBuffer.byteLength);
    combined.set(new Uint8Array(encryptedBuffer), 0);
    combined.set(new Uint8Array(tagBuffer), encryptedBuffer.byteLength);

    const decrypted = await crypto.subtle.decrypt(
      { name: 'AES-GCM', iv: ivBuffer },
      key,
      combined
    );

    return new TextDecoder().decode(decrypted);
  }

  private async importSharedSecret(sharedSecretBase64: string): Promise<CryptoKey> {
    const sharedSecretBuffer = this.base64ToArrayBuffer(sharedSecretBase64);
    
    return await crypto.subtle.importKey(
      'raw',
      sharedSecretBuffer,
      { name: 'AES-GCM' },
      false,
      ['encrypt', 'decrypt']
    );
  }

  generateSessionId(): string {
    const array = new Uint8Array(16);
    crypto.getRandomValues(array);
    return Array.from(array, byte => byte.toString(16).padStart(2, '0')).join('');
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

  getKeys(): EncryptionKey | null {
    return this.keys;
  }
}

export const encryptionService = new EncryptionService(); 