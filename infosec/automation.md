Hi there,

This is gonna be one of the favorite articles I've ever written. Automation, that's a pretty familiar word. Maybe you've heard people telling that they got some bounties with just using some simple automation. So in this article, I will be discussing about the bug bounty automation.


Photo by Ibrahim Boran on Unsplash
Requirements

A VPS server or a Raspberry Pi (I use Raspberry Pi as one can also use it for other purposes)
Knowledge of some programming language (of course, python preferred)
LINUX as its powerful
And CRON (crontab), the backbone
So starting with the backbone, the CRON. So if you don’t know about crontab, here’s a brief description:-

Cron is a command line utility, which schedules the tasks and run them automatically as specified.

The way you can access it in your linux machine is by using sudo crontab -e. If you’re running it for the first time, it will ask you the text editor of your choice. You could use anyone according to your needs.


Crontab on my raspberry pi
So I’ve selected nano and if you'll see my schedules jobs, you will find multiple things (I know you might be wondering CRYPTO MINING, but that's not the part of this article but still I will talk about this at the end.

So you could see that I've deployed many scripts from the ‘bots’ folder in user directory. You could specify multiple command to be run at a particular time. So let's start with the syntax of CRON

Crontab
So, if you’ll open crontab for first time, you’ll find the basic syntax, and PLEASE, DON’T REMOVE THE PART DISCUSSING ABOUT THE SYNTAX, IT WILL HELP YOU IN FUTURE, and I’ve dropped in below for your reference

# Edit this file to introduce tasks to be run by cron.
# 
# Each task to run has to be defined through a single line
# indicating with different fields when the task will be run
# and what command to run for the task
# 
# To define the time you can provide concrete values for
# minute (m), hour (h), day of month (dom), month (mon),
# and day of week (dow) or use '*' in these fields (for 'any').
# 
# Notice that tasks will be started based on the cron's system
# daemon's notion of time and timezones.
# 
# Output of the crontab jobs (including errors) is sent through
# email to the user the crontab file belongs to (unless redirected).
# 
# For example, you can run a backup of all your user accounts
# at 5 a.m every week with:
# 0 5 * * 1 tar -zcf /var/backups/home.tgz /home/
# 
# For more information see the manual pages of crontab(5) and cron(8)
# 
# m h  dom mon dow   command
So the basic syntax is

m h dom mon dow command
Where ‘m’ is minute

‘h’ is hour

‘dom’ is day of week

‘mon’ is month and

‘dow’ is day of week

So now let’s do some practicals:-

Run nuclei scan in /home/user/nuclei-scans/directory for target https://www.example.com with ‘-as’ (automatic scan flag) and output the results to ‘nuclei-scan.txt’ everyday at 12:00 AM

So, let’s do it step by step. First of all, you have to go to the directory specified, so the command would be cd /home/user/nuclei-scans/ . So now, once we’ve switched to directory, we need to build the command for nuclei. Assuming that nuclei binary is set to path (or in /usr/bin directory), the command will be nuclei -t https://www.example.com -as -o nuclei-scan.txt . Now once we’ve built two commands, lets combine them, so the final command will be:-

cd /home/user/nuclei-scans/ && nuclei -t https://www.example.com -as -o nuclei-scan.txt

So now, once we’ve build the command, let’s add it to crontab.

So first thing in crontab syntax is minute. So the minute here is ‘00' (12:00 AM) the next thing is hour, so since here it is 12:00 AM, we will convert it to 24-hour format, so it will become ‘00’. The next thing is dom, mon, and dow, so since we are running it everyday, it will be ‘*’ (asterisk, for wildcard). So finally, the line we would add to crontab would be:-

00 00 * * * cd /home/user/nuclei-scans/ && nuclei -t https://www.example.com -as -o nuclei-scan.txt

Adding this line to crontab would run nuclei scan automatically at 12 AM everyday

Channel to send message to
For this, simply head over to slack (sending message to email is easier but not that suitable for this task, as you could end up messing your inbox), create a workspace and channels for different tasks. You could use the guide here for setting up an app and how to use it to send messages to slack channels.

The python/bash script
So, you could use any script as per of your choice, but I use python for this, because it is powerful and easy (bash is also easy, but I feel more comfortable while scripting in python, so we’ll talk about python).

So assuming that you’ve a bit experience in python programming and you’ve created a slack webhook

You could use the following code for sending message to slack (sorry for using this poor method 😅)

import os
slack_webhook = "<slack_webhook_URL>"
def sendMsg(msg):
    if slack_send_msg == True:
        os.system("curl -X POST -H 'Content-type: application/json' --data '{\"text\":\"" + msg + "\"}' " + slack_webhook)
    else:
        print(msg)
So, I’ve deployed three bots, first is to look for new subdomains, next to check subdomain takeover and one to run nuclei.

So since I am on a metered connection, I scan only a few targets (5–7 domains)

You could see the algorithm in the file below:-


Algorithm for monitoring system
You could use this algorithm for any of the tool you use.

What if I don’t want to buy/rent a raspberry-pi/VPS server?
You could do the same with your laptop/PC. Just at the place of time, you could use @reboot , so it would run the scan every time your machine is rebooted/started. The example command below will run nuclei every time the laptop is rebooted:-

@reboot cd /home/user/nuclei-scans/ && nuclei -t https://www.example.com -as -o nuclei-scan.txt

Another reason for automation
Sometimes, the reason for automation could be to consume up your left over internet data, but in a productive manner (which is somehow my reason also). To use your left-over data for some fruitful work, you can use Honeygain. It is an online service, which helps you earn some money from your left-over internet data. You can share your leftover data with your mobile phone, PC or any other device you wish. If you will sign up using my referral link here, you will get an additional $5 credit. So go, and sign up now!

And the crypto mining (not related to this topic but for fun)
Since the task won’t be running all the time, we should utilize it for something. So, I do crypto mining. There are multiple coins available but the coin best suitable for raspberry-pi/VPS is Duino-Coin. You could explore its website and start mining (you won’t get rich by this mining, but it will give you some experience with crypto mining, which could be a good investment).

Important: Make sure you don’t mine with your machine you do your work on as it consumes a lot of processing power of your machine.

I hope that this article would help you setting up your monitoring machine. Feel free to clap for this article and follow me for more

Pro-tip: You could clap upto 50 times for an article

:)

