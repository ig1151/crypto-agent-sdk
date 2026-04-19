import axios, { AxiosInstance } from 'axios';
import { DecideOptions } from '../types';

export class UnifiedDecisionClient {
  private client: AxiosInstance;

  constructor(baseUrl: string, timeout: number) {
    this.client = axios.create({ baseURL: baseUrl, timeout });
  }

  async decide(options: DecideOptions): Promise<any> {
    const response = await this.client.post('/v1/decide', options);
    return response.data;
  }
}
