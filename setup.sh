#!/bin/bash
set -e

mkdir -p src/clients src/types

cat > package.json << 'EOF'
{
  "name": "@ig1151/crypto-agent-sdk",
  "version": "1.0.0",
  "description": "TypeScript SDK for the crypto decision stack. One import to access market signals, news impact, portfolio rebalancing and unified trading decisions.",
  "main": "dist/index.js",
  "types": "dist/index.d.ts",
  "files": ["dist"],
  "scripts": {
    "build": "tsc",
    "dev": "tsc --watch",
    "test": "node dist/index.js"
  },
  "keywords": ["crypto", "trading", "sdk", "ai", "agents", "portfolio", "signals"],
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
EOF

cat > tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
EOF

cat > .gitignore << 'EOF'
node_modules/
dist/
*.log
EOF

cat > .npmignore << 'EOF'
src/
tsconfig.json
setup.sh
*.log
EOF

cat > src/types/index.ts << 'EOF'
export interface PortfolioAsset {
  asset: string;
  value: number;
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
  };
  timeout?: number;
}

export interface DecideOptions {
  portfolio: PortfolioAsset[];
  risk_tolerance: 'low' | 'medium' | 'high';
  news?: NewsArticle[];
  primary_asset?: string;
}

export interface SignalOptions {
  ticker: string;
}

export interface BatchSignalOptions {
  assets: string[];
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
    news_impact?: Record<string, any>;
    market_signal?: Record<string, any>;
  };
}
EOF

cat > src/clients/unifiedDecision.ts << 'EOF'
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
EOF

cat > src/clients/marketSignal.ts << 'EOF'
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
EOF

cat > src/clients/newsImpact.ts << 'EOF'
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
EOF

cat > src/clients/portfolioRebalance.ts << 'EOF'
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
EOF

cat > src/clients/marketTrigger.ts << 'EOF'
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
EOF

cat > src/index.ts << 'EOF'
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
  private unifiedDecision: UnifiedDecisionClient;
  private marketSignal: MarketSignalClient;
  private newsImpact: NewsImpactClient;
  private portfolioRebalance: PortfolioRebalanceClient;
  private marketTrigger: MarketTriggerClient;

  constructor(config: CryptoAgentConfig = {}) {
    const urls = { ...DEFAULT_URLS, ...config.baseUrls };
    const timeout = config.timeout ?? 30000;

    this.unifiedDecision = new UnifiedDecisionClient(urls.unifiedDecision, timeout);
    this.marketSignal = new MarketSignalClient(urls.marketSignal, timeout);
    this.newsImpact = new NewsImpactClient(urls.newsImpact, timeout);
    this.portfolioRebalance = new PortfolioRebalanceClient(urls.portfolioRebalance, timeout);
    this.marketTrigger = new MarketTriggerClient(urls.marketTrigger, timeout);
  }

  // Unified decision — combines all signals
  async decide(options: DecideOptions): Promise<any> {
    return this.unifiedDecision.decide(options);
  }

  // Market signal for a single ticker
  async signal(ticker: string): Promise<any> {
    return this.marketSignal.signal(ticker);
  }

  // Batch signals for multiple tickers
  async batchSignal(assets: string[]): Promise<any> {
    return this.marketSignal.batchSignal(assets);
  }

  // News impact analysis
  async newsImpact(options: NewsImpactOptions): Promise<any> {
    return this.newsImpact.analyze(options);
  }

  // Portfolio rebalance
  async rebalance(options: RebalanceOptions): Promise<any> {
    return this.portfolioRebalance.rebalance(options);
  }

  // Available rebalance strategies
  async strategies(): Promise<any> {
    return this.portfolioRebalance.strategies();
  }

  // Trigger evaluation
  async trigger(options: TriggerOptions): Promise<any> {
    return this.marketTrigger.evaluate(options);
  }
}

export default CryptoAgent;
EOF

cat > README.md << 'EOF'
# @ig1151/crypto-agent-sdk

TypeScript SDK for the crypto decision stack. One import to access market signals, news impact, portfolio rebalancing and unified trading decisions.

## Install

```bash
npm install @ig1151/crypto-agent-sdk
```

## Quick start

```typescript
import { CryptoAgent } from '@ig1151/crypto-agent-sdk';

const agent = new CryptoAgent();

// Unified decision — combines market signals, news impact and portfolio analysis
const decision = await agent.decide({
  portfolio: [
    { asset: 'BTC', value: 6000 },
    { asset: 'ETH', value: 3000 }
  ],
  risk_tolerance: 'medium',
  news: [
    { title: 'SEC moves closer to Bitcoin ETF approval', source: 'CoinDesk' }
  ]
});

console.log(decision.final_decision); // "reduce_and_rebalance"
console.log(decision.urgency);        // "medium"
console.log(decision.actions);        // buy/sell actions
```

## Methods

### `agent.decide(options)` — Unified decision
Combines market signals, news impact and portfolio analysis into one decision.

### `agent.signal(ticker)` — Market signal
Returns buy/sell/hold decision for a single stock or crypto ticker.

### `agent.batchSignal(assets)` — Batch signals
Returns signals for up to 10 tickers in one call.

### `agent.newsImpact(options)` — News impact
Analyzes news articles and returns market impact assessment.

### `agent.rebalance(options)` — Portfolio rebalance
Returns target allocations, drift analysis and rebalance actions.

### `agent.trigger(options)` — Trigger evaluation
Evaluates conditions against market context and returns trigger signal.

## APIs

This SDK wraps:
- [Unified Decision API](https://unified-decision-api.onrender.com)
- [Market Decision API](https://market-signal-api-iu2o.onrender.com)
- [Crypto News Impact API](https://crypto-news-impact-api.onrender.com)
- [Portfolio Rebalance API](https://portfolio-rebalance-api.onrender.com)
- [Market Trigger API](https://market-trigger-api.onrender.com)

## License

MIT
EOF

echo "✅ All files created."
echo ""
echo "Next steps:"
echo "  1. npm install"
echo "  2. npm run build"
echo "  3. Test the SDK"
echo "  4. npm publish --access public"