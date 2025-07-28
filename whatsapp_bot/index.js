const { Client } = require('whatsapp-web.js');
const qrcode = require('qrcode-terminal');

const client = new Client();

client.on('qr', (qr) => {
    // Generate and scan this code with your phone
    qrcode.generate(qr, { small: true });
});

client.on('ready', () => {
    console.log('WhatsApp Bot is ready!');
});

client.on('message', msg => {
    if (msg.body == '!ping') {
        msg.reply('pong');
    }
});

client.initialize();

// Function to send a message
function sendMessage(to, message) {
    // to: country code + number (e.g., '1234567890@c.us')
    client.sendMessage(to, message);
}

// Example:
// sendMessage('1234567890@c.us', 'This is a test message from Mulky AI OS.');
