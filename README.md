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
