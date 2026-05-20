const { Client, LocalAuth } = require('whatsapp-web.js');
const qrcode = require('qrcode-terminal');
const express = require('express');
const bodyParser = require('body-parser');

const app = express();
const port = process.env.PORT || 3000;

app.use(bodyParser.json());

// Initialize WhatsApp Client
const client = new Client({
    authStrategy: new LocalAuth(),
    puppeteer: {
        args: ['--no-sandbox']
    }
});

client.on('qr', (qr) => {
    console.log('QR RECEIVED', qr);
    qrcode.generate(qr, { small: true });
});

client.on('ready', () => {
    console.log('WhatsApp Bot is ready!');
});

client.on('message', async msg => {
    if (msg.body === '!ping') {
        msg.reply('pong');
    }

    if (msg.body.startsWith('!forecast')) {
        const symbol = msg.body.split(' ')[1] || 'EURUSD';
        msg.reply(`Requesting forecast for ${symbol}... (Feature integration pending)`);
        // Here we could call GAS backend to get forecast and reply
    }
});

// Endpoint to receive notifications from GAS
app.post('/send', async (req, res) => {
    let { to, message } = req.body;

    // Defensive parsing for GAS responses that might arrive as strings
    if (typeof req.body === 'string') {
        try {
            const parsed = JSON.parse(req.body);
            to = parsed.to;
            message = parsed.message;
        } catch (e) {
            console.error('Failed to parse body string', e);
        }
    }

    if (!to || !message) {
        return res.status(400).json({ status: 'error', message: 'Missing to or message' });
    }

    // Ensure 'to' is in correct format (e.g., 6285322624048@c.us)
    const formattedTo = to.includes('@c.us') ? to : `${to}@c.us`;

    try {
        await client.sendMessage(formattedTo, message);
        console.log(`Message sent to ${formattedTo}`);
        res.json({ status: 'success' });
    } catch (error) {
        console.error('Failed to send message', error);
        res.status(500).json({ status: 'error', message: error.message });
    }
});

client.initialize();

app.listen(port, () => {
    console.log(`Notification server listening on port ${port}`);
});
