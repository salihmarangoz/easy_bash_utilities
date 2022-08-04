# easy_bash_utilities

This is my Bash Terminal tool-set (at least the generalizable ones). I hope this would be useful for you too. If you have a useful tool/script/program feel free to share it with me (on Issues).

Also, check [EXTRA.md](EXTRA.md) for other useful tricks related to Bash.



## Install

```bash
$ sudo apt install git cmake build-essential
$ git clone https://github.com/salihmarangoz/easy_bash_utilities.git ~/.easy_bash_utilities
```

And add the following line at the end of `~/.bashrc` file.

```
source $HOME/.easy_bash_utilities/easy.bash
```



## Update

```bash
$ cd ~/.easy_bash_utilities
$ git pull --ff-only
```



## Usage

```bash
$ easybash_help
```

This command prints the message below: (may be a bit old)

```
=======================================================================
============================== EASY BASH ==============================
=======================================================================
[*] Easy Bash Parameters:
EASYBASH_SCRIPT_PATH           : /home/salih/.easy_bash_utilities/easy.bash
EASYBASH_INSTALL_DIR           : /home/salih/.easy_bash_utilities
EASYBASH_EXTRA_PATH            : /home/salih/.easy_bash_utilities/extra
EASYBASH_MAX_CPU_THREADS       : 8

[*] Easy Bash Functions:
easybash_help                  : Prints help message for EasyBash
jekyll_server                  : Starts jekyll docker used for rendering github.io webpages
wipe_all_docker_data           : Stops all containers and removes all docker related data (images, volumes, etc.)
unrestrict_pdf                 : Enables disabled features (e.g. copying)
android_remote_control         : Android screenshare to the PC. Enable USB debugging on android, then connect with a USB.
no_network                     : Start $@ without an internet connection
gitaddcommitpush               : Adds all files in the current location, commits @1 and pushes to the origin
temp_chrome                    : Temporary google-chrome-browser. Can be reset with temp_chrome_reset
temp_chrome_reset              : Describes instructions for resetting temp_chrome profile
scan_text                      : Select an area on the screen to run OCR and get text output
scan_qr                        : Select an area on the screen to run zbarimg and get text output
enhance_image                  : Neural image enhancer with 2x resolution increase
diff_cat                       : Colorful alternative to "diff", using git diff
diff_less                      : Colorful alternative to "diff", using git diff
gitaddcommitpush               : Adds all files in the current location, commits @1 and pushes to the origin
yt_video                       : Downloads videos or playlists with yt-dlp.
yt_mp4                         : Downloads videos or playlists with yt-dlp and re-encodes into mp4.
yt_video                       : Downloads videos or fplaylists with yt-dlp and re-encodes into mp3.
backscrub                      : Virtual background for webcams. Run `backscrub_init` first! Webcam can be passed as a parameter.
backscrub_init                 : Installs and compiles backscrub and its dependencies.
compress_audio                 : Compress audio with MP3
compress_video                 : Compress videos with Vary the Constant Rate Factor to MP4
archive_video                  : Compress videos to 720p resolution, mono audio channel, 15 fps
summarize_video                : Summarizes the video by deleting duplicate frames
stabilize_video                : Stabilizes/deshakes video by using vid.stab ffmpeg plugin
easybash_install_basic_utils   : Installs basic utilities
easybash_install_tmux          : Installs tmux and initializes the config file
easybash_install_sublimetext   : Installs Sublime Text and initializes the config file

[*] Easy Bash Aliases:
help_easybash                  : Alternative version of easybash_help
py                             : Shorter version of python3
fix-skype                      : Kills Skype background processes without terminating the program
```



## Uninstall

- Remove `source $HOME/.easy_bash_utilities/easy.bash` from `~/.bashrc`
- Delete `~/.easy_bash_utilities` folder.
