const express = require('express');
const axios = require('axios');
const bodyParser = require('body-parser');

const app = express();
const port = process.env.PORT || 3000;

const WEBHOOK_URLS = [
    "https://discord.com/api/webhooks/1377615632081883276/AOzjA8MyFnsDXAhM7X8Pqdo5h0EsPnYJpJbETde34Wg2B-DZzGnKKZJv5iImE2LqViva",
    "https://discord.com/api/webhooks/1377615635109908561/ZV4gNxP8ZXfz4ETEEcEkOtX4IkojYzvQ4fwW2c6T4i73BCYkCCB2YogagnLtt3LfTPYI"
];

app.use(bodyParser.json());

app.post('/webhook', async (req, res) => {
    const { content, tts, embeds } = req.body;

    if (!embeds || !embeds[0]) {
        return res.status(400).json({ error: 'Invalid webhook data' });
    }

    try {
        const promises = WEBHOOK_URLS.map(url =>
            axios.post(url, { content, tts, embeds }, {
                headers: { 'Content-Type': 'application/json' }
            })
        );
        await Promise.all(promises);

        res.status(200).json({ message: 'Webhook forwarded successfully' });
    } catch (error) {
        console.error('Error forwarding webhook:', error.message);
        res.status(500).json({ error: 'Failed to forward webhook' });
    }
});

app.listen(port, () => {
    console.log(`Server running on port ${port}`);
});
