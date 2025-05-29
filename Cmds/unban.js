const { PermissionsBitField } = require('discord.js');

module.exports = {
  name: 'unban',
  description: 'Unban a user from the server',
  async execute(message, args) {
    // Early validation
    if (!message.member.permissions.has(PermissionsBitField.Flags.BanMembers)) {
      return message.reply('You do not have permission to unban members.');
    }

    if (args.length === 0) {
      return message.reply('Usage: !unban <user ID>');
    }

    const userId = args[0];

    // Delete command message after validation
    await message.delete().catch(error => {
      console.error(`[${new Date().toISOString()}] Error deleting command message: ${error.message}`);
    });

    try {
      // Check if user is banned
      const bans = await message.guild.bans.fetch();
      if (!bans.has(userId)) {
        return message.channel.send('This user is not banned.');
      }

      // Unban user (works even if user is not in server)
      await message.guild.members.unban(userId);

      // Send confirmation
      await message.channel.send(`Unbanned user with ID: ${userId}`);
    } catch (error) {
      console.error(`[${new Date().toISOString()}] Unban error: ${error.message}`);
      await message.channel.send('Failed to unban the user. Make sure the ID is correct.').catch(() => {});
    }
  },
};
