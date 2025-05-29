const { PermissionsBitField } = require('discord.js');

module.exports = {
  name: 'unban',
  description: 'Unban a user from the server',
  async execute(message, args) {
    if (!message.member.permissions.has(PermissionsBitField.Flags.BanMembers)) {
      return message.reply('You do not have permission to unban members.');
    }

    if (args.length === 0) {
      return message.reply('Usage: !unban <user ID>');
    }

    const userId = args[0];

    try {
      const bans = await message.guild.bans.fetch();
      if (!bans.has(userId)) {
        return message.reply('This user is not banned.');
      }

      await message.guild.members.unban(userId);
      message.channel.send(`Unbanned user with ID: ${userId}`);
    } catch {
      message.reply('Failed to unban the user. Make sure the ID is correct.');
    }
  }
};
