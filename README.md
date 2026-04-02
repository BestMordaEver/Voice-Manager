# Voice Manager — Temporary Voice Channels for Discord

[![Version](https://img.shields.io/badge/version-4.13.1-blue)](https://github.com/BestMordaEver/Voice-Manager) [![Discord](https://img.shields.io/discord/669676999211483144?label=support&logo=discord&color=5865F2)](https://discord.gg/tqj6jvT) [![License](https://img.shields.io/github/license/BestMordaEver/Voice-Manager)](https://github.com/BestMordaEver/Voice-Manager/blob/master/LICENSE) [![Stars](https://img.shields.io/github/stars/BestMordaEver/Voice-Manager?style=social)](https://github.com/BestMordaEver/Voice-Manager) [![luvit](https://img.shields.io/badge/luvit-Discordia-2C2D72?logo=lua&logoColor=white)](https://github.com/SinisterRectus/Discordia)

[Add to your server](https://discord.com/oauth2/authorize?client_id=601347755046076427) &nbsp;|&nbsp; [Setup Guide](https://github.com/BestMordaEver/Voice-Manager/wiki/Setup-Guide) &nbsp;|&nbsp; [Support Server](https://discord.gg/tqj6jvT)

Voice Manager is a Discord bot that automatically creates and removes temporary voice channels. When a user joins a designated lobby channel, Voice Manager instantly creates a new voice channel for that session. When everyone leaves, the channel is removed — keeping your server tidy without any manual moderation.

[See Voice Manager in action](https://i.imgur.com/xNKVC2B.mp4)

## How It Works

When a user joins a lobby channel, Voice Manager automatically:

- Creates a temporary voice channel for that session
- Optionally creates a private text chat visible only to members in that voice channel
- Removes the temporary channel and logs the transcript once everyone leaves

## Features

- **Auto voice channel creation** — new channels appear instantly when a lobby is joined
- **Private companion text chats** — linked to the matching voice channel, hidden from everyone else
- **Custom channel names** — use text, usernames, or the active game being played
- **Flexible channel placement** — control exactly where new channels appear in your server
- **User moderation controls** — channel owners can manage and customize their own room
- **Transcript logging** — save text chat history before cleanup
- **Matchmaking lobbies** — route users into existing channels instead of always creating new ones

## Who It's For

- **Gaming communities** - spin up game rooms on demand, named after the active game  
- **Social servers** - let members create ad-hoc hangout channels without cluttering the list  
- **Study groups** - private voice + text rooms that disappear when the session ends  
- **Events & moderation** - temporary rooms with transcripts for accountability  