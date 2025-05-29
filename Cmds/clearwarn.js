const fs = require('fs');
const path = require('path');

const warnDataPath = path.join(__dirname, '..', 'Data', 'WarnData.json');
const rolesPath = path.join(__dirname, '..', 'Data', 'Roles.json');

function loadWarnings() {
  try {
    return JSON.parse(fs.readFileSync(warnDataPath, 'utf8'));
  } catch {
    return {};
  }
}

function saveWarnings(warnings) {
  fs.writeFileSync(warnDataPath, JSON.stringify(warnings, null, 2));
}

function loadRoles() {
  try {
    return JSON.parse(fs.readFileSync(rolesPath, 'utf8'));
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
    ...(roleData.Staff || [])
  ];
  return message.member.roles.cache.some(role => allAllowedRoles.includes(role.id));
}

module.exports = {
  name: 'clearwarns',
  description: 'Remove warnings by number or all',
  async execute(message, args) {
    const roleData = loadRoles();
    if (!hasPermission(message, roleData)) return message.reply('You do not have permission to remove warnings.');
    if (args.length < 2) return message.reply('Usage: !clearwanrs user/id id/all');

    let user;
    if (message.mentions.users.size > 0) user = message.mentions.users.first();
    else {
      try {
        user = await message.client.users.fetch(args[0]);
      } catch {
        return message.reply('Invalid user ID or user not found.');
      }
    }

    const warnings = loadWarnings();
    const userWarns = warnings[user.id];
    if (!userWarns || !userWarns.warnings.length) return message.reply('This user has no warnings.');

    if (args[1].toLowerCase() === 'all') {
      const count = userWarns.warnings.length;
      userWarns.warnings = [];
      saveWarnings(warnings);
      return message.channel.send(`Removed all (${count}) warnings from ${user.tag}.`);
    }

    const indices = args.slice(message.mentions.users.size > 0 ? 1 : 1)
      .map(i => parseInt(i, 10) - 1)
      .filter(i => !isNaN(i) && i >= 0 && i < userWarns.warnings.length);

    if (indices.length === 0) return message.reply(`Please provide valid warning numbers between 1 and ${userWarns.warnings.length}.`);

    indices.sort((a, b) => b - a);
    for (const i of indices) userWarns.warnings.splice(i, 1);
    saveWarnings(warnings);

    const removedNumbers = indices.map(i => i + 1).sort((a,b) => a - b);
    message.channel.send(`Removed warning no. ${removedNumbers.join(', ')} from ${user.tag}.`);
  }
};
