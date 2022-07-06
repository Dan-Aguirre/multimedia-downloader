#!/bin/bash

urls="";
options="";
outputTemplate="";
contentID="";
format="bv+ba/b";
path="./";
usingPlaylistFormat=false;
printStatusOptions="--quiet --progress --newline";


printHelp () {
    echo "Options:";
    echo -e "  -h \t print help";
    echo -e "  -v \t save as mp4 file";
    echo -e "  -a \t save as m4a file";
    echo -e "  -m \t embed metadata into file (all available metadata: channel, description, title, date, chapters, and more...)";
    echo -e "  -t \t embed thumbnail into file";
    echo -e "  -s \t embed subtitles into file";
    echo -e "  -c \t append content id to title";
    echo -e "  -p \t enable playlist format (all playlists will be saved into a folder with playlist name and videos will be indexed in order)";
    echo -e "  -D \t uses quality of life defaults (same as using -m, -t, -s, -c, and -p)";
    echo -e "  -f \t specify format as yt-dlp format (default: \"bv+ba/b\" - best video & best audio)";
    echo -e "  -P \t specify download path (default: ./)";
    echo -e "  -o \t specify output template in yt-dlp format (overrides \"-c\" and \"-p\", and does not currently support spaces)";
    echo -e "  -u \t specify urls file";
}

metadata () {
    options="$options --add-metadata --compat-options embed-metadata";
}

thumbnail () {
    options="$options --embed-thumbnail";
}

subtitles () {
    options="$options --embed-subs";
}

displayContentID () {
    contentID=" [%(id)s]";
}

defaults () {
    metadata;
    thumbnail;
    subtitles;
    displayContentID;
    usingPlaylistFormat=true;
}

setOutputTemplate () {
    # does not support spaces due to yt-dlp input parsing
    outputTemplate="--output $@";
}


start=`date +%s`;

while getopts :hvamtscpDf:P:o:u: opt; do
    case $opt in
        h) printHelp; exit;;
        v) echo video option selected; format="mp4";;
        a) echo audio only option selected; format="m4a";;
        m) echo embedding metadata; metadata;;
        t) echo embedding thumbnail; thumbnail;;
        s) echo embedding subtitles; subtitles;;
        c) echo appending content id to title; displayContentID;;
        p) echo using playlist format; usingPlaylistFormat=true;;
        D) echo using QOL defaults; defaults;;
        f) echo format $OPTARG; format=$OPTARG;;
        P) echo output path=$OPTARG; path=$OPTARG;;
        o) echo output template = \"$OPTARG\"; setOutputTemplate $OPTARG;;
        u) echo using urls file; urls=$(cat $OPTARG);;
        ?) echo "Unknown option -$OPTARG"; exit 1;;
    esac
done

# shifts input to ignore flags, leaving only urls as last input
shift $(( OPTIND - 1 ));
urls="$urls "$@;

echo;
echo "parsing urls... (this may take some time if there's a long playlist or many playlists)";

# removes playlist references from the end of a video "&list=...&index=..."
urls=$(echo $urls | sed 's%\(&list=\)[^[:space:]]\+%%g');

for playlist in $urls; do
    if [[ $playlist == *"playlist?list="* ]]; then

        urls=$(echo $urls | sed "s|$playlist||g"); # removes playlist URL from urls list

        if $usingPlaylistFormat; then
            playlistTitle=$(yt-dlp --print playlist -I 1:1 $playlist | sed 's/ /_/g'); # replace spaces with underscores in playlist title

            Index=1
            for id in $(yt-dlp --print id $playlist); do
                urls="$urls [PLAYLISTINFO,$playlistTitle,$Index]https://www.youtube.com/watch?v="$id;
                Index=$((Index+1))
            done

        else
            for id in $(yt-dlp --print id $playlist); do
                urls="$urls https://www.youtube.com/watch?v="$id;
            done

        fi
    fi
done

# printing urls in a human readable format, adding count at then end
echo $urls | tr " " "\n";
echo -n "Urls: ";
echo $urls | wc -w;
echo;

# trap to stop yt-dlp at user interrupt
trap 'jobs -p | xargs kill' SIGINT

for url in $urls; do
    # progress-template cannot be encoded into a variable due to an error with yt-dlp parsing
    # proceeding outputTemplate overrides initial –-output flag
    if [[ $url == *"PLAYLISTINFO"* ]]; then
        # grabs playlist info between the starting "[" and ending "]" brackets
        playlistInfo=$(echo $url | sed 's/.*\[//;s/\].*//');

        # isolate url from string
        url=$(echo $url | cut -d "]" -f 2);

        playlistTitle=$(echo $playlistInfo | cut -d "," -f 2);
        playlistIndex=$(echo $playlistInfo | cut -d "," -f 3);

        yt-dlp --output "$playlistTitle/$playlistIndex - %(title)s$contentID.%(ext)s" $outputTemplate -f $format -P $path $options $printStatusOptions --progress-template "$(echo -e "\033[1;97m[%(info.title)s]\033[1;0m")[%(info.id)s]$(echo -e "\n\r")%(progress._default_template)s)" $url &

   else
        yt-dlp --output "%(title)s$contentID.%(ext)s" $outputTemplate -f $format -P $path $options $printStatusOptions --progress-template "$(echo -e "\033[1;97m[%(info.title)s]\033[1;0m")[%(info.id)s]$(echo -e "\n\r")%(progress._default_template)s)" $url &
   fi
done

# waits for all yt-dlp background processes to finish
wait;


end=`date +%s`;
runtime=$((end-start));

echo;
date -d@$runtime -u +%H:%M:%S | xargs echo runtime:
