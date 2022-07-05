# youtube-downloader
![Shell Script](https://img.shields.io/badge/shell_script-%23121011.svg?style=for-the-badge&logo=gnu-bash&logoColor=white)

V3 of my youtube downloader command line utility using bash, utilizing yt-dlp. Allows for multiple videos and playlist to be downloaded simultaneously, rather than one after another as default in yt-dlp, drastically reducing the download times when downloading large playlists, many videos, or both. Downloads all available metadata from the video, including but not limited to: channel, description, title, video ID, date, and more. If video contains a thumbnail and or subtitles, they will be downloaded as long as the file format supports them. Can use a dedicated urls file as specified with `-u`, and or urls directly passed into the program. Can specify whether to download as video `-v`, audio `-a`, or any other yt-dlp acceptable format `-f`.

## Options
```
Options: 
 -h      print help 
 -v      save as mp4 file 
 -a      save as m4a file 
 -f      specify format as yt-dlp format (default: "bv+ba/b" - best video & best audio) 
 -P      specify download path (default: ./) 
 -u      specify urls file
```

## Requirements
This program uses a `Bash` shell and relies on `yt-dlp` as a command line utility

## TODO
|Status|Task|
|------|----|
|:heavy_check_mark:|Initial commit|
||Add function to display help|
||Option to not store metadata|
||Option to not embed thumbnail|
||Option to not embed subtitles|
||Option to include all|
||Implement output template options|
||Add playlist ordering option|
||Build yt-dlp command using functions rather than hardcoded|
||Organize and order progress and status output|
||Clean and comment code|
