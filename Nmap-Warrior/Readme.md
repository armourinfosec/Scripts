
<h1 align="center">Nmap Warrior Offensive Pentesting Scripts</h1>
 
    
## Features
- Easy to use
- Fast scanning.
- Live Hosts Discovering.
- Multi Option For Scaning.
- Service Version Detection.
- Notify After complete Scaning.



## Installation ⚙️

```
git clone https://github.com/InfoSecWarrior/Offensive-Pentesting-Scripts/
```

```
cd Offensive-Pentesting-Scripts &&  cd Nmap-Warrior
```

```
chmod 777 nmap-warrior.sh 
 ```
 
 ```
 ./nmap-warrior.sh -h
```

```		
infoces㉿warrior)-[~/Desktop/Tools/Offensive-Pentesting-Scripts/Nmap-Warrior]
└─$ ./nmap-warrior.sh -h
    ____      ____     _____            _       __                _           
   /  _/___  / __/___ / ___/___  ____  | |     / /___ ___________(_)___  _____
   / // __ \/ /_/ __ \__ \/ _ \/ ___/  | | /| / / __ `/ ___/ ___/ / __ \/ ___/
 _/ // / / / __/ /_/ /__/ /  __/ /__   | |/ |/ / /_/ / /  / /  / / /_/ / /    
/___/_/ /_/_/  \____/____/\___/\___/   |__/|__/\__,_/_/  /_/  /_/\____/_/     
                                                                              
  github.com/InfoSecWarrior                                 by @ArmourInfosec 

```


## How-it-works 🤔

Target list pass use -l Swich
```
./nmap-warrior.sh -l ip_list.txt 
```
Define Selected Target -u Swich
```
./nmap-warrior.sh -u terget.com 
```
Scan result output -o swich (Its Optional ) Output save Automaticly in crunt folder
```
./nmap-warrior.sh -l ip_list.txt  -o scanresult.txt
```
## MODE 💀

Display Live Domain or IP Address only -s Swich
```
./nmap-warrior.sh -l ip_list.txt -s
```

Custom Port Snam -p Swich 
```
./nmap-warrior.sh -l ip_list.txt -p
```

Service Version Detection (Requires root privileges)
```
./nmap-warrior.sh -l ip_list.txt -v
```
## Feedback

If you have any feedback, please reach out to us at sopurt@InfoSecWarrior.com