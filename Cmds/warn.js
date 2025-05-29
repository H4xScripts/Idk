const fs = require('fs').promises;
const path = require('path');
const { EmbedBuilder } = require('discord.js');

const warnDataPath = '/opt/render/data/WarnData.json';
const rolesPath = '/opt/render/data/Roles.json';

async function loadWarnings() {
  try {
    const data = await fs.readFile(warnDataPath, 'utf8');
    return JSON.parse(data);
  } catch (error) {
    console.error(`[${new Date().toISOString()}] Error loading warn data: ${error.message}`);
    return {};
  }
}

async function saveWarnings(warnings) {
  try {
    await fs.writeFile(warnDataPath, JSON.stringify(warnings, null, 2));
  } catch (error) {
    console.error(`[${new Date().toISOString()}] Error saving warn data: ${error.message}`);
  }
}

async function loadRoles() {
  try {
    const data = await fs.readFile(rolesPath, 'utf8');
    return JSON.parse(data);
  } catch (error) {
    console.error(`[${new Date().toISOString()}] Error loading roles data: ${error.message}`);
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
    ...(roleData.TrialStaff || []),
  ];
  return message.member.roles.cache.some(role => allAllowedRoles.includes(role.id));
}

module.exports = {
  name: 'warn',
  description: 'Warn a user by mention or user ID',
  async execute(message, args) {
    // Early validation
    const roleData = await loadRoles();
    if (!hasPermission(message, roleData)) {
      return message.reply('You do not have permission to warn members.');
    }

    if (!args.length) {
      return message.reply('Please mention a user or provide their user ID.');
    }

    let user;
    try {
      user = message.mentions.users.first() || (await message.client.users.fetch(args[0]));
    } catch (error) {
      console.error(`[${new Date().toISOString()}] Error fetching user: ${error.message}`);
      return message.reply('Invalid user ID or user not found.');
    }

    const reason = args.slice(message.mentions.users.size > 0 ? 1 : 1).join(' ') || 'None';

    // Delete command message after validation
    await message.delete().catch(error => {
      console.error(`[${new Date().toISOString()}] Error deleting command message: ${error.message}`);
    });

    try {
      // Load warnings
      const warnings = await loadWarnings();

      // Initialize or update user warn data
      if (!warnings[user.id]) {
        warnings[user.id] = {
          username: user.tag,
          serverName: message.guild ? message.guild.name : 'DM',
          warnings: [],
        };
      } else {
        warnings[user.id].username = user.tag;
        warnings[user.id].serverName = message.guild ? message.guild.name : 'DM';
      }

      warnings[user.id].warnings.push({
        staff: message.author.tag,
        reason,
        timestamp: new Date().toLocaleString(),
      });

      const totalWarnings = warnings[user.id].warnings.length;

      // Create embed
      const embed = new EmbedBuilder()
        .setTitle('You have been warned')
        .setDescription(`**User:** ${user.tag}\n**Staff:** ${message.author.tag}\n**Reason:** ${reason}`)
        .setColor(0xff0000)
        .setFooter({ text: `Total warnings: ${totalWarnings} • ${new Date().toLocaleString()}` });

      // Send DM and channel message first
      await user.send({ embeds: [embed] }).catch(() => {});
      await message.channel.send({ content: `${user}`, embeds: [embed] });

      // Save warnings last
      await saveWarnings(warnings);
    } catch (error) {
      console.error(`[${new Date().toISOString()}] Warn error: ${error.message}`);
      await message.channel.send('Failed to warn the user.').catch(() => {});
    }
  },
};
