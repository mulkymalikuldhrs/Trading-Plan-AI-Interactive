const { Client, LocalAuth } = require('whatsapp-web.js');
const qrcode = require('qrcode-terminal');
const express = require('express');
const bodyParser = require('body-parser');

// --- EXPRESS SERVER SETUP ---
const app = express();
const port = process.env.PORT || 3000;
app.use(bodyParser.json());

let clientReady = false;

// --- WHATSAPP CLIENT SETUP ---
const client = new Client({
    authStrategy: new LocalAuth()
});

client.on('qr', (qr) => {
    qrcode.generate(qr, { small: true });
    console.log('Scan the QR code with your phone.');
});

client.on('ready', () => {
    console.log('WhatsApp client is ready!');
    clientReady = true;
});

client.on('message', msg => {
    if (msg.body.toLowerCase() === '!status') {
        msg.reply('🤖 Mulky AI OS Bot is active.');
    }
});

client.initialize();

// --- API ENDPOINT FOR SENDING MESSAGES ---
app.post('/send', (req, res) => {
    if (!clientReady) {
        return res.status(503).json({ status: 'error', message: 'WhatsApp client is not ready.' });
    }

    const { to, message } = req.body;
    if (!to || !message) {
        return res.status(400).json({ status: 'error', message: 'Missing "to" or "message" in request body.' });
    }

    const chatId = `${to}@c.us`;

    client.sendMessage(chatId, message).then(response => {
        res.status(200).json({ status: 'success', data: response });
    }).catch(err => {
        res.status(500).json({ status: 'error', message: 'Failed to send message.', details: err });
    });
});

app.listen(port, () => {
    console.log(`WhatsApp Bot server listening at http://localhost:${port}`);
});
