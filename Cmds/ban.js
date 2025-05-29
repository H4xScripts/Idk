const fs = require('fs');
const path = require('path');
const { PermissionsBitField, EmbedBuilder } = require('discord.js');

const banDataPath = path.join(__dirname, '..', 'Data', 'BanData.json');

function loadBanData() {
  try {
    return JSON.parse(fs.readFileSync(banDataPath, 'utf8'));
  } catch {
    return {};
  }
}

function saveBanData(data) {
  fs.writeFileSync(banDataPath, JSON.stringify(data, null, 2));
}

module.exports = {
  name: 'ban',
  description: 'Ban a user and save ban reason',
  async execute(message, args) {
    await message.delete();
    if (!message.member.permissions.has(PermissionsBitField.Flags.BanMembers)) {
      return message.reply('You do not have permission to ban members.');
    }

    if (args.length === 0) {
      return message.reply('Usage: !ban <user mention or ID> [reason]');
    }

    let user;
    if (message.mentions.users.size > 0) {
      user = message.mentions.users.first();
    } else {
      try {
        user = await message.client.users.fetch(args[0]);
      } catch {
        return message.reply('Invalid user ID or user not found.');
      }
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
      const embedDM = new EmbedBuilder()
        .setTitle('You have been banned')
        .setDescription(`**User :** ${user.tag}\n**Staff :** ${message.author.tag}\n**Reason: ** ${reason}`)
        .setColor(0xff0000)
        .setFooter({ text: 'discord.gg/H4xScripts' });

      await user.send({ embeds: [embedDM] }).catch(() => {}); // Ignore DM errors

      await member.ban({ reason });

      const banData = loadBanData();

      if (!Array.isArray(banData[user.id])) {
        banData[user.id] = [];
      }

      banData[user.id].push({
        staff: message.author.tag,
        reason: reason,
        date: new Date().toLocaleString()
      });

      saveBanData(banData);

      const embedChannel = new EmbedBuilder()
        .setTitle('User Banned')
        .setDescription(`**User:** ${user.tag}\n**Staff:** ${message.author.tag}\n**Reason:** ${reason}`)
        .setColor(0xff0000)
        .setFooter({ text: new Date().toLocaleString() });

      message.channel.send({ embeds: [embedChannel] });
    } catch {
      message.reply('Failed to ban the user.');
    }
  }
};
