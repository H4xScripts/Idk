const fs = require('fs').promises; // Use promises for async file operations
const path = require('path');
const { PermissionsBitField, EmbedBuilder } = require('discord.js');

const banDataPath = path.join(__dirname, '..', 'Data', 'BanData.json');

async function loadBanData() {
  try {
    const data = await fs.readFile(banDataPath, 'utf8');
    return JSON.parse(data);
  } catch {
    return {};
  }
}

async function saveBanData(data) {
  try {
    await fs.writeFile(banDataPath, JSON.stringify(data, null, 2));
  } catch (error) {
    console.error(`[${new Date().toISOString()}] Error saving ban data: ${error.message}`);
  }
}

module.exports = {
  name: 'ban',
  description: 'Ban a user and save ban reason',
  async execute(message, args) {
    // Early validation to allow quick command deletion
    if (!message.member.permissions.has(PermissionsBitField.Flags.BanMembers)) {
      return message.reply('You do not have permission to ban members.');
    }

    if (args.length === 0) {
      return message.reply('Usage: !ban <user mention or ID> [reason]');
    }

    let user;
    try {
      user = message.mentions.users.first() || await message.client.users.fetch(args[0]);
    } catch {
      return message.reply('Invalid user ID or user not found.');
    }

    const member = message.guild.members.cache.get(user.id);
    if (!member) {
      return message.reply('User is not in this server.');
    }

    if (!member.bannable) {
      return message.reply('I cannot ban this user.');
    }

    const reason = args.slice(message.mentions.users.size > 0 ? 1 : 1).join(' ') || 'No reason provided';

    try {
      // Delete command message immediately after validation
      await message.delete();

      // Create embeds first to prioritize sending
      const embedDM = new EmbedBuilder()
        .setTitle('You have been banned')
        .setDescription(`**User:** ${user.tag}\n**Staff:** ${message.author.tag}\n**Reason:** ${reason}`)
        .setColor(0xff0000)
        .setFooter({ text: 'discord.gg/H4xScripts' });

      const embedChannel = new EmbedBuilder()
        .setTitle('User Banned')
        .setDescription(`**User:** ${user.tag}\n**Staff:** ${message.author.tag}\n**Reason:** ${reason}`)
        .setColor(0xff0000)
        .setFooter({ text: new Date().toLocaleString() });

      // Send DM to banned user (non-blocking, ignore errors)
      await user.send({ embeds: [embedDM] }).catch(() => {});

      // Perform the ban
      await member.ban({ reason });

      // Send channel embed
      await message.channel.send({ embeds: [embedChannel] });

      // Save ban data last (async to avoid blocking)
      const banData = await loadBanData();
      if (!Array.isArray(banData[user.id])) {
        banData[user.id] = [];
      }
      banData[user.id].push({
        staff: message.author.tag,
        reason,
        date: new Date().toLocaleString(),
      });
      await saveBanData(banData);
    } catch (error) {
      console.error(`[${new Date().toISOString()}] Ban error: ${error.message}`);
      // Since message is deleted, send error to channel or log it
      await message.channel.send('Failed to ban the user.').catch(() => {});
    }
  },
};
