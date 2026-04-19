#!/bin/bash
set -e

echo "🚀 Updating @ig1151/crypto-agent-sdk to v2.0.0..."

cat > package.json << 'ENDPACKAGE'
{
  "name": "@ig1151/crypto-agent-sdk",
  "version": "2.0.0",
  "description": "TypeScript SDK for the crypto decision stack. Signals, news impact, portfolio rebalancing, unified decisions and strategy execution.",
  "main": "dist/index.js",
  "types": "dist/index.d.ts",
  "scripts": {
    "build": "tsc",
    "dev": "tsc --watch",
    "test": "node dist/index.js"
  },
  "keywords": ["crypto", "trading", "sdk", "ai", "agents", "portfolio", "signals", "strategy"],
  "author": "ig1151",
  "license": "MIT",
  "dependencies": {
    "axios": "^1.6.0"
  },
  "devDependencies": {
    "@types/node": "^20.10.0",
    "typescript": "^5.3.2"
  }
}
ENDPACKAGE

mkdir -p src/clients src/types

cat > src/types/index.ts << 'ENDTYPES'
export interface PortfolioAsset {
  asset: string;
  value: number;
  weight?: number;
}

export interface NewsArticle {
  title: string;
  source?: string;
  published_at?: string;
  body?: string;
}

export interface CryptoAgentConfig {
  baseUrls?: {
    unifiedDecision?: string;
    marketSignal?: string;
    newsImpact?: string;
    portfolioRebalance?: string;
    marketTrigger?: string;
    strategyExecution?: string;
  };
  timeout?: number;
}

export interface DecideOptions {
  portfolio: PortfolioAsset[];
  risk_tolerance: 'low' | 'medium' | 'high';
  news?: NewsArticle[];
  primary_asset?: string;
}

export interface NewsImpactOptions {
  asset: string;
  topic?: string;
  articles: NewsArticle[];
}

export interface RebalanceOptions {
  portfolio: PortfolioAsset[];
  strategy: 'risk_adjusted' | 'equal_weight' | 'momentum_tilt';
  risk_tolerance: 'low' | 'medium' | 'high';
  constraints?: {
    max_single_asset?: number;
    min_trade_size?: number;
    exclude_assets?: string[];
  };
  cash_buffer?: number;
}

export interface TriggerConditions {
  min_impact_score?: number;
  max_impact_score?: number;
  action_bias?: string | string[];
  sentiment?: string | string[];
  min_confidence?: number;
  event_types?: string[];
  impact_horizon?: string | string[];
  freshness?: string | string[];
  forbid_risk_warning?: boolean;
  require_risk_warning?: boolean;
}

export interface TriggerOptions {
  asset: string;
  conditions: TriggerConditions;
  context: {
    news_impact?: Record<string, unknown>;
    market_signal?: Record<string, unknown>;
  };
}

// Strategy Execution types
export type StrategyName = 'news_momentum' | 'trend_following' | 'risk_adjusted';
export type RiskTolerance = 'low' | 'medium' | 'high';

export interface ExecuteStrategyOptions {
  portfolio: PortfolioAsset[];
  strategy: StrategyName;
  risk_tolerance?: RiskTolerance;
  assets?: string[];
}

export interface StrategyAction {
  asset: string;
  action: 'buy' | 'sell' | 'hold';
  amount: number;
  confidence: number;
}

export interface StrategyResult {
  strategy: StrategyName;
  decision: string;
  confidence: number;
  actions: StrategyAction[];
  reasoning: string[];
  sources: string[];
  latency_ms: number;
  timestamp: string;
}

export interface BacktestResult {
  strategy: StrategyName;
  backtest_scenarios: Array<{ scenario: string } & StrategyResult>;
  timestamp: string;
}

export interface StrategyDefinition {
  name: StrategyName;
  description: string;
  parameters: string[];
  risk_levels: RiskTolerance[];
}
ENDTYPES

cat > src/clients/unifiedDecision.ts << 'ENDUNIFIED'
import axios from 'axios';

export class UnifiedDecisionClient {
  constructor(private baseUrl: string, private timeout: number) {}

  async decide(options: unknown): Promise<unknown> {
    const res = await axios.post(`${this.baseUrl}/v1/decide`, options, { timeout: this.timeout });
    return res.data;
  }
}
ENDUNIFIED

cat > src/clients/marketSignal.ts << 'ENDSIGNAL'
import axios from 'axios';

export class MarketSignalClient {
  constructor(private baseUrl: string, private timeout: number) {}

  async signal(ticker: string): Promise<unknown> {
    const res = await axios.get(`${this.baseUrl}/v1/signal/${ticker}`, { timeout: this.timeout });
    return res.data;
  }

  async batchSignal(assets: string[]): Promise<unknown> {
    const res = await axios.post(`${this.baseUrl}/v1/signal/batch`, { assets }, { timeout: this.timeout });
    return res.data;
  }
}
ENDSIGNAL

cat > src/clients/newsImpact.ts << 'ENDNEWS'
import axios from 'axios';

export class NewsImpactClient {
  constructor(private baseUrl: string, private timeout: number) {}

  async analyze(options: unknown): Promise<unknown> {
    const res = await axios.post(`${this.baseUrl}/v1/analyze`, options, { timeout: this.timeout });
    return res.data;
  }
}
ENDNEWS

cat > src/clients/portfolioRebalance.ts << 'ENDREBALANCE'
import axios from 'axios';

export class PortfolioRebalanceClient {
  constructor(private baseUrl: string, private timeout: number) {}

  async rebalance(options: unknown): Promise<unknown> {
    const res = await axios.post(`${this.baseUrl}/v1/rebalance`, options, { timeout: this.timeout });
    return res.data;
  }

  async strategies(): Promise<unknown> {
    const res = await axios.get(`${this.baseUrl}/v1/strategies`, { timeout: this.timeout });
    return res.data;
  }
}
ENDREBALANCE

cat > src/clients/marketTrigger.ts << 'ENDTRIGGER'
import axios from 'axios';

export class MarketTriggerClient {
  constructor(private baseUrl: string, private timeout: number) {}

  async evaluate(options: unknown): Promise<unknown> {
    const res = await axios.post(`${this.baseUrl}/v1/trigger`, options, { timeout: this.timeout });
    return res.data;
  }
}
ENDTRIGGER

cat > src/clients/strategyExecution.ts << 'ENDSTRATEGY'
import axios from 'axios';
import {
  ExecuteStrategyOptions,
  StrategyResult,
  BacktestResult,
  StrategyDefinition,
} from '../types';

export class StrategyExecutionClient {
  constructor(private baseUrl: string, private timeout: number) {}

  async execute(options: ExecuteStrategyOptions): Promise<StrategyResult> {
    const res = await axios.post(`${this.baseUrl}/v1/strategy/execute`, options, { timeout: this.timeout });
    return res.data as StrategyResult;
  }

  async backtest(options: ExecuteStrategyOptions): Promise<BacktestResult> {
    const res = await axios.post(`${this.baseUrl}/v1/strategy/backtest`, options, { timeout: this.timeout });
    return res.data as BacktestResult;
  }

  async list(): Promise<{ strategies: StrategyDefinition[]; count: number }> {
    const res = await axios.get(`${this.baseUrl}/v1/strategy/list`, { timeout: this.timeout });
    return res.data;
  }
}
ENDSTRATEGY

cat > src/index.ts << 'ENDINDEX'
import { UnifiedDecisionClient } from './clients/unifiedDecision';
import { MarketSignalClient } from './clients/marketSignal';
import { NewsImpactClient } from './clients/newsImpact';
import { PortfolioRebalanceClient } from './clients/portfolioRebalance';
import { MarketTriggerClient } from './clients/marketTrigger';
import { StrategyExecutionClient } from './clients/strategyExecution';
import {
  CryptoAgentConfig,
  DecideOptions,
  NewsImpactOptions,
  RebalanceOptions,
  TriggerOptions,
  ExecuteStrategyOptions,
  StrategyResult,
  BacktestResult,
  StrategyDefinition,
} from './types';

export * from './types';

const DEFAULT_URLS = {
  unifiedDecision: 'https://unified-decision-api.onrender.com',
  marketSignal: 'https://market-signal-api-iu2o.onrender.com',
  newsImpact: 'https://crypto-news-impact-api.onrender.com',
  portfolioRebalance: 'https://portfolio-rebalance-api.onrender.com',
  marketTrigger: 'https://market-trigger-api.onrender.com',
  strategyExecution: 'https://strategy-execution-api.onrender.com',
};

export class CryptoAgent {
  private decisionClient: UnifiedDecisionClient;
  private signalClient: MarketSignalClient;
  private newsClient: NewsImpactClient;
  private rebalanceClient: PortfolioRebalanceClient;
  private triggerClient: MarketTriggerClient;
  private strategyClient: StrategyExecutionClient;

  constructor(config: CryptoAgentConfig = {}) {
    const urls = { ...DEFAULT_URLS, ...config.baseUrls };
    const timeout = config.timeout ?? 30000;

    this.decisionClient = new UnifiedDecisionClient(urls.unifiedDecision, timeout);
    this.signalClient = new MarketSignalClient(urls.marketSignal, timeout);
    this.newsClient = new NewsImpactClient(urls.newsImpact, timeout);
    this.rebalanceClient = new PortfolioRebalanceClient(urls.portfolioRebalance, timeout);
    this.triggerClient = new MarketTriggerClient(urls.marketTrigger, timeout);
    this.strategyClient = new StrategyExecutionClient(urls.strategyExecution, timeout);
  }

  // --- Existing methods ---
  async decide(options: DecideOptions): Promise<unknown> {
    return this.decisionClient.decide(options);
  }

  async signal(ticker: string): Promise<unknown> {
    return this.signalClient.signal(ticker);
  }

  async batchSignal(assets: string[]): Promise<unknown> {
    return this.signalClient.batchSignal(assets);
  }

  async newsImpact(options: NewsImpactOptions): Promise<unknown> {
    return this.newsClient.analyze(options);
  }

  async rebalance(options: RebalanceOptions): Promise<unknown> {
    return this.rebalanceClient.rebalance(options);
  }

  async strategies(): Promise<unknown> {
    return this.rebalanceClient.strategies();
  }

  async trigger(options: TriggerOptions): Promise<unknown> {
    return this.triggerClient.evaluate(options);
  }

  // --- Strategy Execution (new in v2) ---
  async executeStrategy(options: ExecuteStrategyOptions): Promise<StrategyResult> {
    return this.strategyClient.execute(options);
  }

  async backtestStrategy(options: ExecuteStrategyOptions): Promise<BacktestResult> {
    return this.strategyClient.backtest(options);
  }

  async listStrategies(): Promise<{ strategies: StrategyDefinition[]; count: number }> {
    return this.strategyClient.list();
  }
}

export default CryptoAgent;
ENDINDEX

cat > README.md << 'ENDREADME'
# @ig1151/crypto-agent-sdk

TypeScript SDK for the crypto decision stack. One import to access market signals, news impact, portfolio rebalancing, unified decisions and strategy execution.

## Install

```bash
npm install @ig1151/crypto-agent-sdk
```

## Quick Start

```typescript
import CryptoAgent from '@ig1151/crypto-agent-sdk';

const agent = new CryptoAgent();

// Execute a strategy (new in v2)
const result = await agent.executeStrategy({
  portfolio: [
    { asset: 'BTC', value: 10000, weight: 0.6 },
    { asset: 'ETH', value: 4000, weight: 0.3 },
    { asset: 'SOL', value: 1000, weight: 0.1 },
  ],
  strategy: 'news_momentum',
  risk_tolerance: 'medium',
});

console.log(result.decision);   // e.g. "increase_btc_exposure"
console.log(result.actions);    // [{ asset: 'BTC', action: 'buy', amount: 1000, confidence: 0.84 }]
console.log(result.reasoning);  // ["High-impact bullish news detected..."]

// Backtest a strategy
const backtest = await agent.backtestStrategy({
  portfolio: [...],
  strategy: 'trend_following',
  risk_tolerance: 'high',
});

// List available strategies
const { strategies } = await agent.listStrategies();

// Other methods (unchanged from v1)
const signal = await agent.signal('BTC');
const decision = await agent.decide({ portfolio: [...], risk_tolerance: 'medium' });
const rebalanced = await agent.rebalance({ portfolio: [...], strategy: 'equal_weight', risk_tolerance: 'low' });
```

## Methods

| Method | Description |
|--------|-------------|
| `executeStrategy(options)` | Run a strategy → get decision + actions + reasoning |
| `backtestStrategy(options)` | Backtest across bear / neutral / bull scenarios |
| `listStrategies()` | List available strategies and parameters |
| `decide(options)` | Unified decision from all signals |
| `signal(ticker)` | Market signal for a single asset |
| `batchSignal(assets)` | Signals for multiple assets |
| `newsImpact(options)` | News impact analysis |
| `rebalance(options)` | Portfolio rebalance recommendation |
| `trigger(options)` | Market trigger evaluation |

## Strategies

| Name | Description |
|------|-------------|
| `news_momentum` | Reacts to high-impact crypto news to adjust exposure |
| `trend_following` | Follows strong directional market signals |
| `risk_adjusted` | Rebalances portfolio to target weights |

## What's New in v2

- `executeStrategy()` — the strategy execution layer
- `backtestStrategy()` — test strategies across scenarios
- `listStrategies()` — discover available strategies
- Full TypeScript types for all strategy inputs and outputs
- `strategyExecution` base URL override in config

## License

MIT
ENDREADME

echo "✅ SDK v2 files created!"
echo "Next: npm install && npm run build"