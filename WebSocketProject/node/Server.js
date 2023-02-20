const WebSocket = require('ws')

const wss = new WebSocket.Server({ port: 8823 });

wss.on('connection', ws => {
    console.log('connect');

    ws.on('close', () => {
        console.log("close");
    });
});