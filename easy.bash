#!/bin/bash

#============================================================================================================#
#=============================================== PARAMETERS =================================================#
#============================================================================================================#

#EASYBASH_PARAM:EASYBASH_SCRIPT_PATH:todo
export EASYBASH_SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"

#EASYBASH_PARAM:EASYBASH_INSTALL_DIR:todo
export EASYBASH_INSTALL_DIR=$(dirname "$EASYBASH_SCRIPT_PATH")

#EASYBASH_PARAM:EASYBASH_EXTRA_PATH:todo
export EASYBASH_EXTRA_PATH="$EASYBASH_INSTALL_DIR""/extra"

#EASYBASH_PARAM:EASYBASH_MAX_CPU_THREADS:cpu thread limiter for heavy tasks
export EASYBASH_MAX_CPU_THREADS=8

#============================================================================================================#
#================================================= HELPER FUNCTIONS =========================================#
#============================================================================================================#

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

function _easybash_check_ytdlp(){
    EASYBASH_YTDLP="$EASYBASH_EXTRA_PATH/yt-dlp"
    _easybash_check "cat $EASYBASH_YTDLP" "Installing yt-dlp..."
    if [ $? -ne "0" ]; then
        wget https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -O "$EASYBASH_YTDLP"
        chmod a+rx "$EASYBASH_YTDLP"
    fi
    "$EASYBASH_YTDLP" -U
}

function _easybash_check_pyenv(){
    EASYBASH_PYENV="$EASYBASH_EXTRA_PATH/easyenv"
    python3 -m venv "$EASYBASH_PYENV"
    echo "$EASYBASH_PYENV/bin/activate"
    source "$EASYBASH_PYENV/bin/activate"
}

function _print_header_func(){
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

function _print_header_param(){
    local PARAM_HEADER_PREFIX="$1"

    local PARSEDBASHRC=$(cat "$EASYBASH_SCRIPT_PATH" | grep "$PARAM_HEADER_PREFIX")
    local HELPSTRING=""
    while IFS= read -r line; do
        local COMMANDNAME=$(echo $line | cut -d':' -f2)
        local COMMANDDESCRIPTION=$(echo $line | cut -d':' -f3)
        local WHITESPACEFILLER="                                                   "
        local NEWHELPSTRING=$(printf '%.25s : %s' "$COMMANDNAME$WHITESPACEFILLER" "${!COMMANDNAME}")
        local HELPSTRING="$HELPSTRING$NEWHELPSTRING\n"
    done <<< "$PARSEDBASHRC"
    printf "$HELPSTRING"
}

#EASYBASH_FUNC:easybash_help:Prints help message for EasyBash
function easybash_help(){
    echo "======================================================================="
    echo "============================== EASY BASH =============================="
    echo "======================================================================="
    echo -e "[*] Easy Bash Parameters:"
    _print_header_param "#EASYBASH""_PARAM"
    echo -e "\n[*] Easy Bash Functions:"
    _print_header_func "#EASYBASH""_FUNC"
    echo -e "\n[*] Easy Bash Aliases:"
    _print_header_func "#EASYBASH""_ALIAS"
}

#============================================================================================================#
#================================================= ALIASES ==================================================#
#============================================================================================================#

#EASYBASH_ALIAS:py:Shorter version of python3
alias py='python3' 

#EASYBASH_ALIAS:fix-skype:Kills Skype background processes without terminating the program
alias fix-skype='kill -HUP `ps -eo "pid:1,args:1" | grep -E "\-\-type=renderer.*skypeforlinux" | cut -d" " -f1`'

#============================================================================================================#
#================================================= FUNCTIONS ================================================#
#============================================================================================================#

#EASYBASH_FUNC:jekyll_server:Starts jekyll docker used for rendering github.io webpages
#EASYBASH_SRC:https://github.com/BretFisher/jekyll-serve
function jekyll_serve(){
    _easybash_check "which docker" "Please install docker with:\n\$ sudo apt install docker.io\n\$ sudo groupadd docker\n\$ sudo usermod -aG docker ${USER}"; [ $? -eq 0 ] || return 1
    docker run -p 4000:4000 -v $(pwd):/site bretfisher/jekyll-serve
}

#EASYBASH_FUNC:wipe_all_docker_data:Stops all containers and removes all docker related data (images, volumes, etc.)
function wipe_all_docker_data(){
    _easybash_check "which docker" "Please install docker with:\n\$ sudo apt install docker.io\n\$ sudo groupadd docker\n\$ sudo usermod -aG docker ${USER}"; [ $? -eq 0 ] || return 1
    [ $? -eq 0 ] || return 1
    docker kill $(docker ps -q)
    docker system prune -a --volumes
}

#EASYBASH_FUNC:unrestrict_pdf:Enables disabled features (e.g. copying)
function unrestrict_pdf(){
    _easybash_check "which qpdf" "Please install qpdf with:\n\$ sudo apt install qpdf"; [ $? -eq 0 ] || return 1

    for var in "$@"
    do
        local INPUT_FILE="$var"
        local OUTPUT_FILE="${INPUT_FILE%.*}.unrestricted.pdf"
        if [[ "$INPUT_FILE" == *".unrestricted."* ]]; then
            echo "$INPUT_FILE is already processed! (according to the filename)"
            continue
        fi
        echo "Processing $INPUT_FILE..."
        qpdf --decrypt "$INPUT_FILE" "$OUTPUT_FILE"
    done
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
function gitaddcommitpush(){ 
    _easybash_check "which git" "Please install git with:\n\$ sudo apt install git"; [ $? -eq 0 ] || return 1
    git add . &&
    git commit -m "$1" &&
    git push origin
}

#EASYBASH_FUNC:temp_chrome:Temporary google-chrome-browser. Can be reset with temp_chrome_reset
function temp_chrome(){
    _easybash_check "google-chrome" "Please Google Chrome from from https://www.google.com/chrome/"
    local EASY_CHROME="$EASYBASH_EXTRA_PATH/temp_chrome"
    local EASY_CHROME_USERDATA="$EASY_CHROME/userdata"
    mkdir -p "$EASY_CHROME_USERDATA"
    touch "$EASY_CHROME/DELETE_userdata_TO_RESET_TEMPORARY_CHROME"
    google-chrome --user-data-dir="$EASY_CHROME_USERDATA"
}

#EASYBASH_FUNC:temp_chrome_reset:Describes instructions for resetting temp_chrome profile
function temp_chrome_reset(){
    EASY_CHROME="$EASYBASH_EXTRA_PATH/temp_chrome"
    xdg-open "$EASY_CHROME"
}

#EASYBASH_FUNC:scan_text:Select an area on the screen to run OCR and get text output
function scan_text(){
    _easybash_check "which mogrify" "Please install imagemagick with:\n\$ sudo apt install imagemagick"; [ $? -eq 0 ] || return 1
    _easybash_check "which maim" "Please install maim with:\n\$ sudo apt install maim"; [ $? -eq 0 ] || return 1
    _easybash_check "which tesseract" "Please install tesseract-ocr with:\n\$ sudo add-apt-repository ppa:alex-p/tesseract-ocr-devel\n\$ sudo apt update\n\$ sudo apt install tesseract-ocr"; [ $? -eq 0 ] || return 1

    echo "==================================================="
    echo "Click to the target window or select a bounding box"
    echo "==================================================="

    SCR_IMG=$(mktemp --tmpdir scan_textXXXXXXXX.png)
    OCR_TXT="${SCR_IMG%.*}"
    trap "rm $SCR_IMG" EXIT
    trap "rm $OCR_TXT.txt" EXIT
    maim -s "$SCR_IMG" -m 1
    mogrify -modulate 100,0 -resize 400% "$SCR_IMG"
    tesseract "$SCR_IMG" "$OCR_TXT" &> /dev/null
    cat "$OCR_TXT.txt"
    rm "$SCR_IMG"
    rm "$OCR_TXT.txt"
}


#EASYBASH_FUNC:scan_qr:Select an area on the screen to run zbarimg and get text output
function scan_qr(){
    _easybash_check "which maim" "Please install maim with:\n\$ sudo apt install maim"; [ $? -eq 0 ] || return 1
    _easybash_check "which zbarimg" "Please install zbar-tools with:\n\$ sudo apt install zbar-tools"; [ $? -eq 0 ] || return 1

    echo "==================================================="
    echo "Click to the target window or select a bounding box"
    echo "==================================================="

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

#EASYBASH_FUNC:diff_cat:Colorful alternative to "diff", using git diff
function diff_cat(){
    EASY_GIT_OUTPUT=$(git diff --color --no-index $@)
    echo -e "$EASY_GIT_OUTPUT"
}

#EASYBASH_FUNC:diff_less:Colorful alternative to "diff", using git diff
function diff_less(){
    git diff --no-index $@
}

#EASYBASH_FUNC:gitaddcommitpush:Adds all files in the current location, commits @1 and pushes to the origin
function gitaddcommitpush(){ 
    _easybash_check "which git" "Please install git with:\n\$ sudo apt install git"; [ $? -eq 0 ] || return 1

    git add . &&
    git commit -m "$1" &&
    git push origin
}

#EASYBASH_FUNC:yt_video:Downloads videos or playlists with yt-dlp.
function yt_video(){
    _easybash_check_ytdlp
    "$EASYBASH_YTDLP" $@
}

#EASYBASH_FUNC:yt_mp4:Downloads videos or playlists with yt-dlp and re-encodes into mp4.
function yt_mp4(){
    _easybash_check_ytdlp
    "$EASYBASH_YTDLP" --recode-video mp4 $@
}

#EASYBASH_FUNC:yt_video:Downloads videos or fplaylists with yt-dlp and re-encodes into mp3.
function yt_mp3(){
    _easybash_check_ytdlp
    "$EASYBASH_YTDLP" -x --audio-format mp3 --audio-quality 0 $@
}

#EASYBASH_FUNC:backscrub:Virtual background for webcams with deep learning. Run `backscrub_init` first!Webcam device can be passed as a parameter.
#EASYBASH_SRC:https://github.com/salihmarangoz/backscrub
function backscrub(){
    EASY_BACKSCRUB="$EASYBASH_EXTRA_PATH/backscrub"
    EASY_BACKSCRUB_DEVICE_NUM="99" # /dev/video99

    # init v4l2loopback
    sudo rmmod v4l2loopback
    sudo modprobe v4l2loopback devices=1 video_nr="$EASY_BACKSCRUB_DEVICE_NUM" max_buffers=2 exclusive_caps=1 card_label="VirtualCam"

    if [ -z "$1" ]
    then
        # no video device is given. find automatically
        for var in $(ls /dev/video*)
        do
            v4l2-ctl --list-formats -d "$var" | grep "[0]" &> /dev/null
            if [ $? -ne "0" ]; then
                break
            fi
            EASYBASH_BESTWEBCAM=$(echo $var)
        done
    else
          EASYBASH_BESTWEBCAM=$(echo $1)
    fi

    "$EASY_BACKSCRUB"/build/deepseg -d -d -c "$EASYBASH_BESTWEBCAM" -v /dev/video"$EASY_BACKSCRUB_DEVICE_NUM" -b "$EASY_BACKSCRUB/office.jpg" -m "$EASY_BACKSCRUB/models/best1-selfiesegmentation_mlkit-256x256-2021_01_19-v1215.f16.tflite"

    echo "===================================================="
    echo "===================================================="
    echo "===== IF IT DIDNT WORK RUN backscrub_init !!! ======"
    echo "===================================================="
    echo "===================================================="
}

#EASYBASH_FUNC:backscrub:Installs/compiles backscrub and v4l2loopback.
function backscrub_init(){
    EASY_BACKSCRUB="$EASYBASH_EXTRA_PATH/backscrub"

    # setup v4l2loopback
    cd /tmp
    git clone https://github.com/umlaeute/v4l2loopback.git
    cd v4l2loopback
    git pull --ff-only
    make && sudo make install
    sudo depmod -a

    # setup backscrub
    git clone --recursive https://github.com/salihmarangoz/backscrub.git "$EASY_BACKSCRUB"
    cd "$EASY_BACKSCRUB"
    git pull --ff-only
    sudo apt install libopencv-dev build-essential curl
    ./cmake-3.20.3-linux-x86_64.sh --skip-license
    git clone https://github.com/tensorflow/tensorflow/ --depth 1 --branch v2.4.0
    mkdir build; cd build
    "$EASY_BACKSCRUB"/bin/cmake ..
    make -j8
}


#============================================================================================================#
#================================================= TODO =====================================================#
#============================================================================================================#

#EASYBASH_FUNC:compress_audio:Compress audio with MP3
function compress_audio(){
    _easybash_check "which ffmpeg" "Please install ffmpeg with:\n\$ sudo apt install ffmpeg"; [ $? -eq 0 ] || return 1

    for var in "$@"
    do
        INPUT_FILE="$var"
        OUTPUT_FILE="${INPUT_FILE%.*}.compressed.mp3"
        if [[ "$INPUT_FILE" == *".compressed."* ]]; then
            echo "$INPUT_FILE is already compressed! (according to the filename)"
            continue
        fi
        ffmpeg -i "$INPUT_FILE" -acodec libmp3lame -threads "$BASHRC_CPU_THREADS" "$OUTPUT_FILE"
    done
    alert "Audio compressing job finished"
}


#EASYBASH_FUNC:compress_video:Compress videos with Vary the Constant Rate Factor to MP4
function compress_video(){
    _easybash_check "which ffmpeg" "Please install ffmpeg with:\n\$ sudo apt install ffmpeg"; [ $? -eq 0 ] || return 1

    for var in "$@"
    do
        INPUT_FILE="$var"
        OUTPUT_FILE="${INPUT_FILE%.*}.compressed.mp4"
        if [[ "$INPUT_FILE" == *".compressed."* ]]; then
            echo "$INPUT_FILE is already compressed! (according to the filename)"
            continue
        fi
        ffmpeg -i "$INPUT_FILE" -vcodec libx264 -crf 23 -threads "$BASHRC_CPU_THREADS" "$OUTPUT_FILE"
    done
    alert "Video compressing job finished"
}


#EASYBASH_FUNC:archive_video:Compress videos to 720p resolution, mono audio channel, 15 fps
function archive_video(){
    _easybash_check "which ffmpeg" "Please install ffmpeg with:\n\$ sudo apt install ffmpeg"; [ $? -eq 0 ] || return 1

    for var in "$@"
    do
        INPUT_FILE="$var"
        OUTPUT_FILE="${INPUT_FILE%.*}.archived.mp4"
        if [[ "$INPUT_FILE" == *".archived."* ]]; then
            echo "$INPUT_FILE is already archived! (according to the filename)"
            continue
        fi
        ffmpeg -i "$INPUT_FILE" -r 15 -preset veryslow -s hd720 -map_channel 0.1.0 -async 1 -threads "$BASHRC_CPU_THREADS" "$OUTPUT_FILE"
    done
    alert "Video archiving job finished"
}


#EASYBASH_FUNC:summarize_video:Summarizes the video by deleting duplicate frames
function summarize_video(){
    _easybash_check "which ffmpeg" "Please install ffmpeg with:\n\$ sudo apt install ffmpeg"; [ $? -eq 0 ] || return 1

    for var in "$@"
    do
        INPUT_FILE="$var"
        TMP_FILE=$(mktemp "XXXXXXXXXXXXXX$INPUT_FILE")
        OUTPUT_FILE="${INPUT_FILE%.*}.summarized.mp4"
        if [[ "$INPUT_FILE" == *".summarized."* ]]; then
            echo "$INPUT_FILE is already summarized! (according to the filename)"
            continue
        fi
        ffmpeg -y -i "$INPUT_FILE" -threads "$BASHRC_CPU_THREADS" -vf mpdecimate,setpts=N/FRAME_RATE/TB "$TMP_FILE"
        LAST_FRAME_POS=$(ffmpeg -i "$TMP_FILE" -threads "$BASHRC_CPU_THREADS" -map 0:v:0 -c copy -f null - 2>&1 | grep frame | cut -d' ' -f3)
        ffmpeg -i "$TMP_FILE" -threads "$BASHRC_CPU_THREADS" -vf trim=start_frame=0:end_frame=$LAST_FRAME_POS -an "$OUTPUT_FILE"
        rm "$TMP_FILE"
    done
    alert "Video summarizing job finished"
}


#EASYBASH_FUNC:stabilize_video:Stabilizes/deshakes video by using vid.stab ffmpeg plugin
function stabilize_video(){
    BASHRC_EASY_FILES_FFMPEG="$EASYBASH_EXTRA_PATH/ffmpeg"
    FFMPEG_EASY="$BASHRC_EASY_FILES_FFMPEG/ffmpeg"

    _easybash_check "cat $FFMPEG_EASY" "Installing ffmpeg..."
    if [ $? -ne "0" ]; then
        mkdir -p "$BASHRC_EASY_FILES_FFMPEG"
        wget "https://johnvansickle.com/ffmpeg/builds/ffmpeg-git-amd64-static.tar.xz" -O "$EASYBASH_EXTRA_PATH/ffmpeg.tar.xz"
        tar xf "$EASYBASH_EXTRA_PATH/ffmpeg.tar.xz" -C  "$BASHRC_EASY_FILES_FFMPEG" --strip-components=1
        rm "$EASYBASH_EXTRA_PATH/ffmpeg.tar.xz"
    fi

    for var in "$@"
    do
        INPUT_FILE="$var"
        OUTPUT_FILE="${INPUT_FILE%.*}.stabilized.mp4"
        if [[ "$INPUT_FILE" == *".stabilized."* ]]; then
            echo "$INPUT_FILE is already stabilized! (according to the filename)"
            continue
        fi
        TRANSFORM_FILE=$(mktemp "XXXXXXXXXXXXXXtransform.trf")
        $FFMPEG_EASY -i "$INPUT_FILE" -threads "$EASYBASH_MAX_CPU_THREADS" -vf vidstabdetect="$TRANSFORM_FILE" -f null -
        $FFMPEG_EASY -i "$INPUT_FILE" -threads "$EASYBASH_MAX_CPU_THREADS" -vf vidstabtransform="$TRANSFORM_FILE",unsharp=5:5:0.8:3:3:0.4 "$OUTPUT_FILE"
        rm "$TRANSFORM_FILE"
    done
    alert "Video stabilizing job finished"
}


