#!/bin/bash

#=============================================== PARAMETERS =================================================

#EASYBASH_PARAM:EASYBASH_INSTALL_DIR:todo
export EASYBASH_INSTALL_DIR=$(dirname "$(realpath $0)")

#EASYBASH_PARAM:EASYBASH_SCRIPT_PATH:todo
export EASYBASH_SCRIPT_PATH="$EASYBASH_INSTALL_DIR""/easy.bash"

#EASYBASH_PARAM:EASYBASH_EXTRA_PATH:todo
export EASYBASH_EXTRA_PATH="$EASYBASH_INSTALL_DIR""/extra"

#EASYBASH_PARAM:EASYBASH_MAX_CPU_THREADS:cpu thread limiter for heavy tasks
export EASYBASH_MAX_CPU_THREADS="16"

#================================================= HELPER FUNCTIONS =========================================

function _easybash_check(){
    local PARAM_CHECK_COMMAND="$1"
    local PARAM_ERROR_MSG="$2"

    local CHECK_INSTALLATION=0
    if ! eval "$PARAM_CHECK_COMMAND" &> /dev/null; then
        echo -e "$PARAM_ERROR_MSG"
        local CHECK_INSTALLATION=1
    fi
    return $CHECK_INSTALLATION
}

function _print_header(){
    local PARAM_HEADER_PREFIX="$1"

    local PARSEDBASHRC=$(cat "$EASYBASH_SCRIPT_PATH" | grep "$PARAM_HEADER_PREFIX")
    local HELPSTRING=""
    while IFS= read -r line; do
        local COMMANDNAME=$(echo $line | cut -d':' -f2)
        local COMMANDDESCRIPTION=$(echo $line | cut -d':' -f3)
        local WHITESPACEFILLER="                                                   "
        local NEWHELPSTRING=$(printf '%.25s : %s' "$COMMANDNAME$WHITESPACEFILLER" "$COMMANDDESCRIPTION")
        local HELPSTRING="$HELPSTRING$NEWHELPSTRING\n"
    done <<< "$PARSEDBASHRC"
    printf "$HELPSTRING"
}

#EASYBASH_FUNC:help_bashrc:Prints help message for easy bashrc
function easybash_help(){
    echo "======================================================================="
    echo "============================== EASY BASH =============================="
    echo "======================================================================="
    echo -e "[*] Easy Bash Parameters:"
    _print_header "#EASYBASH""_PARAM"
    echo -e "\n[*] Easy Bash Functions:"
    _print_header "#EASYBASH""_FUNC"
    echo -e "\n[*] Easy Bash Aliases:"
    _print_header "#EASYBASH""_ALIAS"
}

#================================================= ALIASES ==================================================

#EASYBASH_ALIAS:py:Shorter version of python3
alias py='python3' 

#EASYBASH_ALIAS:fix-skype:Kills Skype background processes without terminating the program
alias fix-skype='kill -HUP `ps -eo "pid:1,args:1" | grep -E "\-\-type=renderer.*skypeforlinux" | cut -d" " -f1`'


#================================================= FUNCTIONS ================================================

#EASYBASH_FUNC:jekyll_server:Starts jekyll docker used for rendering github.io webpages
#EASYBASH_SRC:https://github.com/BretFisher/jekyll-serve
function jekyll_serve(){
    _easybash_check "which docker" "Please install docker with:\n\$ sudo apt install docker.io\n\$ sudo groupadd docker\n\$ sudo usermod -aG docker ${USER}"; [ $? -eq 0 ] || return 1
    docker run -p 4000:4000 -v $(pwd):/site bretfisher/jekyll-serve
}

#EASYBASH_FUNC:wipe_all_docker_data:todo
function wipe_all_docker_data(){
    _easybash_check "which docker" "Please install docker with:\n\$ sudo apt install docker.io\n\$ sudo groupadd docker\n\$ sudo usermod -aG docker ${USER}"; [ $? -eq 0 ] || return 1
    [ $? -eq 0 ] || return 1
}

#EASYBASH_FUNC:unrestrict_pdf:todo
function unrestrict_pdf(){
    _easybash_check "which qpdf" "Please install qpdf with:\n\$ sudo apt install qpdf"; [ $? -eq 0 ] || return 1
    qpdf --decrypt restricted-input.pdf unrestricted-output.pdf
}

#EASYBASH_FUNC:android_remote_control:Android screenshare to the PC. Enable USB debugging on android, then connect with a USB.
#EASYBASH_SRC:https://github.com/Genymobile/scrcpy
function android_remote_control(){
    _easybash_check "which scrcpy" "Please install scrcpy with:\n\$ sudo apt install scrcpy"; [ $? -eq 0 ] || return 1
    scrcpy
}

#EASYBASH_FUNC:no_network:Start $@ without an internet connection
function no_network(){
    _easybash_check "which firejail" "Please install firejail with:\n\$ sudo apt install firejail"; [ $? -eq 0 ] || return 1
    firejail --noprofile --net=none $@
}

#EASYBASH_FUNC:gitaddcommitpush:Adds all files in the current location, commits @1 and pushes to the origin
gitaddcommitpush(){ 
    _easybash_check "which git" "Please install git with:\n\$ sudo apt install git"; [ $? -eq 0 ] || return 1
    git add . &&
    git commit -m "$1" &&
    git push origin
}

#EASYBASH_FUNC:temp_chrome:Temporary google-chrome-browser. Can be reset with temp_chrome_reset
temp_chrome(){
    _easybash_check "google-chrome" "Please Google Chrome from from https://www.google.com/chrome/"
    local EASY_CHROME="$EASYBASH_EXTRA_PATH/temp_chrome"
    local EASY_CHROME_USERDATA="$EASY_CHROME/userdata"
    touch "$EASY_CHROME/DELETE_userdata_TO_RESET_TEMPORARY_CHROME"
    google-chrome --user-data-dir="$EASY_CHROME_USERDATA"
}

#EASYBASH_FUNC:temp_chrome_reset:Describes instructions for resetting temp_chrome profile
temp_chrome_reset(){
    EASY_CHROME="$EASYBASH_EXTRA_PATH/chrome"
    xdg-open "$EASY_CHROME"
}

#EASYBASH_FUNC:scan_text:Select an area on the screen to run OCR and get text output
function scan_text(){
    _easybash_check "which mogrify" "Please install imagemagick with:\n\$ sudo apt install imagemagick"; [ $? -eq 0 ] || return 1
    _easybash_check "which maim" "Please install maim with:\n\$ sudo apt install maim"; [ $? -eq 0 ] || return 1
    _easybash_check "which tesseract" "Please install tesseract-ocr with:\n\$ sudo add-apt-repository ppa:alex-p/tesseract-ocr-devel\n\$ sudo apt update\n\$ sudo apt install tesseract-ocr"; [ $? -eq 0 ] || return 1

    #select tesseract_lang in eng rus equ ;do break;done # Quick language menu, add more if you need other languages.
    SCR_IMG=$(mktemp --tmpdir scan_textXXXXXXXX.png)
    OCR_TXT="${SCR_IMG%.*}"
    trap "rm $SCR_IMG" EXIT
    trap "rm $OCR_TXT.txt" EXIT
    maim -s "$SCR_IMG" -m 1
    mogrify -modulate 100,0 -resize 400% "$SCR_IMG"  #should increase detection rate
    tesseract "$SCR_IMG" "$OCR_TXT" &> /dev/null
    cat "$OCR_TXT.txt"
    rm "$SCR_IMG"
    rm "$OCR_TXT.txt"
}


#EASYBASH_FUNC:scan_qrcode:Select an area on the screen to run zbarimg and get text output
function scan_qr(){
    _easybash_check "which maim" "Please install maim with:\n\$ sudo apt install maim"; [ $? -eq 0 ] || return 1
    _easybash_check "which zbarimg" "Please install zbar-tools with:\n\$ sudo apt install zbar-tools"; [ $? -eq 0 ] || return 1

    SCR_IMG=$(mktemp --tmpdir scan_qrXXXXXXXX.png)
    OCR_TXT="${SCR_IMG%.*}"
    trap "rm $SCR_IMG" EXIT
    maim -s "$SCR_IMG" -m 1
    zbarimg -q "$SCR_IMG"
    rm "$SCR_IMG"
}


#EASYBASH_FUNC:enhance_image:Neural image enhancer with 2x resolution increase
#EASYBASH_SRC:https://github.com/alexjc/neural-enhance
function enhance_image(){
    _easybash_check "which docker" "Please install docker with:\n\$ sudo apt install docker.io\n\$ sudo groupadd docker\n\$ sudo usermod -aG docker ${USER}"; [ $? -eq 0 ] || return 1

    echo "=================================================================================================="
    echo "Please visit for usage: https://github.com/alexjc/neural-enhance#2a-using-docker-image-recommended"
    echo "=================================================================================================="

    docker run --rm -v "$(pwd)/`dirname ${@:$#}`":/ne/input -it alexjc/neural-enhance ${@:1:$#-1} "input/`basename ${@:$#}`"
}