const fs = require('fs').promises; // Use promises for async file operations
const path = require('path');

const warnDataPath = path.join(__dirname, '..', 'Data', 'WarnData.json');
const rolesPath = path.join(__dirname, '..', 'Data', 'Roles.json');

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
  ];
  return message.member.roles.cache.some(role => allAllowedRoles.includes(role.id));
}

module.exports = {
  name: 'clearwarns',
  description: 'Remove warnings by number or all',
  async execute(message, args) {
    // Early validation to allow quick command deletion
    const roleData = await loadRoles();
    if (!hasPermission(message, roleData)) {
      return message.reply('You do not have permission to remove warnings.');
    }

    if (args.length < 2) {
      return message.reply('Usage: !clearwarns <user mention or ID> <id/all>');
    }

    let user;
    try {
      user = message.mentions.users.first() || (await message.client.users.fetch(args[0]));
    } catch (error) {
      console.error(`[${new Date().toISOString()}] Error fetching user: ${error.message}`);
      return message.reply('Invalid user ID or user not found.');
    }

    // Load warnings to check if user has any
    const warnings = await loadWarnings();
    const userWarns = warnings[user.id];
    if (!userWarns || !userWarns.warnings?.length) {
      return message.reply('This user has no warnings.');
    }

    // Delete command message after validation
    await message.delete().catch(error => {
      console.error(`[${new Date().toISOString()}] Error deleting command message: ${error.message}`);
    });

    try {
      let responseMessage;
      if (args[1].toLowerCase() === 'all') {
        const count = userWarns.warnings.length;
        userWarns.warnings = [];
        responseMessage = `Removed all (${count}) warnings from ${user.tag}.`;
      } else {
        const indices = args
          .slice(message.mentions.users.size > 0 ? 1 : 1)
          .map(i => parseInt(i, 10) - 1)
          .filter(i => !isNaN(i) && i >= 0 && i < userWarns.warnings.length);

        if (indices.length === 0) {
          return message.channel.send(
            `Please provide valid warning numbers between 1 and ${userWarns.warnings.length}.`
          );
        }

        indices.sort((a, b) => b - a); // Sort descending for safe splicing
        for (const i of indices) {
          userWarns.warnings.splice(i, 1);
        }
        const removedNumbers = indices.map(i => i + 1).sort((a, b) => a - b);
        responseMessage = `Removed warning no. ${removedNumbers.join(', ')} from ${user.tag}.`;
      }

      // Send confirmation message first
      await message.channel.send(responseMessage);

      // Save warnings last
      await saveWarnings(warnings);
    } catch (error) {
      console.error(`[${new Date().toISOString()}] Clearwarns error: ${error.message}`);
      await message.channel.send('Failed to clear warnings.').catch(() => {});
    }
  },
};
