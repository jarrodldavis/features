#!/bin/bash
set -euo pipefail

env -u NODE_OPTIONS node <<'NODE'
const assert = require('node:assert/strict');
const { lookup } = require('node:dns/promises');
const { createServer } = require('node:net');
const { once } = require('node:events');

async function checkBinding(host, expectedAddress) {
    const server = createServer();
    server.listen(0, host);
    await once(server, 'listening');
    try {
        assert.equal(server.address().address, expectedAddress);
    } finally {
        server.close();
    }
}

async function main() {
    const addresses = await lookup('localhost', { all: true });
    assert.deepEqual(addresses[0], { address: '127.0.0.1', family: 4 });
    assert.ok(addresses.some(({ address, family }) => address === '::1' && family === 6));

    await checkBinding('localhost', '127.0.0.1');
    await checkBinding('::1', '::1');
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
NODE
