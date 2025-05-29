const fs = require('fs');
const path = require('path');
const { EmbedBuilder } = require('discord.js');

const warnDataPath = path.join(__dirname, '..', 'Data', 'WarnData.json');
const rolesPath = path.join(__dirname, '..', 'Data', 'Roles.json');

function loadWarnings() {
  try {
    const data = fs.readFileSync(warnDataPath, 'utf8');
    return JSON.parse(data);
  } catch {
    return {};
  }
}

function saveWarnings(warnings) {
  fs.writeFileSync(warnDataPath, JSON.stringify(warnings, null, 2));
}

function loadRoles() {
  try {
    const data = fs.readFileSync(rolesPath, 'utf8');
    return JSON.parse(data);
  } catch {
    return {};
  }
}

function hasPermission(message, roleData) {
  const botOwners = roleData.BotOwner || [];
  if (botOwners.includes(message.author.id)) return true;
  const allAllowedRoles = [
    ...(roleData.Owner || []),
    ...(roleData.Admins || []),
    ...(roleData.Staff || []),
    ...(roleData.TrialStaff || [])
  ];
  return message.member.roles.cache.some(role => allAllowedRoles.includes(role.id));
}

module.exports = {
  name: 'warn',
  description: 'Warn a user by mention or user ID',
  async execute(message, args) {
    const roleData = loadRoles();

    if (!hasPermission(message, roleData)) {
      await message.reply('You do not have permission to warn members.');
      try { await message.delete(); } catch {}
      return;
    }

    if (!args.length) {
      await message.reply('Please mention a user or provide their user ID.');
      try { await message.delete(); } catch {}
      return;
    }

    let user = null;
    if (message.mentions.users.size > 0) {
      user = message.mentions.users.first();
    } else {
      try {
        user = await message.client.users.fetch(args[0]);
      } catch {
        await message.reply('Invalid user ID or user not found.');
        try { await message.delete(); } catch {}
        return;
      }
    }

    const reason = args.slice(message.mentions.users.size > 0 ? 1 : 1).join(' ') || 'None';

    const warnings = loadWarnings();

    if (!warnings[user.id]) {
      warnings[user.id] = {
        username: user.tag,
        serverName: message.guild ? message.guild.name : 'DM',
        warnings: []
      };
    } else {
      warnings[user.id].username = user.tag;
      warnings[user.id].serverName = message.guild ? message.guild.name : 'DM';
    }

    warnings[user.id].warnings.push({
      staff: message.author.tag,
      reason,
      timestamp: new Date().toLocaleString()
    });

    saveWarnings(warnings);

    const totalWarnings = warnings[user.id].warnings.length;

    const embed = new EmbedBuilder()
      .setTitle('You have been warned')
      .setDescription(`**User:** ${user.tag}\n**Staff:** ${message.author.tag}\n**Reason:** ${reason}`)
      .setColor(0xff0000)
      .setFooter({ text: `Total warnings: ${totalWarnings} • ${new Date().toLocaleString()}` });

    await user.send({ embeds: [embed] }).catch(() => {});
    await message.channel.send({ content: `${user}`, embeds: [embed] });
    try { await message.delete(); } catch {}
  }
};
