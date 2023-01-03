#!/bin/bash

# ------------------------------------------------------------------ 
# Requirements:
# ------------------------------------------------------------------
# go 

SECONDS=0

# COLORS
red='\033[0;31m'
blue='\033[0;34m'
green='\033[0;32m'
yellow='\033[0;33m'
purple='\033[0;35m'
reset='\033[0m'

function banner(){
echo -e  "    ____      ____     _____            _       __                _           "
echo -e  "   /  _/___  / __/___ / ___/___  ____  | |     / /___ ___________(_)___  _____"
echo -e  "   / // __ \/ /_/ __ \\__ \/ _ \/ ___/  | | /| / / __ \`/ ___/ ___/ / __ \/ ___/"
echo -e  " _/ // / / / __/ /_/ /__/ /  __/ /__   | |/ |/ / /_/ / /  / /  / / /_/ / /    "
echo -e  "/___/_/ /_/_/  \____/____/\___/\___/   |__/|__/\__,_/_/  /_/  /_/\____/_/     "
echo -e  "                                                                              "
echo -e  "  github.com/InfoSecWarrior                                 by @ArmourInfosec "
echo -e  "\n"

}

function INFO_PRINT(){

   echo -e ${blue} [" "INFO"  "] ${reset}
}

function WARNING_PRINT(){

  echo -e ${yellow} [WARNING] ${reset}
}

function ERROR_PRINT(){

    echo -e ${red} [ ERROR ] ${reset}
}

function COMMAND_PRINT(){

    echo -e ${green} [COMMAND] ${reset}
}

function NOTIFY_PRINT(){

    echo -e ${purple} [NOTIFY ] ${reset}
}

banner

GO_INSTALL=true

# Check go install or Not
which go &>/dev/null || GO_INSTALL=false

if [ "${GO_INSTALL}" = true ]; then

        echo -e "$(INFO_PRINT) Good! Go installed! "

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
        all_gotools["tlsx"]="go install -v github.com/projectdiscovery/tlsx/cmd/tlsx@latest"
        all_gotools["katana"]="go install -v github.com/projectdiscovery/katana/cmd/katana@latest"

        # OWASP Amass
        all_gotools["Amass"]="go install -v github.com/OWASP/Amass/v3/...@master"
        
        #Tom Hudson Tools
        all_gotools["gf"]="go install -v github.com/tomnomnom/gf@latest"
        all_gotools["qsreplace"]="go install -v github.com/tomnomnom/qsreplace@latest"
        all_gotools["waybackurls"]="go install -v github.com/tomnomnom/waybackurls@latest"
        all_gotools["anew"]="go install -v github.com/tomnomnom/anew@latest"
        all_gotools["unfurl"]="go install -v github.com/tomnomnom/unfurl@latest"
        all_gotools["inscope"]="go install -v github.com/tomnomnom/hacks/inscope@latest"
        all_gotools["httprobe"]="go install -v github.com/tomnomnom/httprobe@latest"
        all_gotools["assetfinder"]="go get -u github.com/tomnomnom/assetfinder"
        
        # Gwendal Le Coguic  Tools
        all_gotools["github-subdomains"]="go install -v github.com/gwen001/github-subdomains@latest"
        all_gotools["github-endpoints"]="go install -v github.com/gwen001/github-endpoints@latest"

        # Josué Encinar Tools
        all_gotools["analyticsrelationships"]="go install -v github.com/Josue87/analyticsrelationships@latest"
        all_gotools["gotator"]="go install -v github.com/Josue87/gotator@latest"
        all_gotools["roboxtractor"]="go install -v github.com/Josue87/roboxtractor@latest"

        all_gotools["puredns"]="go install -v github.com/d3mondev/puredns/v2@latest"
        all_gotools["gauplus"]="go install github.com/bp0lr/gauplus@latest"
        all_gotools["dnstake"]="go install -v github.com/pwnesia/dnstake/cmd/dnstake@latest"
        all_gotools["hakrawler"]="go install -v github.com/hakluke/hakrawler@latest"
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
        all_gotools["rush"]="go install -v github.com/shenwei356/rush@latest"
        all_gotools["enumerepo"]="go install -v github.com/trickest/enumerepo@latest"
        all_gotools["Web-Cache-Vulnerability-Scanner"]="go install -v github.com/Hackmanit/Web-Cache-Vulnerability-Scanner@latest"

        all_gotools["cent"]="go install -v github.com/xm1k3/cent@latest"

        echo -e "$(INFO_PRINT) Installing Go tools (${#all_gotools[@]})"

        declare -A not_install_gotools

        i=0

        for gotool in "${!all_gotools[@]}"; do
            i=$((i + 1))
            ${all_gotools[$gotool]}
            exit_status=$?
            if [ $exit_status -eq 0 ]
            then
                echo -e "$(INFO_PRINT) $gotool installed (${i}/${#all_gotools[@]})"
            else
                echo -e "$(ERROR_PRINT) Unable to install $gotool, try manually (${i}/${#all_gotools[@]})"
                not_install_gotools["$gotool"]="$gotool"
            fi
        done

        if [ ${#not_install_gotools[@]} -ne 0 ]; then

            echo -e "$(ERROR_PRINT) Unable to install following go tools (${#not_install_gotools[@]}), try manually."

            i=0
            for not_install_gotool in "${!not_install_gotools[@]}"; do
                i=$((i + 1))
                echo -e "$(ERROR_PRINT) $not_install_gotool (${i}/${#not_install_gotools[@]})"
            done
        fi

        #copy all go binary into /usr/local/bin
        echo -e "$(INFO_PRINT) Copy all Go Tools into ${yellow}/usr/local/bin"
        sudo cp $HOME/go/bin/* /usr/local/bin

    else
        echo -e  "$(ERROR_PRINT) Go is not install."
        echo -e  "$(INFO_PRINT) Use the following command to install go."
        # One line command to install go
        # wget https://go.dev/dl/go1.19.3.linux-amd64.tar.gz && tar -C /usr/local/ -xzf go1.19.3.linux-amd64.tar.gz && cd /usr/local/ && ls -lha && echo "export PATH=\$PATH:/usr/local/go/bin:\$HOME/go/bin" >> ~/.bashrc && echo "export GOROOT=/usr/local/go" >> ~/.bashrc && echo "export PATH=\$PATH:/usr/local/go/bin:\$HOME/go/bin" >> /home/*/.bashrc && echo "export GOROOT=/usr/local/go" >> /home/*/.bashrc && source ~/.bashrc && source /home/*/.bashrc && go version
        echo -e  "wget https://go.dev/dl/go1.19.3.linux-amd64.tar.gz && tar -C /usr/local/ -xzf go1.19.3.linux-amd64.tar.gz && cd /usr/local/ && ls -lha && echo \"export PATH=\$PATH:/usr/local/go/bin:\$HOME/go/bin\" >> ~/.bashrc && echo \"export GOROOT=/usr/local/go\" >> ~/.bashrc && echo \"export PATH=\$PATH:/usr/local/go/bin:\$HOME/go/bin\" >> /home/*/.bashrc && echo \"export GOROOT=/usr/local/go\" >> /home/*/.bashrc && source ~/.bashrc && source /home/*/.bashrc && go version"
        echo -e "$(INFO_PRINT) If it fails for any reason try to install manually"


fi

duration=$SECONDS
echo -e "$(INFO_PRINT) Elapsed Time: $(($duration / 60)) minutes and $(($duration % 60)) seconds."
