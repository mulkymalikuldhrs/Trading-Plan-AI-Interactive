const { Client, LocalAuth, MessageMedia, Buttons } = require('whatsapp-web.js');
const qrcode = require('qrcode-terminal');
const express = require('express');
const bodyParser = require('body-parser');
const axios = require('axios');

// --- CONFIGURATION ---
const app = express();
const port = process.env.PORT || 3000;
// Use environment variables for production security
const GOOGLE_APPS_SCRIPT_URL = process.env.GAS_URL;
const BOT_API_KEY = process.env.BOT_API_KEY;

if (!GOOGLE_APPS_SCRIPT_URL || !BOT_API_KEY) {
    console.error("FATAL: GAS_URL or BOT_API_KEY environment variables are not set.");
    process.exit(1);
}

app.use(bodyParser.json());
let clientReady = false;

// --- WHATSAPP CLIENT SETUP ---
const client = new Client({
    authStrategy: new LocalAuth(),
    puppeteer: {
        args: ['--no-sandbox', '--disable-setuid-sandbox'],
        executablePath: process.env.PUPPETEER_EXECUTABLE_PATH || null
    }
});

client.on('qr', (qr) => {
    console.log('Scan the QR code below to login:');
    qrcode.generate(qr, { small: true });
});

client.on('ready', () => {
    console.log('Dhaher Trading Plan AI Bot is ready and hardened!');
    clientReady = true;
});

client.on('auth_failure', msg => {
    console.error('AUTHENTICATION FAILURE', msg);
});

client.on('disconnected', (reason) => {
    console.log('Client was logged out', reason);
});

// --- ADVANCED COMMAND HANDLING ---
client.on('message', async (msg) => {
    try {
        const text = msg.body.trim().toLowerCase();
        if (!text.startsWith('/') && !text.startsWith('!')) return;

        const parts = text.split(' ');
        const command = parts[0];
        const args = parts.slice(1);

        const commandHandlers = {
            '!reflect': handleReflect,
            '/summary': handleSummary,
            '/cot': handleCot,
            '/forecast': handleForecast,
            '/ping': (m) => m.reply('pong')
        };

        if (commandHandlers[command]) {
            await commandHandlers[command](msg, args);
        }
    } catch (error) {
        console.error("Error handling message:", error);
        msg.reply("An internal error occurred while processing your request.");
    }
});

client.initialize();


// --- COMMAND HANDLER FUNCTIONS ---
async function handleReflect(msg, args) {
    // Note: Buttons might not work on all WhatsApp clients/versions
    msg.reply("I noticed you asked for reflection. What was on your mind after your last trade?\n\n1. It was a good trade\n2. It was a bad trade\n3. I broke my rules\n\nReply with the number to continue.");
}

async function handleSummary(msg, args) {
    const symbol = args[0] ? args[0].toUpperCase() : 'EURUSD';
    msg.reply(`🤖 Roger that! Generating a full intelligence summary for **${symbol}**...`);

    try {
        const response = await axios.post(GOOGLE_APPS_SCRIPT_URL, {
            action: 'getAiMasterSummary',
            apiKey: BOT_API_KEY,
            data: { symbol: symbol }
        });

        if (response.data.status === 'success') {
            const summary = response.data.data;
            const formattedReply = `
*🧠 AI Master Summary for ${symbol}*
*Bias:* ${summary.final_bias} (Confidence: ${summary.confidence_score}/10)
*Signal Active:* ${summary.signal.active}
*Entry:* ${summary.signal.entry || 'N/A'}
*Stop Loss:* ${summary.signal.stop_loss || 'N/A'}
*Take Profit:* ${summary.signal.take_profit || 'N/A'}

*Thesis:* ${summary.technical_thesis || 'No specific thesis provided.'}

*Read the full analysis in the app!*
            `;
            msg.reply(formattedReply.trim());
        } else {
            msg.reply(`Error from AI: ${response.data.message}`);
        }

    } catch (error) {
        console.error("Summary error:", error.message);
        msg.reply('Sorry, I had trouble generating the summary. The AI might be busy. Please try again.');
    }
}

async function handleForecast(msg, args) {
    const symbol = args[0] ? args[0].toUpperCase() : 'EURUSD';
    msg.reply(`🔮 On it! Generating a new forecast for **${symbol}**...`);

    try {
        const response = await axios.post(GOOGLE_APPS_SCRIPT_URL, {
            action: 'getForecast',
            apiKey: BOT_API_KEY,
            data: { pair: symbol, timeframe: 'H4', days: 7 }
        });

        if (response.data.status === 'success') {
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
            msg.reply(formattedReply.trim());
        } else {
            msg.reply(`Error from Forecast Engine: ${response.data.message}`);
        }

    } catch (error) {
        console.error("Forecast error:", error.message);
        msg.reply('I had trouble peering into the future... The forecast engine might be down. Please try again.');
    }
}

async function handleCot(msg, args) {
    const symbol = args[0] ? args[0].toUpperCase() : 'EURUSD';
    msg.reply(`📊 Fetching COT data for **${symbol}**...`);
    try {
        const response = await axios.post(GOOGLE_APPS_SCRIPT_URL, {
            action: 'getCotAnalysis',
            apiKey: BOT_API_KEY,
            data: { symbol: symbol }
        });
        if (response.data.status === 'success') {
            const cot = response.data.data;
            msg.reply(`*COT Analysis for ${symbol}*\n*Institutional Bias:* ${cot.bias}\n*Net Position:* ${cot.netPosition}\n*Retail Sentiment:* ${cot.retailShort}% Short`);
        } else {
            msg.reply("Failed to fetch COT data.");
        }
    } catch (e) {
        msg.reply("Error connecting to COT data source.");
    }
}


// --- API ENDPOINT FOR SENDING NOTIFICATIONS FROM GAS ---
app.post('/send', (req, res) => {
    const { apiKey, to, message } = req.body;

    if (apiKey !== BOT_API_KEY) {
        return res.status(403).json({ status: 'error', message: 'Unauthorized' });
    }

    if (!clientReady) {
        return res.status(503).json({ status: 'error', message: 'WhatsApp client not ready' });
    }

    const chatId = to.includes('@c.us') ? to : `${to}@c.us`;

    client.sendMessage(chatId, message)
        .then(response => {
            res.json({ status: 'success', messageId: response.id._serialized });
        })
        .catch(err => {
            console.error("Error sending message:", err);
            res.status(500).json({ status: 'error', message: err.message });
        });
});

app.listen(port, () => {
    console.log(`Dhaher Trading Plan AI Bot server listening at http://localhost:${port}`);
});
