const express = require('express');
const { Client, IntentsBitField, EmbedBuilder } = require('discord.js');
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
    // Add more mappings for 50-60 UniverseIds as needed
    "default": "1377615632081883276" // Fallback channel for unmatched UniverseIds
};

app.use(bodyParser.json());

// Log when bot is ready
client.once('ready', () => {
    console.log(`[${new Date().toISOString()}] Discord bot logged in as ${client.user.tag}`);
});

// Handle webhook POST requests
app.post('/webhook', async (req, res) => {
    const { Key, Executor, ExecutorLevel, GameName, GameLink, UniverseId } = req.body;

    // Validate incoming data
    if (!Key || !Executor || !ExecutorLevel || !GameName || !GameLink || !UniverseId) {
        console.error(`[${new Date().toISOString()}] Invalid webhook data received`);
        return res.status(400).json({ error: 'Invalid webhook data: Missing required fields' });
    }

    console.log(`[${new Date().toISOString()}] Received webhook request for game: ${GameName} (UniverseId: ${UniverseId})`);

    // Create Discord embed
    const embed = new EmbedBuilder()
        .setTitle('H4xScripts')
        .setDescription(
            `**Game**: [${GameName}](${GameLink})\n` +
            `**Key**: \`${Key}\`\n` +
            `**Executor**: \`${Executor}\`\n` +
            `**Executor Level**: \`${ExecutorLevel}\`\n` +
            `**Universe ID**: \`${UniverseId}\``
        )
        .setColor(0xffa500) // Orange, equivalent to 16753920
        .setFooter({ text: new Date().toISOString().slice(0, 19).replace('T', ' ') });

    try {
        // Get the target channel ID based on UniverseId
        const channelId = UNIVERSE_TO_CHANNEL[UniverseId] || UNIVERSE_TO_CHANNEL["default"];
        const channel = await client.channels.fetch(channelId);

        if (!channel) {
            console.error(`[${new Date().toISOString()}] Channel not found: ${channelId}`);
            return res.status(500).json({ error: 'Channel not found' });
        }

        // Send the embed to the target channel
        await channel.send({ embeds: [embed] });
        console.log(`[${new Date().toISOString()}] Embed sent to channel: ${channelId}`);

        res.status(200).json({
            message: 'Webhook processed successfully',
            sent_to: channelId
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
