import axios, { AxiosInstance } from 'axios';
import { RebalanceOptions } from '../types';

export class PortfolioRebalanceClient {
  private client: AxiosInstance;

  constructor(baseUrl: string, timeout: number) {
    this.client = axios.create({ baseURL: baseUrl, timeout });
  }

  async rebalance(options: RebalanceOptions): Promise<any> {
    const response = await this.client.post('/v1/rebalance', options);
    return response.data;
  }

  async strategies(): Promise<any> {
    const response = await this.client.get('/v1/strategies');
    return response.data;
  }
}
