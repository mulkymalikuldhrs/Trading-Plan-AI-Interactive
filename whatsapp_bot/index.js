const { Client, LocalAuth, Buttons } = require('whatsapp-web.js');
const qrcode = require('qrcode-terminal');
const express = require('express');
const bodyParser = require('body-parser');
const axios = require('axios');

// --- CONFIGURATION ---
const app = express();
const port = process.env.PORT || 3000;
const GOOGLE_APPS_SCRIPT_URL = process.env.GOOGLE_APPS_SCRIPT_URL;
const API_KEY = process.env.API_KEY;

if (!GOOGLE_APPS_SCRIPT_URL || !API_KEY) {
    console.error("CRITICAL ERROR: GOOGLE_APPS_SCRIPT_URL or API_KEY environment variables are not set.");
    process.exit(1);
}

app.use(bodyParser.json());
let clientReady = false;

// --- WHATSAPP CLIENT SETUP ---
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
        '/outlook': handleOutlook,
        '/setup': handleSetup,
        '/forecast': handleForecast,
    };

    if (commandHandlers[command]) {
        await commandHandlers[command](msg, args);
    }
});

// --- COMMAND HANDLER FUNCTIONS ---
async function handleReflect(msg, args) {
    const reflectionPrompt = new Buttons('I noticed you asked for reflection. What was on your mind after your last trade?', [{body: 'It was a good trade'}, {body: 'It was a bad trade'}, {body: 'I broke my rules'}], 'Reflection Time', 'Let me guide you.');
    client.sendMessage(msg.from, reflectionPrompt);
}

async function handleSummary(msg, args) {
    const symbol = args[0] ? args[0].toUpperCase() : 'EURUSD';
    msg.reply(`🤖 Roger that! Generating a full intelligence summary for **${symbol}**...`);

    try {
        const response = await axios.post(GOOGLE_APPS_SCRIPT_URL, {
            action: 'getAiMasterSummary',
            data: {
                symbol: symbol,
                apiKey: API_KEY
            }
        });

        const summary = response.data.data;
        const formattedReply = `
*🧠 AI Master Summary for ${symbol}*
*Bias:* ${summary.final_bias} (Confidence: ${summary.confidence_score}/10)
*Signal Active:* ${summary.signal.active}
*Entry:* ${summary.signal.entry || 'N/A'}
*Stop Loss:* ${summary.signal.stop_loss || 'N/A'}
*Take Profit:* ${summary.signal.take_profit || 'N/A'}
*Read the full analysis in the app!*
        `;
        msg.reply(formattedReply);

    } catch (error) {
        msg.reply('Sorry, I had trouble generating the summary. The AI might be busy. Please try again.');
    }
}

async function handleForecast(msg, args) {
    const symbol = args[0] ? args[0].toUpperCase() : 'EURUSD';
    msg.reply(`🔮 On it! Generating a new forecast for **${symbol}**...`);

    try {
        const response = await axios.post(GOOGLE_APPS_SCRIPT_URL, {
            action: 'getForecast',
            data: {
                pair: symbol,
                timeframe: 'H4',
                days: 7,
                apiKey: API_KEY
            }
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
        msg.reply('I had trouble peering into the future... The forecast engine might be down. Please try again.');
    }
}

async function handleCot(msg, args) {
    const symbol = args[0] ? args[0].toUpperCase() : 'EURUSD';
    const currency = symbol.substring(0, 3);
    msg.reply(`📊 Fetching COT data for **${currency}**...`);

    try {
        const response = await axios.post(GOOGLE_APPS_SCRIPT_URL, {
            action: 'getMarketData',
            data: {
                symbol: symbol,
                apiKey: API_KEY
            }
        });

        const cot = response.data.data.cot_report[currency];
        if (cot) {
            const formattedReply = `
*📊 COT Report for ${currency}*
*Long:* ${cot.long.toLocaleString()}
*Short:* ${cot.short.toLocaleString()}
*Net:* ${cot.net.toLocaleString()}
*Sentiment:* ${cot.sentiment}
            `;
            msg.reply(formattedReply);
        } else {
            msg.reply(`Sorry, I couldn't find COT data for ${currency}.`);
        }
    } catch (error) {
        msg.reply('Error fetching COT data.');
    }
}

async function handleOutlook(msg, args) {
    const symbol = args[0] ? args[0].toUpperCase() : 'EURUSD';
    msg.reply(`🧐 Analyzing outlook for **${symbol}**...`);
    await handleSummary(msg, args);
}

async function handleSetup(msg, args) {
    msg.reply('To validate a setup, please use the Dhaher AI Mobile App for full technical scanning.');
}


// --- API ENDPOINT FOR SENDING MESSAGES ---
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
        if (!clientReady) {
            return res.status(503).json({ status: 'error', message: 'WhatsApp client not ready' });
        }
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
    console.log(`Dhaher Trading Plan AI Bot server listening at http://localhost:${port}`);
});
