import axios, { AxiosInstance } from 'axios';
import { NewsImpactOptions } from '../types';

export class NewsImpactClient {
  private client: AxiosInstance;

  constructor(baseUrl: string, timeout: number) {
    this.client = axios.create({ baseURL: baseUrl, timeout });
  }

  async analyze(options: NewsImpactOptions): Promise<any> {
    const response = await this.client.post('/v1/news-impact', options);
    return response.data;
  }
}
