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
