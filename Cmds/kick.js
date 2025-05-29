const { PermissionsBitField, EmbedBuilder } = require('discord.js');

module.exports = {
  name: 'kick',
  description: 'Kick a user from the server',
  async execute(message, args) {
    if (!message.member.permissions.has(PermissionsBitField.Flags.KickMembers)) {
      return message.reply('You do not have permission to kick members.');
    }

    if (args.length === 0) {
      return message.reply('Usage: !kick <user mention or ID> [reason]');
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

    const member = message.guild.members.cache.get(user.id);
    if (!member) {
      return message.reply('User is not in this server.');
    }

    if (!member.kickable) {
      return message.reply('I cannot kick this user.');
    }

    const reason = args.slice(message.mentions.users.size > 0 ? 1 : 1).join(' ') || 'No reason provided';

    try {
      await user.send({
        embeds: [
          new EmbedBuilder()
            .setTitle('You have been kicked')
            .setDescription(`**Server:** ${message.guild.name}\n**Staff:** ${message.author.tag}\n**Reason:** ${reason}`)
            .setColor(0xffa500)
            .setFooter({ text: 'discord.gg/H4xScripts' })
        ]
      }).catch(() => {});

      await member.kick(reason);

      const embed = new EmbedBuilder()
        .setTitle('User Kicked')
        .setDescription(`**User:** ${user.tag}\n**Staff:** ${message.author.tag}\n**Reason:** ${reason}`)
        .setColor(0xffa500)
        .setFooter({ text: new Date().toLocaleString() });

      message.channel.send({ embeds: [embed] });
    } catch {
      message.reply('Failed to kick the user.');
    }
  }
};
