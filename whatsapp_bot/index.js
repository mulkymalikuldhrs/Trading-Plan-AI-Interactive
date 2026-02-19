const { Client, LocalAuth, MessageMedia, List, Buttons } = require('whatsapp-web.js');
const qrcode = require('qrcode-terminal');
const express = require('express');
const axios = require('axios');
require('dotenv').config();

// --- CONFIGURATION ---
const app = express();
const port = process.env.PORT || 3000;
const GOOGLE_APPS_SCRIPT_URL = process.env.GOOGLE_APPS_SCRIPT_URL || "YOUR_GOOGLE_APPS_SCRIPT_WEB_APP_URL";
const API_KEY = process.env.API_KEY;

app.use(express.json());
let clientReady = false;

// --- WHATSAPP CLIENT SETUP ---
const client = new Client({
    authStrategy: new LocalAuth(),
    puppeteer: { args: ['--no-sandbox'] }
});

client.on('qr', (qr) => qrcode.generate(qr, { small: true }));
client.on('ready', () => {
    console.log('Dhaher Trading Plan AI Bot is ready!');
    clientReady = true;
});

// --- COMMAND HANDLING ---
client.on('message', async (msg) => {
    const text = msg.body.toLowerCase();
    const command = text.split(' ')[0];
    const args = text.split(' ').slice(1);

    const commandHandlers = {
        '!reflect': handleReflect,
        '/summary': handleSummary,
        '/cot': handleCot,
        '/outlook': handleSummary, // Aliasing outlook to summary
        '/setup': handleSetup,
        '/forecast': handleForecast,
        '/ping': (msg) => msg.reply('pong 🏓'),
    };

    if (commandHandlers[command]) {
        await commandHandlers[command](msg, args);
    }
});

client.initialize();


// --- COMMAND HANDLER FUNCTIONS ---
async function handleReflect(msg, args) {
    const reflectionPrompt = new Buttons('Reflection Time: How was your last trade?', [{body: 'Followed Plan'}, {body: 'Broke Rules'}, {body: 'Emotional'}], 'Dhaher AI Coach', 'I am here to help you stay disciplined.');
    client.sendMessage(msg.from, reflectionPrompt);
}

async function handleSummary(msg, args) {
    const symbol = args[0] ? args[0].toUpperCase() : 'EURUSD';
    msg.reply(`🤖 Generating intelligence summary for **${symbol}**...`);

    try {
        const response = await axios.post(GOOGLE_APPS_SCRIPT_URL, {
            action: 'getAiMasterSummary',
            data: { symbol: symbol }
        });

        if (response.data.status === 'success') {
            const summary = response.data.data;
            const formattedReply = `
*🧠 AI Master Summary: ${symbol}*
*Bias:* ${summary.final_bias} (Confidence: ${summary.confidence_score}/10)

*Technical Thesis:* ${summary.technical_thesis}
*Fundamental Thesis:* ${summary.fundamental_thesis}
*Positional (COT) Thesis:* ${summary.positional_thesis}

*Signal:* ${summary.signal.active ? '✅ ACTIVE' : '❌ INACTIVE'}
${summary.signal.active ? `*Entry:* ${summary.signal.entry}\n*SL:* ${summary.signal.stop_loss}\n*TP:* ${summary.signal.take_profit}` : ''}
            `;
            msg.reply(formattedReply);
        } else {
            msg.reply('GAS Error: ' + response.data.message);
        }
    } catch (error) {
        console.error(error);
        msg.reply('Sorry, I had trouble connecting to the AI brain.');
    }
}

async function handleForecast(msg, args) {
    const symbol = args[0] ? args[0].toUpperCase() : 'EURUSD';
    msg.reply(`🔮 Peer into the future of **${symbol}**...`);

    try {
        const response = await axios.post(GOOGLE_APPS_SCRIPT_URL, {
            action: 'getGptFeedback',
            data: {
                promptType: 'Forecast',
                promptData: { pair: symbol, timeframe: 'H4', days: 7, technical_structure: 'Mixed', current_price: 'Market', supply_area: 'Unknown', cot_summary: 'Mixed', fundamental_summary: 'Mixed' },
                referenceId: 'WS-FORECAST-' + symbol
            }
        });

        if (response.data.status === 'success') {
            const forecast = response.data.data;
            const formattedReply = `
*🔮 7-Day Outlook: ${symbol}*
*Bias:* ${forecast.bias}
*Probability:* ${forecast.probability}%
*Entry Zone:* ${forecast.entry_zone}
*Confirmation:* ${forecast.confirmation}
*SL:* ${forecast.stop_loss} | *TP:* ${forecast.take_profit}
            `;
            msg.reply(formattedReply);
        }
    } catch (error) {
        msg.reply('Forecast engine is currently cooling down.');
    }
}

async function handleCot(msg, args) {
    const symbol = args[0] ? args[0].toUpperCase() : 'EUR';
    msg.reply(`📊 Fetching Commitment of Traders data for **${symbol}**...`);
    // In a real app, this would call GAS to get COT specific data
    // For now, we'll use a simplified response or reuse summary
    msg.reply(`Institutional sentiment for ${symbol} is currently being processed. Check /summary for integrated analysis.`);
}

async function handleSetup(msg, args) {
    msg.reply('🔍 To validate a setup, please use the mobile app for a full visual experience and TradingView integration.');
}


// --- API ENDPOINT FOR SENDING MESSAGES ---
app.post('/send', async (req, res) => {
    const { to, message, api_key } = req.body;

    if (API_KEY && api_key !== API_KEY) {
        return res.status(401).json({ status: 'error', message: 'Unauthorized.' });
    }

    if (!clientReady) {
        return res.status(503).json({ status: 'error', message: 'WhatsApp client not ready.' });
    }

    try {
        const formattedTo = to.includes('@c.us') ? to : `${to}@c.us`;
        await client.sendMessage(formattedTo, message);
        res.json({ status: 'success', message: 'Message sent.' });
    } catch (error) {
        res.status(500).json({ status: 'error', message: 'Failed to send.' });
    }
});

app.listen(port, () => {
    console.log(`WhatsApp Bot listening at http://localhost:${port}`);
});
