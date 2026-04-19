import axios, { AxiosInstance } from 'axios';

export class MarketSignalClient {
  private client: AxiosInstance;

  constructor(baseUrl: string, timeout: number) {
    this.client = axios.create({ baseURL: baseUrl, timeout });
  }

  async signal(ticker: string): Promise<any> {
    const response = await this.client.get(`/v1/signal/${ticker.toUpperCase()}`);
    return response.data;
  }

  async batchSignal(assets: string[]): Promise<any> {
    const response = await this.client.post('/v1/signal/batch', { assets });
    return response.data;
  }
}
