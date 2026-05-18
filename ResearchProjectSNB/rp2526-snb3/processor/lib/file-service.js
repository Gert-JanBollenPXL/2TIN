import fetch from 'node-fetch';
import { promises as fs } from 'fs';

export class FileService {
  constructor(config) {
    this.mediaServiceUrl = config.mediaServiceUrl;
    this.mediaSigningSecret = config.mediaSigningSecret;
  }

  async getSignedUrl(method, path, expiresIn = 300) {
    const response = await fetch(`${this.mediaServiceUrl}/sign`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ method, path, expiresIn })
    });
    
    if (!response.ok) {
      throw new Error(`Failed to get signed URL: ${response.statusText}`);
    }
    
    return response.json();
  }

  async download(path, outputFile) {
    const signed = await this.getSignedUrl('GET', `/${path}`);
    const url = `${this.mediaServiceUrl}${signed.url}`;
    
    const response = await fetch(url, {
      headers: signed.headers
    });
    
    if (!response.ok) {
      throw new Error(`Failed to download: ${response.statusText}`);
    }
    
    const buffer = await response.buffer();
    await fs.writeFile(outputFile, buffer);
    
    return outputFile;
  }

  async upload(localPath, remotePath) {
    const signed = await this.getSignedUrl('PUT', `/${remotePath}`);
    const url = `${this.mediaServiceUrl}${signed.url}`;
    
    const fileBuffer = await fs.readFile(localPath);
    
    const response = await fetch(url, {
      method: 'PUT',
      headers: {
        ...signed.headers,
        'Content-Type': 'application/octet-stream'
      },
      body: fileBuffer
    });
    
    if (!response.ok) {
      throw new Error(`Failed to upload: ${response.statusText}`);
    }
    
    return remotePath;
  }
}
