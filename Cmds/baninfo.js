const fs = require('fs').promises; // Use promises for async file operations
const path = require('path');
const { EmbedBuilder } = require('discord.js');

const banDataPath = path.join(__dirname, '..', 'Data', 'BanData.json');

async function loadBanData() {
  try {
    const data = await fs.readFile(banDataPath, 'utf8');
    return JSON.parse(data);
  } catch (error) {
    console.error(`[${new Date().toISOString()}] Error loading ban data: ${error.message}`);
    return {};
  }
}

module.exports = {
  name: 'baninfo',
  description: 'Shows ban history of a user',
  async execute(message, args) {
    // Early validation to allow quick command deletion
    if (args.length === 0) {
      return message.reply('Usage: !baninfo <user mention or ID>');
    }

    let user;
    try {
      user = message.mentions.users.first() || (await message.client.users.fetch(args[0]));
    } catch (error) {
      console.error(`[${new Date().toISOString()}] Error fetching user: ${error.message}`);
      return message.reply('Invalid user ID or user not found.');
    }

    // Delete command message after user validation
    await message.delete().catch(error => {
      console.error(`[${new Date().toISOString()}] Error deleting command message: ${error.message}`);
    });

    try {
      const banData = await loadBanData();
      const userBans = banData[user.id];

      if (!userBans || userBans.length === 0) {
        return message.channel.send('No ban history found for this user.');
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

      await message.channel.send({ embeds: [embed] });
    } catch (error) {
      console.error(`[${new Date().toISOString()}] Baninfo error: ${error.message}`);
      await message.channel.send('Failed to retrieve ban info.').catch(() => {});
    }
  },
};
