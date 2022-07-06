# youtube-downloader
![Shell Script](https://img.shields.io/badge/shell_script-%23121011.svg?style=for-the-badge&logo=gnu-bash&logoColor=white)

V3 of my youtube downloader command line utility using bash, utilizing yt-dlp. Allows for multiple videos and playlist to be downloaded simultaneously, rather than one after another as default in yt-dlp, drastically reducing the download times when downloading large playlists, many videos, or both. Downloads all available metadata from the video, including but not limited to: channel, description, title, video ID, date, chapters, and more. If video contains a thumbnail and or subtitles, they will be downloaded as long as the file format supports them. Can use a dedicated urls file as specified with `-u`, and or urls directly passed into the program. Can specify whether to download as video `-v`, audio `-a`, or any other yt-dlp acceptable format `-f`.

## Options
```
Options:
  -h     print help
  -v     save as mp4 file
  -a     save as m4a file
  -m     embed metadata into file
  -t     embed thumbnail into file
  -s     embed subtitles into file
  -c     append content id to title
  -f     specify format as yt-dlp format (default: "bv+ba/b" - best video & best audio)
  -p     enable playlist format (all playlists will be saved into a folder with playlist name and videos will be indexed in order)
  -P     specify download path (default: ./)
  -o     specify output template in yt-dlp format (overrides "-c" and "-p", and does not currently support spaces)
  -u     specify urls file
```

## Requirements
This program uses a `Bash` shell and relies on `yt-dlp` as a command line utility

## TODO
|Status|Task|
|------|----|
|:heavy_check_mark:|Initial commit|
|:heavy_check_mark:|Add function to display help|
|:heavy_check_mark:|Option to store metadata|
|:heavy_check_mark:|Option to embed thumbnail|
|:heavy_check_mark:|Option to embed subtitles|
||Option to include all|
|:heavy_check_mark:|Implement output template options|
|:heavy_check_mark:|Add playlist formatting and ordering option|
||Option to save/append url's to file for archiving|
|:heavy_check_mark:|Build yt-dlp command using functions rather than hardcoded|
||Organize and order progress and status output|
||Clean and comment code|
