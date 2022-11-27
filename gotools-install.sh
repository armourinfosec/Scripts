#!/bin/bash

# One line command to install go
# wget https://go.dev/dl/go1.19.3.linux-amd64.tar.gz && tar -C /usr/local/ -xzf go1.19.3.linux-amd64.tar.gz && cd /usr/local/ && ls -lha && echo "export PATH=\$PATH:/usr/local/go/bin:\$HOME/go/bin" >> ~/.bashrc && echo "export GOROOT=/usr/local/go" >> ~/.bashrc && echo "export PATH=\$PATH:/usr/local/go/bin:\$HOME/go/bin" >> /home/*/.bashrc && echo "export GOROOT=/usr/local/go" >> /home/*/.bashrc && source ~/.bashrc && source /home/*/.bashrc && go version

# COLORS
red='\033[0;31m'
blue='\033[0;34m'
green='\033[0;32m'
yellow='\033[0;33m'
reset='\033[0m'

declare -A all_gotools
# Project Discovery Tools
all_gotools["nuclei"]="go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest"
all_gotools["subfinder"]="go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest"
all_gotools["httpx"]="go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest"
all_gotools["naabu"]="go install -v github.com/projectdiscovery/naabu/v2/cmd/naabu@latest"
all_gotools["notify"]="go install -v github.com/projectdiscovery/notify/cmd/notify@latest"
all_gotools["dnsx"]="go install -v github.com/projectdiscovery/dnsx/cmd/dnsx@latest"
all_gotools["interactsh-client"]="go install -v github.com/projectdiscovery/interactsh/cmd/interactsh-client@latest"
all_gotools["mapcidr"]="go install -v github.com/projectdiscovery/mapcidr/cmd/mapcidr@latest"
all_gotools["tlsx"]="go install github.com/projectdiscovery/tlsx/cmd/tlsx@latest"
all_gotools["katana"]="go install github.com/projectdiscovery/katana/cmd/katana@latest"

# OWASP Amass
all_gotools["Amass"]="go install -v github.com/OWASP/Amass/v3/...@master"

#Tom Hudson Tools
all_gotools["gf"]="go install -v github.com/tomnomnom/gf@latest"
all_gotools["qsreplace"]="go install -v github.com/tomnomnom/qsreplace@latest"
all_gotools["waybackurls"]="go install -v github.com/tomnomnom/waybackurls@latest"
all_gotools["anew"]="go install -v github.com/tomnomnom/anew@latest"
all_gotools["unfurl"]="go install -v github.com/tomnomnom/unfurl@latest"
all_gotools["inscope"]="go install github.com/tomnomnom/hacks/inscope@latest"
all_gotools["httprobe"]="go install github.com/tomnomnom/httprobe@latest"

# Gwendal Le Coguic  Tools
all_gotools["github-subdomains"]="go install -v github.com/gwen001/github-subdomains@latest"
all_gotools["github-endpoints"]="go install -v github.com/gwen001/github-endpoints@latest"

# Josué Encinar Tools
all_gotools["analyticsrelationships"]="go install -v github.com/Josue87/analyticsrelationships@latest"
all_gotools["gotator"]="go install -v github.com/Josue87/gotator@latest"
all_gotools["roboxtractor"]="go install -v github.com/Josue87/roboxtractor@latest"

all_gotools["puredns"]="go install -v github.com/d3mondev/puredns/v2@latest"
all_gotools["dnstake"]="go install -v github.com/pwnesia/dnstake/cmd/dnstake@latest"
all_gotools["hakrawler"]="go install github.com/hakluke/hakrawler@latest"
all_gotools["ffuf"]="go install -v github.com/ffuf/ffuf@latest"
all_gotools["gau"]="go install -v github.com/lc/gau/v2/cmd/gau@latest"
all_gotools["subjs"]="go install -v github.com/lc/subjs@latest"
all_gotools["Gxss"]="go install -v github.com/KathanP19/Gxss@latest"
all_gotools["gospider"]="go install -v github.com/jaeles-project/gospider@latest"
all_gotools["gowitness"]="go install -v github.com/sensepost/gowitness@latest"
all_gotools["crlfuzz"]="go install -v github.com/dwisiswant0/crlfuzz/cmd/crlfuzz@latest"
all_gotools["dalfox"]="go install -v github.com/hahwul/dalfox/v2@latest"
all_gotools["ipcdn"]="go install -v github.com/six2dez/ipcdn@latest"
all_gotools["gitdorks_go"]="go install -v github.com/damit5/gitdorks_go@latest"
all_gotools["smap"]="go install -v github.com/s0md3v/smap/cmd/smap@latest"
all_gotools["dsieve"]="go install -v github.com/trickest/dsieve@master"
all_gotools["rush"]="go install github.com/shenwei356/rush@latest"
all_gotools["enumerepo"]="go install github.com/trickest/enumerepo@latest"
all_gotools["Web-Cache-Vulnerability-Scanner"]="go install -v github.com/Hackmanit/Web-Cache-Vulnerability-Scanner@latest"

echo -e "${blue} Installing Go tools (${#all_gotools[@]})${reset}"
i=0
for gotool in "${!all_gotools[@]}"; do
    i=$((i + 1))
    eval ${all_gotools[$gotool]} $DEBUG_STD
    exit_status=$?
    if [ $exit_status -eq 0 ]
    then
        echo -e "${yellow} $gotool installed (${i}/${#all_gotools[@]})${reset}"
    else
        echo -e "${red} Unable to install $gotool, try manually (${i}/${#all_gotools[@]})${reset}"
    fi
done

#copy all go binary into /usr/local/bin
echo -e "${blue} Copy all Go Tools into ${yellow}/usr/local/bin${reset}"
cp $HOME/go/bin/* /usr/local/bin
echo -e "${green} Done!! ${reset}"
