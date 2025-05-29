const { PermissionsBitField, EmbedBuilder } = require('discord.js');

module.exports = {
  name: 'kick',
  description: 'Kick a user from the server',
  async execute(message, args) {
    // Early validation
    if (!message.member.permissions.has(PermissionsBitField.Flags.KickMembers)) {
      return message.reply('You do not have permission to kick members.');
    }

    if (args.length === 0) {
      return message.reply('Usage: !kick <user mention or ID> [reason]');
    }

    let user;
    try {
      user = message.mentions.users.first() || (await message.client.users.fetch(args[0]));
    } catch (error) {
      console.error(`[${new Date().toISOString()}] Error fetching user: ${error.message}`);
      return message.reply('Invalid user ID or user not found.');
    }

    const member = message.guild.members.cache.get(user.id);
    if (!member) {
      return message.reply('User is not in this server.');
    }

   

    if (!member.kickable) {
      return message.reply('I cannot kick this user.');
    }

    const reason = args.slice(message.mentions.users.size > 0 ? 1 : 1).join(' ') || 'No reason provided';

    // Delete command message after validation
    await message.delete().catch(error => {
      console.error(`[${new Date().toISOString()}] Error deleting command message: ${error.message}`);
    });

    try {
      // Create embeds
      const embedDM = new EmbedBuilder()
        .setTitle('You have been kicked')
        .setDescription(`**Server:** ${message.guild.name}\n**Staff:** ${message.author.tag}\n**Reason:** ${reason}`)
        .setColor(0xffa500)
        .setFooter({ text: 'discord.gg/H4xScripts' });

      const embedChannel = new EmbedBuilder()
        .setTitle('User Kicked')
        .setDescription(`**User:** ${user.tag}\n**Staff:** ${message.author.tag}\n**Reason:** ${reason}`)
        .setColor(0xffa500)
        .setFooter({ text: new Date().toLocaleString() });

      // Send DM (non-blocking, ignore errors)
      await user.send({ embeds: [embedDM] }).catch(() => {});

      // Perform kick
      await member.kick(reason);

      // Send channel embed
      await message.channel.send({ embeds: [embedChannel] });
    } catch (error) {
      console.error(`[${new Date().toISOString()}] Kick error: ${error.message}`);
      await message.channel.send('Failed to kick the user.').catch(() => {});
    }
  },
};
