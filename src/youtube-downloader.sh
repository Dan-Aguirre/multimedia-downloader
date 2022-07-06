#!/bin/bash

urls="";
options="";
outputTemplate="";
contentID="";
savedURLsFile="";
format="mp4";
path="./";
usingPlaylistFormat=false;
printStatusOptions="--quiet --progress --newline";


printHelp () {
    echo "Usage: $0 [OPTION]... [URLS]...";
    echo;
    echo "Options:";
    echo -e "  -h \t\t\t print help";
    echo -e "  -v \t\t\t save as mp4 file (default)";
    echo -e "  -a \t\t\t save as m4a file (ignores -s, cannot embed subtitles into m4a)";
    echo -e "  -m \t\t\t embed metadata into file (all available metadata: channel, description, title, date, chapters, and more...)";
    echo -e "  -t \t\t\t embed thumbnail into file";
    echo -e "  -s \t\t\t embed subtitles into file";
    echo -e "  -c \t\t\t append content id to title";
    echo -e "  -p \t\t\t enable playlist format (all playlists will be saved into a folder with playlist name and videos will be indexed in order)";
    echo -e "  -D \t\t\t uses quality of life defaults (same as using -m, -t, -s, -c, and -p)";
    echo -e "  -f FORMAT \t\t specify format as yt-dlp format";
    echo -e "  -P DIRECTORY \t\t specify download path (default: ./)";
    echo -e "  -o [TYPES:]TEMPLATE \t specify output template in yt-dlp format (overrides \"-c\" and \"-p\", and does not currently support spaces)";
    echo -e "  -u FILE \t\t specify urls file";
    echo -e "  -U FILE \t\t specify file to save urls in after completion (appends)"
}

video () {
    format="mp4";
}

audio () {
    format="m4a";
    # overrides --embed-subs, subs cannot be embedded into m4a files
    options="$options --no-embed-subs"
}

metadata () {
    options="--add-metadata --compat-options embed-metadata $options";
}

thumbnail () {
    options="--embed-thumbnail $options";
}

subtitles () {
    options="--sub-langs \"all\" --embed-subs $options";
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

saveURLs () {
    echo $urls | sed 's/ /\n/g' >> $savedURLsFile;
}


start=`date +%s`;


# processing flags
while getopts :hvamtscpDf:P:o:u:U: opt; do
    case $opt in
        h) printHelp; exit;;
        v) echo video option selected; video;;
        a) echo audio only option selected; audio;;
        m) echo embedding metadata; metadata;;
        t) echo embedding thumbnail; thumbnail;;
        s) echo embedding subtitles; subtitles;;
        c) echo appending content id to title; displayContentID;;
        p) echo using playlist format; usingPlaylistFormat=true;;
        D) echo using quality of life defaults; defaults;;
        f) echo format $OPTARG; format=$OPTARG;;
        P) echo output path=$OPTARG; path=$OPTARG;;
        o) echo output template = \"$OPTARG\"; setOutputTemplate $OPTARG;;
        u) echo using urls file; urls=$(cat $OPTARG);;
        U) echo saving urls to $OPTARG; savedURLsFile=$OPTARG;;
        ?) echo Unknown option -$OPTARG; exit 1;;
    esac
done


# shifts input to ignore flags, appends remaining input into urls variable
shift $(( OPTIND - 1 ));
urls="$urls "$@;


echo;
echo "parsing urls... (this may take some time if there's a long playlist or many playlists)";


# removes playlist references from the end of videos "&list=...&index=..."
urls=$(echo $urls | sed 's%\(&list=\)[^[:space:]]\+%%g');


# extracts urls from playlist, and if -p is used, embeds playlist info into the url string for processing later on
for playlist in $urls; do
    if [[ $playlist == *"playlist?list="* ]]; then

        # removes playlist URL from urls list
        urls=$(echo $urls | sed "s|$playlist||g");

        if $usingPlaylistFormat; then
            # replace spaces with underscores in playlist title
            playlistTitle=$(yt-dlp --print playlist -I 1:1 $playlist | sed 's/ /_/g');

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


if [ -n "$savedURLsFile" ]; then
    echo -n "Saving Urls to $savedURLsFile: ";
    saveURLs;
    echo "[Done]";
fi


end=`date +%s`;
runtime=$((end-start));

echo;
date -d@$runtime -u +%H:%M:%S | xargs echo "runtime: ";
