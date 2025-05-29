const fs = require('fs');
const path = require('path');
const { EmbedBuilder } = require('discord.js');

const warnDataPath = path.join(__dirname, '..', 'Data', 'WarnData.json');

function loadWarnings() {
  try {
    const data = fs.readFileSync(warnDataPath, 'utf8');
    return JSON.parse(data);
  } catch {
    return {};
  }
}

module.exports = {
  name: 'warns',
  description: 'Check all warnings of a user by mention or user ID',
  async execute(message, args) {
    if (!args.length) return message.reply('Please mention a user or provide their user ID.');

    let user = null;
    if (message.mentions.users.size > 0) {
      user = message.mentions.users.first();
    } else {
      try {
        user = await message.client.users.fetch(args[0]);
      } catch {
        return message.reply('Invalid user ID or user not found.');
      }
    }

    const warnings = loadWarnings();

    if (!warnings[user.id]) {
      return message.reply(`${user.tag} has no warnings.`);
    }

    const userWarns = warnings[user.id];
    const embed = new EmbedBuilder()
      .setTitle(`Warnings for ${userWarns.username}`)
      .setDescription(`Server: ${userWarns.serverName}`)
      .setColor(0xffa500);

    let warnDescriptions = '';
    userWarns.warnings.forEach((w, i) => {
      warnDescriptions += `**${i + 1}.** Staff: ${w.staff}\nReason: ${w.reason}\nTime: ${w.timestamp}\n\n`;
    });

    embed.setDescription(warnDescriptions || 'No warnings found.');

    await message.channel.send({ embeds: [embed] });
  }
};
