const fs = require('fs');
const path = require('path');
const { EmbedBuilder } = require('discord.js');

const banDataPath = path.join(__dirname, '..', 'Data', 'BanData.json');

function loadBanData() {
  try {
    return JSON.parse(fs.readFileSync(banDataPath, 'utf8'));
  } catch {
    return {};
  }
}

module.exports = {
  name: 'baninfo',
  description: 'Shows ban history of a user',
  async execute(message, args) {
    if (args.length === 0) {
      return message.reply('Usage: !baninfo <user mention or ID>');
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

    const banData = loadBanData();
    const userBans = banData[user.id];

    if (!userBans || userBans.length === 0) {
      return message.reply('No ban history found for this user.');
    }

    let description = '';

    userBans.forEach((ban, i) => {
      const index = i + 1;
      description += `${index}. ban\n`;
      description += `**Staff:** ${ban.staff}\n`;
      description += `**Reason:** ${ban.reason}\n`;
      description += `**Date:** ${ban.date}\n\n`;
    });

    description += `**Total bans:** ${userBans.length}`;

    const embed = new EmbedBuilder()
      .setTitle(`Ban Info for ${user.tag}`)
      .setDescription(description)
      .setColor(0xff0000)
      .setFooter({ text: `Requested by ${message.author.tag}` });

    message.channel.send({ embeds: [embed] });
  }
};
