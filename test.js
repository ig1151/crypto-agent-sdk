const { CryptoAgent } = require('./dist/index.js');

const agent = new CryptoAgent();

async function test() {
  console.log('Testing signal...');
  const signal = await agent.signal('AAPL');
  console.log('Signal:', JSON.stringify(signal, null, 2));
}

test().catch(console.error);
