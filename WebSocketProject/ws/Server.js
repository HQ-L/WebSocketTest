const ws = new require('nodejs-websocket');
const PORT = 8823

const server = ws.createServer(connect => {
    console.log("success")
    connect.on('text', data => {
        console.log(data)
        broadcast({
            type: 1,
            message: data
        })
    })

    connect.on('close', () => {
        console.log("interrupt")
    })

    connect.on('error', () => {
        console.log("error")
    })
});

server.listen(PORT, () => {
    console.log('start ' + PORT)
});

function broadcast(message) {
    server.connections.forEach(item => {
        item.send(JSON.stringify(message))
    });
}
