const express = require('express');
const { Client, IntentsBitField, WebhookClient, EmbedBuilder, Collection } = require('discord.js');
const bodyParser = require('body-parser');
const fs = require('fs');
const path = require('path');

const app = express();
const port = process.env.PORT || 3000;
const botToken = process.env.Bot_Token;

if (!botToken) {
    process.exit(1);
}

const client = new Client({
    intents: [
        IntentsBitField.Flags.Guilds,
        IntentsBitField.Flags.GuildMessages,
        IntentsBitField.Flags.MessageContent
    ]
});

const UNIVERSE_TO_CHANNEL = {
    "6161049307": "1377728605207007362",
    "7436755782": "1377720529603264673",
    "6022141304": "1377728540841083020",
    "7332711118": "1377728632868442263",
    "7468338447": "1377728512630194266",
    "7546582051": "1377728571308511384",
    "default": "1377728912142110862",
    "error": "1377748972055036026",
    "total": "1377750061479497849"
};

const channelWebhooks = new Map();
const PREFIX = '!';
client.commands = new Collection();
let totalDataCount = 0;
let lastTotalMessage = null;

app.use(bodyParser.json());

const commandsPath = path.join(__dirname, 'Cmds');
const commandFiles = fs.readdirSync(commandsPath).filter(file => file.endsWith('.js'));

for (const file of commandFiles) {
    const filePath = path.join(commandsPath, file);
    try {
        const command = require(filePath);
        if ('name' in command && 'execute' in command) {
            client.commands.set(command.name, command);
        }
    } catch {}
}

client.once('ready', async () => {
    try {
        for (const [universeId, channelId] of Object.entries(UNIVERSE_TO_CHANNEL)) {
            try {
                const channel = await client.channels.fetch(channelId);
                if (!channel) continue;
                await ensureWebhooks(channel, channelId);
            } catch {}
        }
        setInterval(updateTotalEmbed, 10000);
    } catch {}
});

async function ensureWebhooks(channel, channelId) {
    try {
        const webhooks = await channel.fetchWebhooks();
        const h4xWebhooks = webhooks.filter(wh => wh.name === 'H4xScript');
        const webhooksToCreate = 5 - h4xWebhooks.size;
        if (webhooksToCreate > 0) {
            for (let i = 0; i < webhooksToCreate; i++) {
                await channel.createWebhook({
                    name: 'H4xScript',
                    avatar: 'https://cdn.discordapp.com/avatars/1362841147424374895/4b77da63ba23d49b169b6a7f9717d527.png'
                });
            }
        }
        const webhookIds = (await channel.fetchWebhooks()).filter(wh => wh.name === 'H4xScript').map(wh => ({ id: wh.id, token: wh.token }));
        channelWebhooks.set(channelId, webhookIds);
    } catch {}
}

async function updateTotalEmbed() {
    try {
        const channel = await client.channels.fetch(UNIVERSE_TO_CHANNEL["total"]);
        if (!channel) return;

        const description = `Total Webhook Data Received: ${totalDataCount}`;
        const embed = new EmbedBuilder()
            .setTitle('H4xScripts Total Data')
            .setDescription(description)
            .setColor(0xffa500)
            .setFooter({ text: new Date().toISOString().slice(0, 19).replace('T', ' ') });

        if (lastTotalMessage) {
            try {
                if (description.length <= 2000) {
                    await lastTotalMessage.edit({ embeds: [embed] });
                } else {
                    const remaining = description.slice(2000);
                    await lastTotalMessage.edit({
                        embeds: [new EmbedBuilder()
                            .setTitle('H4xScripts Total Data')
                            .setDescription(description.slice(0, 2000))
                            .setColor(0xffa500)
                            .setFooter({ text: new Date().toISOString().slice(0, 19).replace('T', ' ') })]
                    });
                    lastTotalMessage = await channel.send({
                        embeds: [new EmbedBuilder()
                            .setTitle('H4xScripts Total Data (Continued)')
                            .setDescription(remaining)
                            .setColor(0xffa500)
                            .setFooter({ text: new Date().toISOString().slice(0, 19).replace('T', ' ') })]
                    });
                }
            } catch {
                lastTotalMessage = await channel.send({ embeds: [embed] });
            }
        } else {
            lastTotalMessage = await channel.send({ embeds: [embed] });
        }
    } catch {}
}

client.on('messageCreate', message => {
    if (message.author.bot) return;
    if (!message.content.startsWith(PREFIX)) return;

    const args = message.content.slice(PREFIX.length).trim().split(/ +/);
    const commandName = args.shift().toLowerCase();

    const command = client.commands.get(commandName);
    if (!command) return;

    try {
        command.execute(message, args);
    } catch {
        message.reply('There was an error executing that command.');
    }
});

app.post('/webhook', async (req, res) => {
    const { Key, Executor, ExecutorLevel, GameName, UniverseId } = req.body;

    if (!Key || !Executor || !ExecutorLevel || !GameName || !UniverseId) {
        try {
            const errorChannel = await client.channels.fetch(UNIVERSE_TO_CHANNEL["error"]);
            if (errorChannel) {
                await errorChannel.send({
                    embeds: [new EmbedBuilder()
                        .setTitle('Webhook Error')
                        .setDescription('Invalid webhook data: Missing required fields')
                        .setColor(0xff0000)
                        .setFooter({ text: new Date().toISOString().slice(0, 19).replace('T', ' ') })]
                });
            }
        } catch {}
        return res.status(400).json({ error: 'Invalid webhook data: Missing required fields' });
    }

    try {
        const channelId = UNIVERSE_TO_CHANNEL[UniverseId] || UNIVERSE_TO_CHANNEL["default"];
        const channel = await client.channels.fetch(channelId);
        if (!channel) {
            try {
                const errorChannel = await client.channels.fetch(UNIVERSE_TO_CHANNEL["error"]);
                if (errorChannel) {
                    await errorChannel.send({
                        embeds: [new EmbedBuilder()
                            .setTitle('Webhook Error')
                            .setDescription(`Channel not found: ${channelId}`)
                            .setColor(0xff0000)
                            .setFooter({ text: new Date().toISOString().slice(0, 19).replace('T', ' ') })]
                    });
                }
            } catch {}
            return res.status(500).json({ error: 'Channel not found' });
        }

        if (!channelWebhooks.has(channelId)) {
            await ensureWebhooks(channel, channelId);
        }

        const webhooks = channelWebhooks.get(channelId);
        if (!webhooks || webhooks.length === 0) {
            try {
                const errorChannel = await client.channels.fetch(UNIVERSE_TO_CHANNEL["error"]);
                if (errorChannel) {
                    await errorChannel.send({
                        embeds: [new EmbedBuilder()
                            .setTitle('Webhook Error')
                            .setDescription(`No webhooks available for channel: ${channelId}`)
                            .setColor(0xff0000)
                            .setFooter({ text: new Date().toISOString().slice(0, 19).replace('T', ' ') })]
                    });
                }
            } catch {}
            return res.status(500).json({ error: 'No webhooks available' });
        }

        const randomWebhook = webhooks[Math.floor(Math.random() * webhooks.length)];
        const webhookClient = new WebhookClient({ id: randomWebhook.id, token: randomWebhook.token });

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

        await webhookClient.send({ embeds: [embed] });
        totalDataCount++;
        res.status(200).json({
            message: 'Webhook processed successfully',
            sent_to: channelId,
            webhook_id: randomWebhook.id
        });
    } catch (error) {
        try {
            const errorChannel = await client.channels.fetch(UNIVERSE_TO_CHANNEL["error"]);
            if (errorChannel) {
                await errorChannel.send({
                    embeds: [new EmbedBuilder()
                        .setTitle('Webhook Error')
                        .setDescription(`Failed to send webhook: ${error.message}`)
                        .setColor(0xff0000)
                        .setFooter({ text: new Date().toISOString().slice(0, 19).replace('T', ' ') })]
                });
            }
        } catch {}
        res.status(500).json({
            error: 'Failed to send webhook',
            details: error.message
        });
    }
});

app.listen(port, async () => {
    try {
        await client.login(botToken);
    } catch {
        process.exit(1);
    }
});
