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

// Function to get a random webhook URL
function getRandomWebhook() {
    return WEBHOOK_URLS[Math.floor(Math.random() * WEBHOOK_URLS.length)];
}

async function validateWebhook(url) {
    try {
        const response = await axios.get(url);
        if (response.status === 200) {
            console.log(`[${new Date().toISOString()}] Validated webhook: ${url}`);
            return true;
        }
        console.error(`[${new Date().toISOString()}] Invalid webhook: ${url} (Status: ${response.status})`);
        return false;
    } catch (error) {
        console.error(`[${new Date().toISOString()}] Error validating webhook ${url}: ${error.message}`);
        return false;
    }
}

async function sendWebhook(url, data, retries = 3, delay = 2000) {
    try {
        console.log(`[${new Date().toISOString()}] Attempting to send to ${url} for game: ${data.embeds[0]?.description?.match(/\*\*Game\*\*: \[(.+?)\]/)?.[1] || 'Unknown'}`);
        await axios.post(url, data, {
            headers: { 'Content-Type': 'application/json' }
        });
        console.log(`[${new Date().toISOString()}] Successfully sent to ${url}`);
    } catch (error) {
        if (error.response?.status === 429 && retries > 0) {
            const retryAfter = (error.response?.headers['x-ratelimit-reset-after'] || delay / 1000) * 1000;
            console.warn(`[${new Date().toISOString()}] Rate limit hit for ${url}, retrying in ${retryAfter/1000}s (${retries} retries left). Limit: ${error.response?.headers['x-ratelimit-limit'] || 'Unknown'}, Remaining: ${error.response?.headers['x-ratelimit-remaining'] || 'Unknown'}, Reset-After: ${error.response?.headers['x-ratelimit-reset-after'] || 'Unknown'}s`);
            await new Promise(resolve => setTimeout(resolve, retryAfter));
            return sendWebhook(url, data, retries - 1, delay * 2); // Exponential backoff
        }
        throw new Error(`Failed to send webhook to ${url}: ${error.message}${error.response ? ` (Status: ${error.response.status}, Rate-Limit-Reset-After: ${error.response.headers['x-ratelimit-reset-after']}s)` : ''}`);
    }
}

app.post('/webhook', async (req, res) => {
    const { content, tts, embeds } = req.body;

    if (!embeds || !embeds[0]) {
        console.error(`[${new Date().toISOString()}] Invalid webhook data received`);
        return res.status(400).json({ error: 'Invalid webhook data' });
    }

    const gameName = embeds[0].description?.match(/\*\*Game\*\*: \[(.+?)\]/)?.[1] || 'Unknown';
    console.log(`[${new Date().toISOString()}] Received webhook request for game: ${gameName}`);

    try {
        // Select a random webhook URL
        const selectedWebhook = getRandomWebhook();
        console.log(`[${new Date().toISOString()}] Selected webhook: ${selectedWebhook}`);
        
        // Send to only the selected webhook
        await sendWebhook(selectedWebhook, { content, tts, embeds });
        
        res.status(200).json({ 
            message: 'Webhook forwarded successfully',
            sent_to: selectedWebhook
        });
    } catch (error) {
        console.error(`[${new Date().toISOString()}] Error forwarding webhook: ${error.message}`);
        res.status(500).json({ 
            error: 'Failed to forward webhook',
            details: error.message
        });
    }
});

// Validate webhooks on startup
app.listen(port, async () => {
    console.log(`Server running on port ${port}`);
    console.log(`[${new Date().toISOString()}] Validating webhooks on startup...`);
    for (const url of WEBHOOK_URLS) {
        await validateWebhook(url);
    }
});
