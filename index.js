const express = require('express');
const { Client, IntentsBitField, WebhookClient, EmbedBuilder, Collection } = require('discord.js');
const bodyParser = require('body-parser');
const fs = require('fs');
const path = require('path');
const { Octokit } = require('@octokit/rest');

const app = express();
const port = process.env.PORT || 3000;
const botToken = process.env.Bot_Token;
const githubToken = process.env.GITHUB_TOKEN;

if (!botToken) {
    console.error(`[${new Date().toISOString()}] Bot_Token not found in environment variables`);
    process.exit(1);
}

if (!githubToken) {
    console.error(`[${new Date().toISOString()}] GITHUB_TOKEN not found in environment variables`);
    process.exit(1);
}

// Initialize Octokit for GitHub API
const octokit = new Octokit({ auth: githubToken });

// GitHub repository details (replace with your repo details or use env variables)
const GITHUB_OWNER = process.env.GITHUB_OWNER || 'your-username';
const GITHUB_REPO = process.env.GITHUB_REPO || 'your-repo';
const DATA_FILE_PATH = 'data.json';

// Initialize Discord bot
const client = new Client({
    intents: [
        IntentsBitField.Flags.Guilds,
        IntentsBitField.Flags.GuildMessages,
        IntentsBitField.Flags.MessageContent
    ]
});

// UniverseId to Channel ID mappings
const UNIVERSE_TO_CHANNEL = {
    "6161049307": "1377728605207007362", // Channel for Pixel Blade
    "7436755782": "1377720529603264673", // Channel for Grow a Garden
    "6022141304": "1377728540841083020", // Replace with actual channel ID
    "7332711118": "1377728632868442263", // Replace with actual channel ID
    "7468338447": "1377728512630194266", // Replace with actual channel ID
    "7546582051": "1377728571308511384", // Replace with actual channel ID
    "default": "1377728912142110862" // Fallback channel for unmatched UniverseIds
};

// Label map for webhook stats
const labelMap = {
    "1377728605207007362": "pixel_blade",
    "1377720529603264673": "grow_a_garden",
    "1377728540841083020": "game3",
    "1377728632868442263": "game4",
    "1377728512630194266": "game5",
    "1377728571308511384": "game6",
    "1377728912142110862": "unknown_game"
};

// Initialize webhook stats
const webhookStats = {
    pixel_blade: { sent: 0, failed: 0 },
    grow_a_garden: { sent: 0, failed: 0 },
    game3: { sent: 0, failed: 0 },
    game4: { sent: 0, failed: 0 },
    game5: { sent: 0, failed: 0 },
    game6: { sent: 0, failed: 0 },
    unknown_game: { sent: 0, failed: 0 }
};

// Store webhooks for each channel (in-memory)
const channelWebhooks = new Map();

// Command prefix
const PREFIX = '!';

// Initialize commands collection
client.commands = new Collection();

app.use(bodyParser.json());

// Load commands from Cmds folder
const commandsPath = path.join(__dirname, 'Cmds');
const commandFiles = fs.readdirSync(commandsPath).filter(file => file.endsWith('.js'));

for (const file of commandFiles) {
    const filePath = path.join(commandsPath, file);
    try {
        const command = require(filePath);
        if ('name' in command && 'execute' in command) {
            client.commands.set(command.name, command);
            console.log(`[${new Date().toISOString()}] Loaded command: ${command.name}`);
        }
    } catch (err) {
        console.error(`[${new Date().toISOString()}] Error loading command ${file}: ${err.message}`);
    }
}

// Function to get current data.json from GitHub
async function getGitHubFile() {
    try {
        const response = await octokit.repos.getContent({
            owner: GITHUB_OWNER,
            repo: GITHUB_REPO,
            path: DATA_FILE_PATH
        });
        const content = Buffer.from(response.data.content, 'base64').toString('utf8');
        return JSON.parse(content);
    } catch (error) {
        if (error.status === 404) {
            // File doesn't exist yet, return default structure
            return { webhookStats, warnings: [] };
        }
        console.error(`[${new Date().toISOString()}] Error fetching data.json: ${error.message}`);
        throw error;
    }
}

// Function to update data.json in GitHub
async function updateGitHubFile(data) {
    try {
        const currentFile = await octokit.repos.getContent({
            owner: GITHUB_OWNER,
            repo: GITHUB_REPO,
            path: DATA_FILE_PATH
        }).catch(() => null);

        const content = Buffer.from(JSON.stringify(data, null, 2)).toString('base64');
        const message = `Update data.json at ${new Date().toISOString()}`;

        if (currentFile) {
            // Update existing file
            await octokit.repos.createOrUpdateFileContents({
                owner: GITHUB_OWNER,
                repo: GITHUB_REPO,
                path: DATA_FILE_PATH,
                message,
                content,
                sha: currentFile.data.sha
            });
        } else {
            // Create new file
            await octokit.repos.createOrUpdateFileContents({
                owner: GITHUB_OWNER,
                repo: GITHUB_REPO,
                path: DATA_FILE_PATH,
                message,
                content
            });
        }
        console.log(`[${new Date().toISOString()}] Updated data.json in GitHub`);
    } catch (error) {
        console.error(`[${new Date().toISOString()}] Error updating data.json: ${error.message}`);
    }
}

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

    // Load initial data from GitHub
    try {
        const data = await getGitHubFile();
        Object.assign(webhookStats, data.webhookStats || webhookStats);
        console.log(`[${new Date().toISOString()}] Loaded webhook stats from GitHub`);
    } catch (error) {
        console.error(`[${new Date().toISOString()}] Failed to load initial data: ${error.message}`);
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

// Handle Discord message commands
client.on('messageCreate', async message => {
    if (message.author.bot) return;
    if (!message.content.startsWith(PREFIX)) return;

    const args = message.content.slice(PREFIX.length).trim().split(/ +/);
    const commandName = args.shift().toLowerCase();

    // Built-in warn command
    if (commandName === 'warn') {
        if (!message.member.permissions.has('MODERATE_MEMBERS')) {
            return message.reply('You do not have permission to use this command.');
        }

        const user = message.mentions.users.first();
        const reason = args.join(' ') || 'No reason provided';
        if (!user) {
            return message.reply('Please mention a user to warn.');
        }

        try {
            const data = await getGitHubFile();
            data.warnings = data.warnings || [];
            data.warnings.push({
                userId: user.id,
                username: user.tag,
                reason,
                timestamp: new Date().toISOString()
            });
            await updateGitHubFile(data);
            message.reply(`Warned ${user.tag} for: ${reason}`);
        } catch (error) {
            console.error(`[${new Date().toISOString()}] Error saving warning: ${error.message}`);
            message.reply('Failed to save warning.');
        }
        return;
    }

    const command = client.commands.get(commandName);
    if (!command) return;

    try {
        await command.execute(message, args);
    } catch (error) {
        console.error(`[${new Date().toISOString()}] Error executing command ${commandName}: ${error.message}`);
        message.reply('There was an error executing that command.');
    }
});

// Handle webhook POST requests
app.post('/webhook', async (req, res) => {
    const { Key, Executor, ExecutorLevel, GameName, UniverseId } = req.body;

    // Validate incoming data
    if (!Key || !Executor || !ExecutorLevel || !GameName || !UniverseId) {
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
            const label = labelMap[channelId] || 'unknown_game';
            webhookStats[label].failed++;
            await updateGitHubFile({ webhookStats, warnings: (await getGitHubFile()).warnings });
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
            const label = labelMap[channelId] || 'unknown_game';
            webhookStats[label].failed++;
            await updateGitHubFile({ webhookStats, warnings: (await getGitHubFile()).warnings });
            return res.status(500).json({ error: 'No webhooks available' });
        }

        const randomWebhook = webhooks[Math.floor(Math.random() * webhooks.length)];
        const webhookClient = new WebhookClient({ id: randomWebhook.id, token: randomWebhook.token });

        // Create embed
        const embed = new EmbedBuilder()
            .setTitle('H4xScripts')
            .setDescription(
                `**Game**: [${GameName}](https://www.roblox.com/games/${UniverseId})\n` +
                `**Key**: \`${Key}\`\n` +
                `**Executor**: \`${Executor}\`\n` +
                `**Executor Level**: \`${ExecutorLevel}\``
            )
            .setColor(0xffa500)
            .setFooter({ text: new Date().toISOString().slice(0, 19).replace('T', ' ') });

        // Send embed via random webhook
        await webhookClient.send({ embeds: [embed] });
        console.log(`[${new Date().toISOString()}] Embed sent to channel ${channelId} via webhook ${randomWebhook.id}`);

        // Update webhook stats
        const label = labelMap[channelId] || 'unknown_game';
        webhookStats[label].sent++;
        await updateGitHubFile({ webhookStats, warnings: (await getGitHubFile()).warnings });

        res.status(200).json({
            message: 'Webhook processed successfully',
            sent_to: channelId,
            webhook_id: randomWebhook.id
        });
    } catch (error) {
        console.error(`[${new Date().toISOString()}] Error sending to channel: ${error.message}`);
        const label = labelMap[channelId] || 'unknown_game';
        webhookStats[label].failed++;
        await updateGitHubFile({ webhookStats, warnings: (await getGitHubFile()).warnings });
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
