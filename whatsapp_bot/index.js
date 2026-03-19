const { Client, LocalAuth, Buttons } = require('whatsapp-web.js');
const qrcode = require('qrcode-terminal');
const express = require('express');
const bodyParser = require('body-parser');
const axios = require('axios');
require('dotenv').config();

// --- CONFIGURATION ---
const app = express();
const port = process.env.PORT || 3000;
const GAS_URL = process.env.GAS_URL;
const API_KEY = process.env.BOT_API_KEY || process.env.API_KEY;

app.use(bodyParser.json());

let clientReady = false;

// --- WHATSAPP CLIENT SETUP ---
const client = new Client({
    authStrategy: new LocalAuth(),
    puppeteer: {
        args: ['--no-sandbox', '--disable-setuid-sandbox'],
        headless: true
    }
});

client.on('qr', (qr) => {
    console.log('Scan the QR code below to login:');
    qrcode.generate(qr, { small: true });
});

client.on('ready', () => {
    console.log('✅ Dhaher Trading Plan AI Bot is ready!');
    clientReady = true;
});

client.on('authenticated', () => {
    console.log('✅ WhatsApp authenticated successfully!');
});

client.on('auth_failure', (msg) => {
    console.error('❌ WhatsApp authentication failed:', msg);
});

// --- COMMAND HANDLING ---
client.on('message', async (msg) => {
    if (!clientReady) return;

    const text = msg.body.trim();
    if (!text.startsWith('/') && !text.startsWith('!')) return;

    const parts = text.split(' ');
    const command = parts[0].toLowerCase();
    const args = parts.slice(1);

    console.log(`Received command: ${command} with args: ${args}`);

    try {
        switch (command) {
            case '!ping':
                msg.reply('pong');
                break;
            case '!reflect':
                await handleReflect(msg);
                break;
            case '/summary':
            case '/outlook':
                await handleSummary(msg, args);
                break;
            case '/forecast':
                await handleForecast(msg, args);
                break;
            case '/cot':
                await handleCot(msg);
                break;
            case '/setup':
                await handleSetup(msg);
                break;
            default:
                // Unknown command
                break;
        }
    } catch (error) {
        console.error(`Error handling command ${command}:`, error);
        msg.reply('❌ An error occurred while processing your command.');
    }
});

client.initialize();

// --- HANDLER FUNCTIONS ---

async function handleReflect(msg) {
    const reflectionPrompt = "🧠 *Reflection Time*\n\nI noticed you're reflecting on your trading. What's on your mind?\n1. It was a good trade (Discipline)\n2. It was a bad trade (Mistake)\n3. I broke my rules (Violated)\n\nReply with the number or just talk to me.";
    msg.reply(reflectionPrompt);
}

async function handleSummary(msg, args) {
    const symbol = (args[0] || 'EURUSD').toUpperCase();
    msg.reply(`🤖 *Master Analyst* is analyzing **${symbol}**... Please wait.`);

    try {
        const response = await axios.post(GAS_URL, {
            action: 'getAiMasterSummary',
            data: { symbol: symbol }
        });

        if (response.data.status === 'success') {
            const summary = response.data.data;
            const formattedReply = `
*🧠 AI Master Summary: ${symbol}*
*Bias:* ${summary.final_bias} (Confidence: ${summary.confidence_score}/10)

*Thesis:*
- Tech: ${summary.technical_thesis}
- Funda: ${summary.fundamental_thesis}
- COT: ${summary.positional_thesis}

*Signal:* ${summary.signal.active ? '✅ ACTIVE' : '❌ NONE'}
${summary.signal.active ? `Entry: ${summary.signal.entry}\nSL: ${summary.signal.stop_loss}\nTP: ${summary.signal.take_profit}` : ''}
            `;
            msg.reply(formattedReply.trim());
        } else {
            msg.reply(`❌ API Error: ${response.data.message}`);
        }
    } catch (error) {
        msg.reply('❌ Failed to connect to the AI engine.');
    }
}

async function handleForecast(msg, args) {
    const symbol = (args[0] || 'EURUSD').toUpperCase();
    msg.reply(`🔮 *Forecast Engine* is peering into the future of **${symbol}**...`);

    try {
        const response = await axios.post(GAS_URL, {
            action: 'getForecast',
            data: { pair: symbol, timeframe: 'H4', days: 7 }
        });

        if (response.data.status === 'success') {
            const forecast = response.data.data;
            const formattedReply = `
*🔮 7-Day Forecast: ${symbol}*
*Bias:* ${forecast.bias} (${forecast.probability}%)

*Outlook:*
${forecast.analysis}

*Key Levels:*
- Entry Zone: ${forecast.entry_zone}
- Stop Loss: ${forecast.stop_loss}
- Take Profit: ${forecast.take_profit}
- Confirmation: ${forecast.confirmation}
            `;
            msg.reply(formattedReply.trim());
        } else {
            msg.reply(`❌ API Error: ${response.data.message}`);
        }
    } catch (error) {
        msg.reply('❌ Failed to reach the forecast engine.');
    }
}

async function handleCot(msg) {
    msg.reply('📊 *COT Insights* fetching latest institutional positions...');
    try {
        // We can use getAiMasterSummary or a dedicated action,
        // but here we just show COT from a summary for EURUSD as default.
        const response = await axios.post(GAS_URL, {
            action: 'getAiMasterSummary',
            data: { symbol: 'EURUSD' }
        });
        const summary = response.data.data;
        msg.reply(`*Institutional Sentiment (COT):*\n${summary.positional_thesis}`);
    } catch (e) {
        msg.reply('❌ Could not fetch COT data.');
    }
}

async function handleSetup(msg) {
    const setupInfo = `
🚀 *Dhaher AI Setup Guide*

1. *Deploy GAS*: Make sure your Google Apps Script is deployed as a Web App.
2. *Set .env*: Configure GAS_URL in your bot's .env file.
3. *Flutter App*: Update GAS_URL in ApiService.
4. *WhatsApp*: Scan the QR code to keep the bot active.

Type /summary [pair] to start!
    `;
    msg.reply(setupInfo.trim());
}

// --- API ENDPOINT FOR SENDING NOTIFICATIONS ---

app.post('/send', (req, res) => {
    const { to, message, api_key } = req.body;

    if (API_KEY && api_key !== API_KEY) {
        return res.status(401).json({ status: 'error', message: 'Unauthorized' });
    }

    if (!clientReady) {
        return res.status(503).json({ status: 'error', message: 'WhatsApp client not ready' });
    }

    const formattedTo = to.includes('@c.us') ? to : `${to}@c.us`;

    client.sendMessage(formattedTo, message)
        .then(response => {
            res.json({ status: 'success', data: response.id });
        })
        .catch(err => {
            res.status(500).json({ status: 'error', message: err.message });
        });
});

app.listen(port, () => {
    console.log(`🚀 WhatsApp Bot Server running on port ${port}`);
});
