#!/bin/bash

BK="\e[7m"
RT="\e[0m"
GR="\e[32m"
YW="\e[93m"

# Ensure the script is run as root
if (( $EUID != 0 )); then
    echo -e "MAKE SURE YOU'RE ROOT BEFORE RUNNING THE SCRIPT"
    exit
fi

echo "Select the architecture for installation:"
echo "1) amd64"
echo "2) arm64"
read -p "Enter the number (1 or 2): " arch_choice

case $arch_choice in
    1)
        arch="amd64"
        ;;
    2)
        arch="arm64"
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

folders(){
    mkdir -p ~/tools
    mkdir -p ~/tools/.tmp
    mkdir -p ~/.gf
    mkdir -p ~/wordlists
}

install_go() {
    goversion="go1.22.4"
    url="https://go.dev/dl/$goversion.linux-$arch.tar.gz"
    
    if command -v go &> /dev/null; then
        echo "Go is already installed."
        return
    fi

    wget $url -q

    if [ $? -ne 0 ]; then
        echo "Failed to download Go tarball. Exiting."
        exit 1
    fi

    sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf $goversion.linux-$arch.tar.gz

    if [ $? -ne 0 ]; then
        echo "Failed to extract Go tarball. Exiting."
        exit 1
    fi

    export PATH=$PATH:/usr/local/go/bin
    echo "export PATH=\$PATH:/usr/local/go/bin" >> ~/.bashrc

    if command -v go &> /dev/null; then
        echo -e "\nGo installed successfully."
    else
        echo -e "\nThere was a problem installing Go. Try installing it manually."
    fi

    rm -rf $goversion.linux-$arch.tar.gz
}


dependencies(){
    mv .github/payloads/patterns/*.json ~/.gf/ 2> /dev/null && cd
    echo -e "${BK}INSTALLING ALL DEPENDENCIES${RT}"
    sudo apt-get update > /dev/null 2>&1
    sudo apt-get full-upgrade -y > /dev/null 2>&1
    sudo apt-get install apt-transport-https bsdmainutils build-essential snapd cmake curl dnsutils gcc git jq libdata-hexdump-perl libffi-dev libpcap-dev libssl-dev libxml2-dev libxml2-utils libxslt1-dev lynx medusa nmap procps pv python3 python3-dev python3-pip wget zip zlib1g-dev libpcap-dev screen -y > /dev/null 2>&1
    sudo snap install chromium > /dev/null 2>&1
    install_go
    echo -e "${GR}SUCCESS${RT}\n"
}

githubd(){
    echo -e "${BK}DOWNLOADING AND INSTALLING ALL TOOLS FROM GITHUB${RT}\n"

    echo -e "\n- Installing Sublist3r"
    git clone https://github.com/aboul3la/Sublist3r.git -q ~/tools/Sublist3r
    cd ~/tools/Sublist3r && sudo pip3 install -r requirements.txt > /dev/null 2>&1
    git clone https://github.com/1ndianl33t/Gf-Patterns -q && mv Gf-Patterns/*.json ~/.gf/ && rm -rf Gf-Patterns/ > /dev/null 2>&1
    if [ -s ~/tools/Sublist3r/sublister.py ]; then
        echo -e "${GR}SUCCESS${RT}"
    else
        echo -e "${YW}FAILED${RT}"
    fi
    
    echo -e "\n- Installing Bhedak"
    cd && wget -O bhedak https://raw.githubusercontent.com/R0X4R/bhedak/main/bhedak.py -q && chmod +x bhedak && mv bhedak /usr/bin/ > /dev/null 2>&1
    which bhedak &> /dev/null && 
    if command -v bhedak &> /dev/null; then
        echo -e "${GR}SUCCESS${RT}"
    else
        echo -e "${YW}FAILED${RT}"
    fi
    
    echo -e "\n- Installing Agnee"
    sudo pip3 install git+https://github.com/R0X4R/Search-Engines-Scraper.git > /dev/null 2>&1 && sudo pip3 install agnee > /dev/null 2>&1
    if command -v agnee &> /dev/null; then
        echo -e "${GR}SUCCESS${RT}"
    else
        echo -e "${YW}FAILED${RT}"
    fi
    
    echo -e "\n- Installing uro"
    cd && pip3 install uro > /dev/null 2>&1
    if command -v uro &> /dev/null; then
        echo -e "${GR}SUCCESS${RT}"
    else
        echo -e "${YW}FAILED${RT}"
    fi
    
    echo -e "\n- Installing anew"
    go install github.com/tomnomnom/anew@latest > /dev/null 2>&1
    if [ -f ~/go/bin/anew ]; then
        echo -e "${GR}SUCCESS${RT}"
    else
        echo -e "${YW}FAILED${RT}"
    fi
    
    echo -e "\n- Installing naabu"
    go install -v go install -v github.com/projectdiscovery/naabu/v2/cmd/naabu@latest > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo -e "${YW}Failed to install naabu${RT}"
        exit 1
    fi

    if [ -f ~/go/bin/naabu ]; then
        echo -e "${GR}SUCCESS${RT}"
    else
        echo -e "${YW}FAILED${RT}"
    fi

    
    echo -e "\n- Installing gobuster"
    go install github.com/OJ/gobuster/v3@latest > /dev/null 2>&1
    if [ -f ~/go/bin/gobuster ]; then
        echo -e "${GR}SUCCESS${RT}"
    else
        echo -e "${YW}FAILED${RT}"
    fi

    echo -e "\n- Installing gf"
    go install github.com/tomnomnom/gf@latest > /dev/null 2>&1
    if [ -f ~/go/bin/anew ]; then
        echo -e "${GR}SUCCESS${RT}"
    else
        echo -e "${YW}FAILED${RT}"
    fi

    echo -e "\n- Installing gospider"
    cd && git clone https://github.com/jaeles-project/gospider ~/tools/.tmp/gospider -q
    cd ~/tools/.tmp/gospider 2> /dev/null
    go install > /dev/null 2>&1
    if [ -f ~/go/bin/gospider ]; then
        echo -e "${GR}SUCCESS${RT}"
    else
        echo -e "${YW}FAILED${RT}"
    fi

    echo -e "\n- Installing aquatone"
    if [ "$arch" == "amd64" ]; then
        aquatone_url="https://github.com/michenriksen/aquatone/releases/download/v1.7.0/aquatone_linux_amd64_1.7.0.zip"
    else
        aquatone_url="https://github.com/michenriksen/aquatone/releases/download/v1.7.0/aquatone_linux_arm64_1.7.0.zip"
    fi
    
    wget -q $aquatone_url -O aquatone.zip
    if [ $? -ne 0 ]; then
        echo -e "${YW}Failed to download Aquatone${RT}"
        exit 1
    fi
    
    unzip -o aquatone.zip -d aquatone > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo -e "${YW}Failed to unzip Aquatone${RT}"
        exit 1
    fi
    
    mv aquatone/aquatone /usr/bin/ > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo -e "${YW}Failed to move Aquatone to /usr/bin${RT}"
        exit 1
    fi
    
    rm -rf aquatone aquatone.zip LICENSE.txt README.md
    
    if command -v aquatone &> /dev/null; then
        echo -e "${GR}SUCCESS${RT}"
    else
        echo -e "${YW}FAILED${RT}"
    fi


    echo -e "\n- Installing assetfinder"
    go install github.com/tomnomnom/assetfinder@latest > /dev/null 2>&1
    if [ -f ~/go/bin/assetfinder ]; then
        echo -e "${GR}SUCCESS${RT}"
    else
        echo -e "${YW}FAILED${RT}"
    fi

    echo -e "\n- Installing crobat"
    go install github.com/cgboal/sonarsearch/cmd/crobat@latest > /dev/null 2>&1
    if [ -f ~/go/bin/crobat ]; then
        echo -e "${GR}SUCCESS${RT}"
    else
        echo -e "${YW}FAILED${RT}"
    fi

    echo -e "\n- Installing gau"
    go install github.com/lc/gau/v2/cmd/gau@latest > /dev/null 2>&1
    if [ -f ~/go/bin/gau ]; then
        echo -e "${GR}SUCCESS${RT}"
    else
        echo -e "${YW}FAILED${RT}"
    fi

    echo -e "\n- Installing waybackurls"
    go install github.com/tomnomnom/waybackurls@latest > /dev/null 2>&1
    if [ -f ~/go/bin/waybackurls ]; then
        echo -e "${GR}SUCCESS${RT}"
    else
        echo -e "${YW}FAILED${RT}"
    fi

    echo -e "\n- Installing kxss"
    go install github.com/Emoe/kxss@latest > /dev/null 2>&1
    if [ -f ~/go/bin/kxss ]; then
        echo -e "${GR}SUCCESS${RT}"
    else
        echo -e "${YW}FAILED${RT}"
    fi

    echo -e "\n- Installing qsreplace"
    go install github.com/tomnomnom/qsreplace@latest > /dev/null 2>&1
    if [ -f ~/go/bin/qsreplace ]; then
        echo -e "${GR}SUCCESS${RT}"
    else
        echo -e "${YW}FAILED${RT}"
    fi

    echo -e "\n- Installing ffuf"
    cd ~/tools/.tmp/ && git clone https://github.com/ffuf/ffuf -q
    cd ffuf && go install > /dev/null 2>&1
    if [ -f ~/go/bin/ffuf ]; then
        echo -e "${GR}SUCCESS${RT}"
    else
        echo -e "${YW}FAILED${RT}"
    fi

    echo -e "\n- Installing dnsx"
    go install -v github.com/projectdiscovery/dnsx/cmd/dnsx@latest > /dev/null 2>&1
    if [ -f ~/go/bin/dnsx ]; then
        echo -e "${GR}SUCCESS${RT}"
    else
        echo -e "${YW}FAILED${RT}"
    fi

    echo -e "\n- Installing notify"
    go install -v github.com/projectdiscovery/notify/cmd/notify@latest > /dev/null 2>&1
    if [ -f ~/go/bin/notify ]; then
        echo -e "${GR}SUCCESS${RT}"
    else
        echo -e "${YW}FAILED${RT}"
    fi

    echo -e "\n- Installing dalfox"
    go install github.com/hahwul/dalfox/v2@latest > /dev/null 2>&1
    if [ -f ~/go/bin/dalfox ]; then
        echo -e "${GR}SUCCESS${RT}"
    else
        echo -e "${YW}FAILED${RT}"
    fi

    echo -e "\n- Installing crlfuzz"
    cd ~/tools/.tmp/ && git clone https://github.com/dwisiswant0/crlfuzz -q
    cd crlfuzz/cmd/crlfuzz && go install > /dev/null 2>&1
    if [ -f ~/go/bin/crlfuzz ]; then
        echo -e "${GR}SUCCESS${RT}"
    else
        echo -e "${YW}FAILED${RT}"
    fi

    echo -e "\n- Installing nuclei"
    go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest > /dev/null 2>&1
    if [ -f ~/go/bin/nuclei ]; then
        echo -e "${GR}SUCCESS${RT}"
    else
        echo -e "${YW}FAILED${RT}"
    fi

    echo -e "\n- Installing subfinder"
    go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest > /dev/null 2>&1
    if [ -f ~/go/bin/subfinder ]; then
        echo -e "${GR}SUCCESS${RT}"
    else
        echo -e "${YW}FAILED${RT}"
    fi

    echo -e "\n- Installing httprobe"
    cd ~/tools/.tmp && git clone https://github.com/tomnomnom/httprobe.git -q
    cd httprobe && go install > /dev/null 2>&1
    if [ -f ~/go/bin/httprobe ]; then
        echo -e "${GR}SUCCESS${RT}"
    else
        echo -e "${YW}FAILED${RT}"
    fi

    echo -e "\n- Installing httpx"
    go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest > /dev/null 2>&1
    if [ -f ~/go/bin/httpx ]; then
        echo -e "${GR}SUCCESS${RT}"
    else
        echo -e "${YW}FAILED${RT}"
    fi

    echo -e "\n- Installing amass"
    go install -v github.com/owasp-amass/amass/v4/...@master > /dev/null 2>&1
    if [ -f ~/go/bin/amass ]; then
        echo -e "${GR}SUCCESS${RT}"
    else
        echo -e "${YW}FAILED${RT}"
    fi

    echo -e "\n- Installing gobuster"
    go install github.com/OJ/gobuster/v3@latest > /dev/null 2>&1
    if [ -f ~/go/bin/gobuster ]; then
        echo -e "${GR}SUCCESS${RT}"
    else
        echo -e "${YW}FAILED${RT}"
    fi
}

wordlistsd(){
    echo -e "\n${BK}DOWNLOADING ALL THE WORDLISTS${RT}"
    cd ~/wordlists/
    
    echo -e "\n- Downloading subdomains wordlists"
    wget -q https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/DNS/deepmagic.com-prefixes-top50000.txt -O subdomains.txt
    if [ -s subdomains.txt ]; then
        echo -e "${GR}SUCCESS${RT}"
    else
        echo -e "${YW}FAILED${RT}"
    fi
    
    echo -e "\n- Downloading resolvers wordlists"
    wget -q https://raw.githubusercontent.com/janmasarik/resolvers/master/resolvers.txt -O resolvers.txt
    if [ -s resolvers.txt ]; then
        echo -e "${GR}SUCCESS${RT}"
    else
        echo -e "${YW}FAILED${RT}"
    fi
    
    echo -e "\n- Downloading fuzz wordlists"
    wget -q https://raw.githubusercontent.com/Bo0oM/fuzz.txt/master/fuzz.txt -O fuzz.txt
    if [ -s fuzz.txt ]; then
        echo -e "${GR}SUCCESS${RT}"
    else
        echo -e "${YW}FAILED${RT}"
    fi
}

main(){
    folders
    dependencies
    githubd
    wordlistsd
    echo -e "\n${BK}FINISHING UP THINGS${RT}"
    rm -rf ~/tools/.tmp/ > /dev/null 2>&1
    sudo cp ~/go/bin/* /usr/bin/ > /dev/null 2>&1
    nuclei -update-templates > /dev/null 2>&1
    echo -e "\nPLEASE CONFIGURE NOTIFY API'S IN ${BK} ~/.config/notify/provider-config.yaml ${RT} FILE"
    echo -e "THANKS FOR INSTALLING ${BK}Project-Erum${RT}. HAPPY HUNTING :)\nPS: "
    garud -h 2> /dev/null
}

main