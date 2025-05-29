const express = require('express');
const { Client, IntentsBitField, WebhookClient } = require('discord.js');
const bodyParser = require('body-parser');

const app = express();
const port = process.env.PORT || 3000;
const botToken = process.env.Bot_Token;

if (!botToken) {
    console.error(`[${new Date().toISOString()}] Bot_Token not found in environment variables`);
    process.exit(1);
}

// Initialize Discord bot
const client = new Client({
    intents: [
        IntentsBitField.Flags.Guilds,
        IntentsBitField.Flags.GuildMessages
    ]
});

// UniverseId to Channel ID mappings
const UNIVERSE_TO_CHANNEL = {
    "6161049307": "1377615632081883276", // Channel for Pixel Blade
    "7436755782": "1377615635109908561", // Channel for Grow a Garden
    "6022141304": "CHANNEL_ID_3", // Replace with actual channel ID
    "7332711118": "CHANNEL_ID_4", // Replace with actual channel ID
    "7468338447": "CHANNEL_ID_5", // Replace with actual channel ID
    "7546582051": "CHANNEL_ID_6", // Replace with actual channel ID
    "default": "1377615632081883276" // Fallback channel for unmatched UniverseIds
};

// Store webhooks for each channel (in-memory; consider a database for persistence)
const channelWebhooks = new Map();

app.use(bodyParser.json());

// Log when bot is ready and initialize webhooks
client.once('ready', async () => {
    console.log(`[${new Date().toISOString()}] Discord bot logged in as ${client.user.tag}`);

    // Initialize webhooks for each channel
    for (const [universeId, channelId] of Object.entries(UNIVERSE_TO_CHANNEL)) {
        try {
            const channel = await client.channels.fetch(channelId);
            if (!channel) {
                console.error(`[${new Date().toISOString()}] Channel not found: ${channelId}`);
                continue;
            }

            await ensureWebhooks(channel, channelId);
        } catch (error) {
            console.error(`[${new Date().toISOString()}] Error initializing webhooks for channel ${channelId}: ${error.message}`);
        }
    }
});

// Ensure up to 5 webhooks exist in a channel
async function ensureWebhooks(channel, channelId) {
    const webhooks = await channel.fetchWebhooks();
    const h4xWebhooks = webhooks.filter(wh => wh.name === 'H4xScript');

    // If fewer than 5 webhooks, create more
    const webhooksToCreate = 5 - h4xWebhooks.size;
    if (webhooksToCreate > 0) {
        console.log(`[${new Date().toISOString()}] Creating ${webhooksToCreate} webhook(s) for channel ${channelId}`);
        for (let i = 0; i < webhooksToCreate; i++) {
            await channel.createWebhook({
                name: 'H4xScript',
                avatar: 'https://cdn.discordapp.com/avatars/1362841147424374895/4b77da63ba23d49b169b6a7f9717d527.png'
            });
        }
    }

    // Store webhook IDs in memory
    const webhookIds = (await channel.fetchWebhooks()).filter(wh => wh.name === 'H4xScript').map(wh => ({ id: wh.id, token: wh.token }));
    channelWebhooks.set(channelId, webhookIds);
    console.log(`[${new Date().toISOString()}] Webhooks for channel ${channelId}: ${webhookIds.length}`);
}

// Handle webhook POST requests
app.post('/webhook', async (req, res) => {
    const { Key, Executor, ExecutorLevel, GameName, GameLink, UniverseId } = req.body;

    // Validate incoming data
    if (!Key || !Executor || !ExecutorLevel || !GameName || !GameLink || !UniverseId) {
        console.error(`[${new Date().toISOString()}] Invalid webhook data received`);
        return res.status(400).json({ error: 'Invalid webhook data: Missing required fields' });
    }

    console.log(`[${new Date().toISOString()}] Received webhook request for game: ${GameName} (UniverseId: ${UniverseId})`);

    try {
        // Get the target channel ID
        const channelId = UNIVERSE_TO_CHANNEL[UniverseId] || UNIVERSE_TO_CHANNEL["default"];
        const channel = await client.channels.fetch(channelId);

        if (!channel) {
            console.error(`[${new Date().toISOString()}] Channel not found: ${channelId}`);
            return res.status(500).json({ error: 'Channel not found' });
        }

        // Ensure webhooks exist
        if (!channelWebhooks.has(channelId)) {
            await ensureWebhooks(channel, channelId);
        }

        // Get random webhook
        const webhooks = channelWebhooks.get(channelId);
        if (!webhooks || webhooks.length === 0) {
            console.error(`[${new Date().toISOString()}] No webhooks available for channel: ${channelId}`);
            return res.status(500).json({ error: 'No webhooks available' });
        }

        const randomWebhook = webhooks[Math.floor(Math.random() * webhooks.length)];
        const webhookClient = new WebhookClient({ id: randomWebhook.id, token: randomWebhook.token });

        // Send plain message with all data except UniverseId
        const message = `Game: ${GameName}\nLink: ${GameLink}\nKey: ${Key}\nExecutor: ${Executor}\nExecutor Level: ${ExecutorLevel}`;
        await webhookClient.send(message);
        console.log(`[${new Date().toISOString()}] Message sent to channel ${channelId} via webhook ${randomWebhook.id}`);

        res.status(200).json({
            message: 'Webhook processed successfully',
            sent_to: channelId,
            webhook_id: randomWebhook.id
        });
    } catch (error) {
        console.error(`[${new Date().toISOString()}] Error sending to channel: ${error.message}`);
        res.status(500).json({
            error: 'Failed to send webhook',
            details: error.message
        });
    }
});

// Start the Express server and log in the bot
app.listen(port, async () => {
    console.log(`[${new Date().toISOString()}] Server running on port ${port}`);
    try {
        await client.login(botToken);
    } catch (error) {
        console.error(`[${new Date().toISOString()}] Failed to log in bot: ${error.message}`);
        process.exit(1);
    }
});
