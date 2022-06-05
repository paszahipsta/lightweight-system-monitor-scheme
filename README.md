# Scheme Lightweight HTTP System Monitor

## Introduction

Lightweight HTTP system monitor written in Scheme for Raspberry Pi, provides basic system information about all crucial components of the device such as RAM memory usage, processor usage, temperature, operating system or uptime. Also allows the user to switch off or reboot the device remotely. The code is written in Chicken Scheme, which allows us to compile code to the binary executable.

## Requirements

Programs is invoking shell commands to retrieve information about system, therefore it requires:
- procinfo installed (sudo apt-get update && sudo apt install procinfo)
- uptime installed (sudo apt install uptime)
- sensors installed (sudo apt install lm-sensors)

Note that the binary is compiled for Raspberry Pi architecture (arm64). 
Also all performed tests were also on the Raspberry Pi with Ubutnu Server 20.04 installed.

## Building a program

To build the Lightweight HTTP Monitor from source code firstly clone the git repository and then follow the given steps:

1. Install Chicken Scheme on your Raspberry Pi by running 
```
sudo apt install libchicken11 libchicken-dev chicken-bin
```
2. Go to the directory of cloned repository and install eggs dependencies
```
cd lightweight-system-monitor-scheme/
chicken-install -sudo -from-list ./install.txt
```
3. To compile the source code and run program immediately you can use prepared makefile
```
make run
```
or compile with chicken tool
```
csc monitor.sch
```
4. Done! The monitor binary should appear in current directory!

## Use instructions

To access the HTTP monitor, check the IP of your Raspberry Pi and try reaching it through browser
```
http://your_raspberry_ip
```