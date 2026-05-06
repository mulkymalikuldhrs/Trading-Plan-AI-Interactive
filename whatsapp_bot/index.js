const { Client, LocalAuth } = require('whatsapp-web.js');
const qrcode = require('qrcode-terminal');
const axios = require('axios');
const express = require('express');
const bodyParser = require('body-parser');

const app = express();
app.use(bodyParser.json());

const GAS_URL = process.env.GAS_URL;
const BOT_API_KEY = process.env.BOT_API_KEY;

const client = new Client({
    authStrategy: new LocalAuth(),
    puppeteer: {
        args: ['--no-sandbox']
    }
});

client.on('qr', (qr) => {
    qrcode.generate(qr, { small: true });
    console.log('QR RECEIVED', qr);
});

client.on('ready', () => {
    console.log('Dhaher Trading Bot is ready!');
});

client.on('message', async msg => {
    const chat = await msg.getChat();
    const command = msg.body.toLowerCase();

    if (command === '!ping') {
        msg.reply('pong');
    } else if (command === '/cot') {
        handleCot(msg);
    } else if (command === '/news') {
        handleNews(msg);
    } else if (command.startsWith('/forecast')) {
        handleForecast(msg);
    } else if (command === '/help') {
        msg.reply(`Available commands:
/cot - Get institutional sentiment
/news - Get latest market news
/forecast [symbol] - Get AI forecast
/help - Show this message`);
    }
});

async function handleCot(msg) {
    try {
        const response = await axios.post(GAS_URL, {
            action: 'getMarketData',
            data: { symbol: 'XAUUSD' },
            apiKey: BOT_API_KEY
        });
        const cot = response.data.data.cot_report;
        let reply = '*Institutional Sentiment (COT)*\n\n';
        for (const [asset, data] of Object.entries(cot)) {
            reply += `*${asset}*: ${data.bias} (Net: ${data.net_position})\n`;
        }
        msg.reply(reply);
    } catch (e) {
        msg.reply('Error fetching COT data.');
    }
}

async function handleNews(msg) {
    try {
        const response = await axios.post(GAS_URL, {
            action: 'getMarketData',
            data: { symbol: 'forex' },
            apiKey: BOT_API_KEY
        });
        const news = response.data.data.news_headlines;
        let reply = '*Latest Market News*\n\n';
        news.forEach((headline, i) => {
            reply += `${i + 1}. ${headline}\n`;
        });
        msg.reply(reply);
    } catch (e) {
        msg.reply('Error fetching news.');
    }
}

async function handleForecast(msg) {
    const symbol = msg.body.split(' ')[1] || 'XAUUSD';
    try {
        const response = await axios.post(GAS_URL, {
            action: 'generateForecast',
            data: { symbol: symbol },
            apiKey: BOT_API_KEY
        });
        const forecast = response.data.data;
        msg.reply(`*AI Forecast for ${symbol}*
Bias: ${forecast.bias}
Probability: ${forecast.probability}%
Summary: ${forecast.summary}
Entry: ${forecast.entry}
SL: ${forecast.sl} | TP: ${forecast.tp}`);
    } catch (e) {
        msg.reply('Error generating forecast.');
    }
}

// Endpoint to send notifications from GAS
app.post('/send', async (req, res) => {
    const { to, message } = req.body;
    try {
        const chatId = to.includes('@c.us') ? to : `${to}@c.us`;
        await client.sendMessage(chatId, message);
        res.status(200).send({ status: 'success' });
    } catch (e) {
        res.status(500).send({ status: 'error', message: e.message });
    }
});

client.initialize();
app.listen(3000, () => console.log('Notification server running on port 3000'));
