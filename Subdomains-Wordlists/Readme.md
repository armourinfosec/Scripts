<h1 align="center">Offensive Subdomains Wordlists Creator</h1>


## Description
This bash script is designed to gather subdomain data from various reputable sources and merge them together to create multiple wordlists, each organized by different subdomain levels, and make a master subdomains wordlist merging all different levels subdomains wordlists. This makes very effective wordlists that can be further used in the subdomain brute-forcing process by security researchers and bug hunters.

## Dependencies

[Duplicut](https://github.com/nil0x42/duplicut) (Required)

[Notify](https://github.com/projectdiscovery/notify) (Optional)

## Installation
```
wget https://raw.githubusercontent.com/InfoSecWarrior/Offensive-Pentesting-Scripts/main/Subdomains-Wordlists/oswc.sh
```
```
chmod +x oswc.sh
```

## Usage
```
./oswc.sh
```
Saving results in specific directory, by default it saves results in present working directory
```
./oswc.sh --output /opt/wordlists
```

## Sample output
```
first_level_subdomains_wordlist.txt
-----------------------------------
sub1
sub2
sub3

second_level_subdomains_wordlist.txt
-----------------------------------
sub1.sub
sub2.sub
sub3.sub

Until ninth_and_above_level_subdomains_wordlist.txt...
```