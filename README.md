# multimedia-downloader
![Shell Script](https://img.shields.io/badge/shell_script-%23121011.svg?style=for-the-badge&logo=gnu-bash&logoColor=white)

V3 of my multimedia downloader built for speed. A command line utility using bash, utilizing yt-dlp. Allows for multiple videos and playlist to be downloaded simultaneously, rather than one after another as default in yt-dlp, drastically reducing the download times when downloading large playlists, many videos, or both.


## Requirements
This program uses a `Bash` shell and relies on `yt-dlp` as a command line utility


## Installation
```
git clone https://github.com/Dan-Aguirre/multimedia-downloader.git
cd multimedia-downloader/src
chmod +x multimedia-downloader.sh
./multimedia-downloader.sh
```


## Usage
```
Usage: ./youtube-downloader.sh [OPTION]... [URLS]...

Options:
  -h                     print help
  -v                     save as best video only file
  -a                     save as best audio only file
  -m                     embed metadata into file (all available metadata: channel, description, title, date, chapters, and more...)
  -t                     embed thumbnail into file
  -s                     embed subtitles into file (only for mp4, webm and mkv videos)
  -c                     append content id to title
  -p                     enable youtube playlist format (youtube playlists will be saved into a folder with playlist name and videos will be indexed in order)
  -d                     uses quality of life defaults (same as using -m, -t, -s, -c, and -p)
  -l                     list all supported sites
  -f FORMAT              specify format as yt-dlp format (default: "bv*+ba/b --format-sort ext" **best video + best audio, ordered by extension)
  -P DIRECTORY           specify download path (default: ./)
  -o [TYPES:]TEMPLATE    specify output template in yt-dlp format (overrides "-c" and "-p", and does not currently support spaces)
  -u FILE                specify urls file
  -U FILE                specify file to save urls in after completion (appends)
```


## TODO
|Status|Task|
|------|----|
|:heavy_check_mark:|Initial commit|
|:heavy_check_mark:|Support all multimedia downloads|
|:heavy_check_mark:|Add function to display help|
|:heavy_check_mark:|Option to store metadata|
|:heavy_check_mark:|Option to embed thumbnail|
|:heavy_check_mark:|Option to embed subtitles|
|:heavy_check_mark:|Option to use quality of life defaults|
|:heavy_check_mark:|Implement output template options|
|:heavy_check_mark:|Add playlist formatting and ordering option|
|:heavy_check_mark:|Option to save/append url's to file for archiving|
|:heavy_check_mark:|Build yt-dlp command using functions rather than hardcoded|
||Organize and order progress and status output|
|:heavy_check_mark:|Clean and comment code|
