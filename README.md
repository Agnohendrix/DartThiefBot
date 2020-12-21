# DartThiefBot
A Flutter-Desktop telegram bot which warns you when your PC:computer: gets disconnected from ACLine:zap::battery:.

You can use it when AFK in a public place(like a library:book:) to get warnings on your smartphone :iphone:.

## Configuration
Download the latest [release](https://github.com/Agnohendrix/DartThiefBot/releases/) and create a myBotInfos.txt file with infos described in **Telegram configuration**

## Telegram configuration

### Create a new Telegram Bot
Follow the [Telegram guide](https://core.telegram.org/bots#3-how-do-i-create-a-bot) and write to [BotFather](https://t.me/botfather).

[BotFather](https://t.me/botfather) will create a new bot and send you your **bot_token**
### Get your Telegram chat_id
Write to [Chat_ID_Echo_Bot](https://t.me/chatid_echo_bot) to get your **chat_id**
### Insert bot_token and chat_id into this new bot
Create a new TXT file named myBotInfos.txt in the root folder (you can use [myBotInfos.example.txt](https://github.com/Agnohendrix/DartThiefBot/blob/main/myBotInfos.example.txt) as template file.
Write into myBotInfos.txt your bot_token and your chat_id in the following format:

`bot_token:1234567890:asdfasdfasdfasdfasdf`

`chat_id:123456789`

(Both on a new line and without spaces)

### Done
Run prova_ffi.exe and you will see a white screen which tells you if your PC is connected to ACLine and you will receive a message on your smartphone :iphone:.

Try plugging and unplugging your ACLine to ensure event message receiving.

## Just for development
### Clone this repository (or [download it](https://github.com/Agnohendrix/DartThiefBot/archive/main.zip))
`git clone https://github.com/Agnohendrix/DartThiefBot`
### Open as [Flutter](https://flutter.dev/) Project and add [desktop support](https://flutter.dev/desktop)

# Suggests are welcome, just file an [Issue](https://github.com/Agnohendrix/DartThiefBot/issues)
