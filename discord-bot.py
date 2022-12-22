'''
                            Discord bot for sending messages to Cod 1 Server 

                            ****           MADE BY FLASH!           ****

'''




import discord
import os
from discord.ext import commands
from discord import app_commands


Prefix = "<TYPE_YOUR_PREFIX_HERE>" # for example '!', '$', etc..

Host = "<TYPE_YOUR_SERVER_IP_ADDRESS>" # Server ip e.g 123.123.123.123 etc

Port = "<TYPE_YOUR_SERVER_PORTS>" # Server port e.g 28960, 28961, etc

Rcon = "<TYPE_YOUR_SERVER_RCON_PASSWORD>" # Rcon pass for the specified server

bot_name = "~Message-sender-bot" # Your bot name doesn't matter what name you give. The name you give the bot in discord developer dashboard.

Server_name = "<YOUR_SERVER_NAME>" # your server name.

path = "" # Location of the file where the Command.py file is saved. Like e.g /data/myserver/Command.py

TOKEN = "<YOUR_BOT_TOKEN>" # Your bot token...



intents = discord.Intents.all()

bot = commands.Bot(help_command=Prefix, intents=intents, case_insensitive = True)

@bot.event 
async def on_ready(): # When the bot is ready
    print("Bot is active\n{}".format(bot.user))
    try:
        synced = await bot.tree.sync()
        print(f"Synced {len(synced)} commands.")
    except Exception as e:
        print(e)

bot.remove_command("help")

@bot.command()
async def help(ctx):
    embed = discord.Embed(title = f"Command list for {bot_name}", description = f"Use {Prefix}help command to see the full list of commands from {bot_name}", color=0xFFFF00)
    embed.add_field(name = "Commands", value = f"`{Prefix}help` Shows this Message\n{Prefix}say <message>\ne.g {Prefix}say Hi.")
    embed.set_footer(text = f"Made by FlasH :D\nThe Prefix of the bot is {Prefix}")
    await ctx.channel.send(embed = embed)

# You can change the role to anything you want I defaultly selected Admin.

@bot.command()
async def say(ctx, *, args):
    role = discord.utils.get(ctx.guild.roles, name="Admin")
    if role in ctx.author.roles:
            os.system(f'python2 {path} {Host} {Port} {Rcon} "set command talk {ctx.author.name}: {args}"')
    else:
        await ctx.channel.send("`You can't use the command you dont have at least Admin Permission...`")



@bot.tree.command(name="say")
@app_commands.describe(message = f"Your message to {Server_name} Server.")
async def say_to_server(ctx: discord.Interaction, message: str):
    try:
            os.system(f'python2 /data/myserver/commandsender.py {Host} {Port} {Rcon} "set command talk {ctx.user.name}: {message}"')
            await ctx.response.send_message(f"`Message sent to server.`\nYour message is\n`{ctx.user.name}:{message}`", ephemeral=True)
    except:
            await ctx.response.send_message(f"`Something went Wrong!.`", ephemeral = True)


bot.run(TOKEN)
