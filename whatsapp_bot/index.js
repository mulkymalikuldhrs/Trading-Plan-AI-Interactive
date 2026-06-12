const { Client, LocalAuth, MessageMedia, Buttons } = require('whatsapp-web.js');
const qrcode = require('qrcode-terminal');
const express = require('express');
const bodyParser = require('body-parser');
const axios = require('axios');

// --- CONFIGURATION ---
const app = express();
const port = process.env.PORT || 3000;
const GOOGLE_APPS_SCRIPT_URL = process.env.GAS_URL;
const BOT_API_KEY = process.env.BOT_API_KEY;

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

client.on('qr', (qr) => qrcode.generate(qr, { small: true }));

client.on('ready', () => {
    console.log('Dhaher Trading Plan AI Bot is ready!');
    clientReady = true;
});

// --- ADVANCED COMMAND HANDLING ---
client.on('message', async (msg) => {
    const text = msg.body.toLowerCase();
    const command = text.split(' ')[0];
    const args = text.split(' ').slice(1);

    const commandHandlers = {
        '!ping': (m) => m.reply('pong'),
        '!reflect': handleReflect,
        '/summary': handleSummary,
        '/cot': handleCot,
        '/forecast': handleForecast,
    };

    if (commandHandlers[command]) {
        try {
            await commandHandlers[command](msg, args);
        } catch (error) {
            console.error(`Error handling command ${command}:`, error);
            msg.reply('❌ An error occurred while processing your request.');
        }
    }
});

client.initialize();

// --- COMMAND HANDLER FUNCTIONS ---
async function handleReflect(msg, args) {
    msg.reply('🧘‍♂️ Reflection mode: How was your discipline today? (Good/Average/Poor)');
}

async function handleSummary(msg, args) {
    const symbol = args[0] ? args[0].toUpperCase() : 'EURUSD';
    msg.reply(`🤖 Generating intelligence summary for **${symbol}**...`);

    try {
        const response = await axios.post(GOOGLE_APPS_SCRIPT_URL, {
            action: 'getAiMasterSummary',
            data: { symbol: symbol, apiKey: BOT_API_KEY }
        });

        // Defensive handling for stringified JSON responses from GAS
        let summary = response.data.data;
        if (typeof summary === 'string') {
            try {
                summary = JSON.parse(summary);
            } catch (e) {
                console.error("Failed to parse GAS summary:", response.data.data);
                return msg.reply('❌ Received invalid data format from backend.');
            }
        }

        if (!summary || typeof summary !== 'object') {
            return msg.reply('❌ Could not retrieve a valid summary.');
        }

        const formattedReply = `
*🧠 AI Master Summary for ${symbol}*
*Bias:* ${summary.final_bias || 'N/A'} (Confidence: ${summary.confidence_score || '?'}/10)
*Signal:* ${summary.signal && summary.signal.active ? 'ACTIVE' : 'INACTIVE'}
*Entry:* ${summary.signal ? summary.signal.entry || 'N/A' : 'N/A'}
*Stop Loss:* ${summary.signal ? summary.signal.stop_loss || 'N/A' : 'N/A'}
*Take Profit:* ${summary.signal ? summary.signal.take_profit || 'N/A' : 'N/A'}

*Technical Thesis:* ${summary.technical_thesis || 'N/A'}
*Fundamental Thesis:* ${summary.fundamental_thesis || 'N/A'}
*COT Bias:* ${summary.cot_raw ? summary.cot_raw.bias || 'N/A' : 'N/A'}
        `;
        msg.reply(formattedReply);
    } catch (error) {
        msg.reply('❌ Sorry, I could not generate the summary.');
    }
}

async function handleCot(msg, args) {
    const symbol = args[0] ? args[0].toUpperCase() : 'EURUSD';
    msg.reply(`📊 Fetching COT data for **${symbol}**...`);

    try {
        const response = await axios.post(GOOGLE_APPS_SCRIPT_URL, {
            action: 'getAiMasterSummary',
            data: { symbol: symbol, apiKey: BOT_API_KEY }
        });

        let data = response.data.data;
        if (typeof data === 'string') {
            try {
                data = JSON.parse(data);
            } catch (e) {
                return msg.reply('❌ Received invalid COT data format.');
            }
        }

        const cot = data.positional_thesis || 'No positional thesis available.';
        const cot_raw = data.cot_raw || {};

        const formattedReply = `
*📊 COT Intelligence for ${symbol}*

*Positional Thesis:* ${cot}

*Institutional Data:*
- Longs: ${cot_raw.nonCommercialLong || 0}
- Shorts: ${cot_raw.nonCommercialShort || 0}
- Net Position: ${cot_raw.nonCommercialLong - cot_raw.nonCommercialShort || 0}
        `;
        msg.reply(formattedReply);
    } catch (error) {
        msg.reply('❌ Could not fetch COT data.');
    }
}

async function handleForecast(msg, args) {
    const symbol = args[0] ? args[0].toUpperCase() : 'EURUSD';
    msg.reply(`🔮 Generating 7-day forecast for **${symbol}**...`);

    try {
        const response = await axios.post(GOOGLE_APPS_SCRIPT_URL, {
            action: 'getForecast',
            data: { pair: symbol, timeframe: 'H4', days: 7, apiKey: BOT_API_KEY }
        });

        let forecast = response.data.data;
        if (typeof forecast === 'string') {
            try {
                forecast = JSON.parse(forecast);
            } catch (e) {
                return msg.reply('❌ Received invalid forecast format.');
            }
        }

        const formattedReply = `
*🔮 AI Forecast for ${symbol}*
*Bias:* ${forecast.bias || 'N/A'}
*Probability:* ${forecast.probability || '0'}%
*Entry Zone:* ${forecast.entry_zone || 'N/A'}
*SL:* ${forecast.stop_loss || 'N/A'} | *TP:* ${forecast.take_profit || 'N/A'}
*Confidence:* ${forecast.probability > 70 ? 'High' : 'Medium'}
        `;
        msg.reply(formattedReply);
    } catch (error) {
        msg.reply('❌ Could not generate forecast.');
    }
}

// --- API ENDPOINT FOR SENDING MESSAGES ---
app.post('/send', async (req, res) => {
    const { to, message, apiKey } = req.body;

    if (apiKey !== BOT_API_KEY) {
        return res.status(401).json({ status: 'error', message: 'Unauthorized' });
    }

    if (!clientReady) {
        return res.status(503).json({ status: 'error', message: 'WhatsApp client not ready' });
    }

    try {
        const chatId = to.includes('@c.us') ? to : `${to}@c.us`;
        await client.sendMessage(chatId, message);
        res.json({ status: 'success' });
    } catch (error) {
        res.status(500).json({ status: 'error', message: error.message });
    }
});

app.listen(port, () => {
    console.log(`WhatsApp Bot server listening at http://localhost:${port}`);
});
