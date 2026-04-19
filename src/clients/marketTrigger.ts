import axios, { AxiosInstance } from 'axios';
import { TriggerOptions } from '../types';

export class MarketTriggerClient {
  private client: AxiosInstance;

  constructor(baseUrl: string, timeout: number) {
    this.client = axios.create({ baseURL: baseUrl, timeout });
  }

  async evaluate(options: TriggerOptions): Promise<any> {
    const response = await this.client.post('/v1/trigger', options);
    return response.data;
  }
}
