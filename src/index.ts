import { UnifiedDecisionClient } from './clients/unifiedDecision';
import { MarketSignalClient } from './clients/marketSignal';
import { NewsImpactClient } from './clients/newsImpact';
import { PortfolioRebalanceClient } from './clients/portfolioRebalance';
import { MarketTriggerClient } from './clients/marketTrigger';
import {
  CryptoAgentConfig,
  DecideOptions,
  NewsImpactOptions,
  RebalanceOptions,
  TriggerOptions
} from './types';

export * from './types';

const DEFAULT_URLS = {
  unifiedDecision: 'https://unified-decision-api.onrender.com',
  marketSignal: 'https://market-signal-api-iu2o.onrender.com',
  newsImpact: 'https://crypto-news-impact-api.onrender.com',
  portfolioRebalance: 'https://portfolio-rebalance-api.onrender.com',
  marketTrigger: 'https://market-trigger-api.onrender.com'
};

export class CryptoAgent {
  private decisionClient: UnifiedDecisionClient;
  private signalClient: MarketSignalClient;
  private newsClient: NewsImpactClient;
  private rebalanceClient: PortfolioRebalanceClient;
  private triggerClient: MarketTriggerClient;

  constructor(config: CryptoAgentConfig = {}) {
    const urls = { ...DEFAULT_URLS, ...config.baseUrls };
    const timeout = config.timeout ?? 30000;

    this.decisionClient = new UnifiedDecisionClient(urls.unifiedDecision, timeout);
    this.signalClient = new MarketSignalClient(urls.marketSignal, timeout);
    this.newsClient = new NewsImpactClient(urls.newsImpact, timeout);
    this.rebalanceClient = new PortfolioRebalanceClient(urls.portfolioRebalance, timeout);
    this.triggerClient = new MarketTriggerClient(urls.marketTrigger, timeout);
  }

  async decide(options: DecideOptions): Promise<any> {
    return this.decisionClient.decide(options);
  }

  async signal(ticker: string): Promise<any> {
    return this.signalClient.signal(ticker);
  }

  async batchSignal(assets: string[]): Promise<any> {
    return this.signalClient.batchSignal(assets);
  }

  async newsImpact(options: NewsImpactOptions): Promise<any> {
    return this.newsClient.analyze(options);
  }

  async rebalance(options: RebalanceOptions): Promise<any> {
    return this.rebalanceClient.rebalance(options);
  }

  async strategies(): Promise<any> {
    return this.rebalanceClient.strategies();
  }

  async trigger(options: TriggerOptions): Promise<any> {
    return this.triggerClient.evaluate(options);
  }
}

export default CryptoAgent;