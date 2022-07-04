# youtube-downloader
V3 of my youtube downloader command line utility using bash, utilizing yt-dlp. Allows for multiple videos and playlist to be downloaded simultaneously, rather than one after another as default in yt-dlp, drastically reducing the download times when downloading large playlists, many videos, or both. Downloads all available metadata from the video, including but not limited to: channel, description, title, video ID, date, and more. If video contains a thumbnail and or subtitles, they will be downloaded as long as the file format supports them. Can use a dedicated urls file as specified with `-u`, and or urls directly passed into the program. Can specify whether to download as video `-v`, audio `-a`, or any other yt-dlp acceptable format `-f`.

## Options: 
`-h`      print help

`-v`      save as mp4 file 

`-a`      save as m4a file 

`-f`      specify format as yt-dlp format (default: "bv+ba/b" - best video & best audio) 

`-P`      specify download path (default: ./) 

`-u`      specify urls file
