const { Client, LocalAuth, MessageMedia, List, Buttons } = require('whatsapp-web.js');
const qrcode = require('qrcode-terminal');
const express = require('express');
const bodyParser = require('body-parser');
const axios = require('axios'); // For calling Google Apps Script

// --- CONFIGURATION ---
const app = express();
const port = process.env.PORT || 3000;
const GOOGLE_APPS_SCRIPT_URL = "YOUR_GOOGLE_APPS_SCRIPT_WEB_APP_URL";

app.use(bodyParser.json());
let clientReady = false;

// --- WHATSAPP CLIENT SETUP ---
const client = new Client({
    authStrategy: new LocalAuth(),
    puppeteer: {
        args: ['--no-sandbox'],
    }
});

client.on('qr', (qr) => qrcode.generate(qr, { small: true }));
client.on('ready', () => {
    console.log('WhatsApp client is ready!');
    clientReady = true;
});

// --- ADVANCED COMMAND HANDLING ---
client.on('message', async (msg) => {
    const text = msg.body.toLowerCase();

    if (text === '!reflect') {
        const reflectionPrompt = new Buttons('I noticed you asked for reflection. What was on your mind after your last trade?', [{body: 'It was a good trade'}, {body: 'It was a bad trade'}, {body: 'I broke my rules'}], 'Reflection Time', 'Let me guide you.');
        client.sendMessage(msg.from, reflectionPrompt);
    }

    if (text === '!summary') {
        msg.reply('🤖 Generating your weekly summary... this might take a moment.');
        try {
            // Trigger the Google Apps Script to run the analysis
            const response = await axios.post(GOOGLE_APPS_SCRIPT_URL, {
                action: 'triggerWeeklyAnalysis',
                data: {}
            });
            // The Apps Script will send the summary back via the /send endpoint
            // No need to do anything else here.
        } catch (error) {
            msg.reply('Sorry, I had trouble generating your summary. Please try again later.');
        }
    }
});

client.initialize();

// --- API ENDPOINT FOR SENDING MESSAGES ---
app.post('/send', (req, res) => {
    if (!clientReady) {
        return res.status(503).json({ status: 'error', message: 'WhatsApp client is not ready.' });
    }

    const { to, message, type, options } = req.body;
    if (!to || !message) {
        return res.status(400).json({ status: 'error', message: 'Missing "to" or "message".' });
    }

    const chatId = `${to}@c.us`;
    let messageObject;

    // Build message based on type (for quick actions)
    switch (type) {
        case 'buttons':
            messageObject = new Buttons(message, options.buttons, options.title, options.footer);
            break;
        case 'list':
            messageObject = new List(message, options.buttonText, options.sections);
            break;
        default:
            messageObject = message;
    }

    client.sendMessage(chatId, messageObject).then(response => {
        res.status(200).json({ status: 'success', data: response });
    }).catch(err => {
        res.status(500).json({ status: 'error', message: 'Failed to send message.', details: err });
    });
});

app.listen(port, () => {
    console.log(`WhatsApp Bot server listening at http://localhost:${port}`);
});
