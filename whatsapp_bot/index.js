require('dotenv').config();
const { Client, LocalAuth, Buttons } = require('whatsapp-web.js');
const qrcode = require('qrcode-terminal');
const express = require('express');
const bodyParser = require('body-parser');
const axios = require('axios');

// --- CONFIGURATION ---
const app = express();
const port = process.env.PORT || 3000;
const GAS_URL = process.env.GAS_URL;
const BOT_API_KEY = process.env.BOT_API_KEY || process.env.API_KEY;

if (!GAS_URL) {
    console.error("ERROR: GAS_URL is not defined in environment variables.");
    process.exit(1);
}

app.use(bodyParser.json());
let clientReady = false;

// --- WHATSAPP CLIENT SETUP ---
const client = new Client({
    authStrategy: new LocalAuth(),
    puppeteer: {
        args: ['--no-sandbox', '--disable-setuid-sandbox'],
        executablePath: process.env.CHROME_PATH || null
    }
});

client.on('qr', (qr) => {
    console.log('Scan this QR code to log in:');
    qrcode.generate(qr, { small: true });
});

client.on('ready', () => {
    console.log('Dhaher Trading Plan AI Bot is ready!');
    clientReady = true;
});

client.on('auth_failure', (msg) => {
    console.error('AUTHENTICATION FAILURE', msg);
});

// --- ADVANCED COMMAND HANDLING ---
client.on('message', async (msg) => {
    const text = msg.body.toLowerCase();
    if (!text.startsWith('!') && !text.startsWith('/')) return;

    const command = text.split(' ')[0];
    const args = text.split(' ').slice(1);

    const commandHandlers = {
        '!reflect': handleReflect,
        '/summary': handleSummary,
        '/cot': handleCot,
        '/forecast': handleForecast,
        '!ping': (m) => m.reply('pong')
    };

    if (commandHandlers[command]) {
        await commandHandlers[command](msg, args);
    }
});

client.initialize();


// --- COMMAND HANDLER FUNCTIONS ---
async function handleReflect(msg, args) {
    msg.reply('Reflection initiated. How was your last trade? (This feature is being enhanced with interactive buttons)');
}

async function handleSummary(msg, args) {
    const symbol = args[0] ? args[0].toUpperCase() : 'EURUSD';
    msg.reply(`🤖 Roger that! Generating a full intelligence summary for **${symbol}**...`);

    try {
        const response = await axios.post(GAS_URL, {
            action: 'getAiMasterSummary',
            data: { symbol: symbol },
            api_key: BOT_API_KEY
        });

        const summary = response.data.data;
        const formattedReply = `
*🧠 AI Master Summary for ${symbol}*
*Bias:* ${summary.final_bias} (Confidence: ${summary.confidence_score}/10)
*Signal Active:* ${summary.signal?.active ?? 'false'}
*Entry:* ${summary.signal?.entry || 'N/A'}
*Stop Loss:* ${summary.signal?.stop_loss || 'N/A'}
*Take Profit:* ${summary.signal?.take_profit || 'N/A'}

*Thesis:*
- Technical: ${summary.technical_thesis}
- Fundamental: ${summary.fundamental_thesis}
        `;
        msg.reply(formattedReply);

    } catch (error) {
        console.error("Summary Error:", error.message);
        msg.reply('Sorry, I had trouble generating the summary. Please check your GAS_URL and BOT_API_KEY.');
    }
}

async function handleForecast(msg, args) {
    const symbol = args[0] ? args[0].toUpperCase() : 'EURUSD';
    msg.reply(`🔮 On it! Generating a new forecast for **${symbol}**...`);

    try {
        const response = await axios.post(GAS_URL, {
            action: 'getForecast',
            data: { pair: symbol, timeframe: 'H4', days: 7 },
            api_key: BOT_API_KEY
        });

        const forecast = response.data.data;
        const formattedReply = `
*🔮 AI Forecast for ${symbol} (7-Day Outlook)*
*Bias:* ${forecast.bias}
*Probability:* ${forecast.probability}%
*Entry Zone:* ${forecast.entry_zone}
*Confirmation:* ${forecast.confirmation}
*SL:* ${forecast.stop_loss} | *TP:* ${forecast.take_profit}

*This is an AI-generated probabilistic forecast, not financial advice.*
        `;
        msg.reply(formattedReply);

    } catch (error) {
        console.error("Forecast Error:", error.message);
        msg.reply('I had trouble peering into the future... Check connection to GAS.');
    }
}

async function handleCot(msg, args) {
    msg.reply('COT analysis coming soon! Use /summary for general bias.');
}


// --- API ENDPOINT FOR SENDING MESSAGES ---
app.post('/send', async (req, res) => {
    const { to, message, api_key } = req.body;

    if (BOT_API_KEY && api_key !== BOT_API_KEY) {
        return res.status(401).json({ status: 'error', message: 'Unauthorized: Invalid API Key' });
    }

    if (!clientReady) {
        return res.status(503).json({ status: 'error', message: 'WhatsApp client not ready' });
    }

    try {
        const chatId = to.includes('@c.us') ? to : `${to}@c.us`;
        await client.sendMessage(chatId, message);
        res.json({ status: 'success', message: 'Message sent' });
    } catch (error) {
        res.status(500).json({ status: 'error', message: error.message });
    }
});

app.listen(port, () => {
    console.log(`Dhaher Trading Plan AI Bot server listening at http://localhost:${port}`);
});
