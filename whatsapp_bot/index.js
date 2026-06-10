/**
 * 📲 MULKY AI TRADING OS - WHATSAPP BOT SERVER
 *
 * This server connects the Google Apps Script backend to WhatsApp
 * using the whatsapp-web.js library.
 */

const { Client, LocalAuth } = require('whatsapp-web.js');
const qrcode = require('qrcode-terminal');
const axios = require('axios');
const express = require('express');
const bodyParser = require('body-parser');

const app = express();
app.use(bodyParser.json());

// --- CONFIGURATION ---
const GAS_URL = process.env.GAS_URL;
const BOT_API_KEY = process.env.BOT_API_KEY;
const PORT = process.env.PORT || 3000;

const client = new Client({
    authStrategy: new LocalAuth(),
    puppeteer: {
        args: ['--no-sandbox', '--disable-setuid-sandbox']
    }
});

// --- WHATSAPP EVENT HANDLERS ---

client.on('qr', (qr) => {
    qrcode.generate(qr, { small: true });
    console.log('Scan the QR code above to log in.');
});

client.on('ready', () => {
    console.log('WhatsApp Bot is ready!');
});

client.on('message', async (msg) => {
    if (msg.body.startsWith('!')) {
        const [command, ...args] = msg.body.slice(1).split(' ');
        const symbol = args[0] || 'EURUSD';

        try {
            msg.reply(`⏳ Processing request for ${symbol}...`);

            const actionMap = {
                'intel': 'getAiMasterSummary',
                'summary': 'getAiMasterSummary',
                'forecast': 'getForecast',
                'plan': 'getForecast'
            };

            const action = actionMap[command.toLowerCase()] || 'getAiMasterSummary';

            const response = await axios.post(GAS_URL, {
                action: action,
                data: {
                    symbol: symbol,
                    pair: symbol,
                    timeframe: 'H4',
                    days: 3,
                    apiKey: BOT_API_KEY
                }
            });

            if (response.data.status === 'success') {
                const result = response.data.data;
                let replyText = `🔮 *AI ANALYSIS: ${symbol}*\n\n`;

                if (action === 'getAiMasterSummary') {
                    replyText += `Bias: ${result.final_bias}\n`;
                    replyText += `Confidence: ${result.confidence_score}/10\n\n`;
                    replyText += `*Thesis:*\n${result.technical_thesis}\n\n`;
                    if (result.signal && result.signal.active) {
                        replyText += `*🎯 Recommended Setup:*\nEntry: ${result.signal.entry}\nSL: ${result.signal.stop_loss}\nTP: ${result.signal.take_profit}`;
                    }
                } else {
                    replyText += `Forecast: ${result.bias}\n`;
                    replyText += `Prob: ${result.probability}%\n\n`;
                    replyText += `*Zone:* ${result.entry_zone}\n`;
                    replyText += `*Targets:* SL ${result.stop_loss} | TP ${result.take_profit}`;
                }

                msg.reply(replyText);
            } else {
                msg.reply("❌ Error: " + response.data.message);
            }
        } catch (e) {
            console.error(e);
            msg.reply("⚠️ Failed to connect to AI engine.");
        }
    }
});

// --- HTTP ENDPOINTS FOR NOTIFICATIONS ---

app.post('/notify', async (req, res) => {
    const { to, message, apiKey } = req.body;

    if (apiKey !== BOT_API_KEY) {
        return res.status(401).send("Unauthorized");
    }

    try {
        const chatId = to.includes('@c.us') ? to : `${to}@c.us`;
        await client.sendMessage(chatId, message);
        res.status(200).send("Notification sent.");
    } catch (e) {
        console.error(e);
        res.status(500).send("Failed to send notification.");
    }
});

app.listen(PORT, () => {
    console.log(`Notification server listening on port ${PORT}`);
});

client.initialize();
