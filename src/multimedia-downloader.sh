#!/bin/bash

urls="";
options="";
outputTemplate="";
contentID="";
savedURLsFile="";
format="bv*+ba/b --format-sort ext";
path="./";
usingPlaylistFormat=false;
printStatusOptions="--quiet --progress --newline";


printHelp () {
    echo "Usage: $0 [OPTION]... [URLS]...";
    echo;
    echo "Options:";
    echo -e "  -h \t\t\t print help";
    echo -e "  -v \t\t\t save as best video only file";
    echo -e "  -a \t\t\t save as best audio only file";
    echo -e "  -m \t\t\t embed metadata into file (all available metadata: channel, description, title, date, chapters, and more...)";
    echo -e "  -t \t\t\t embed thumbnail into file";
    echo -e "  -s \t\t\t embed subtitles into file (only for mp4, webm and mkv videos)";
    echo -e "  -c \t\t\t append content id to title";
    echo -e "  -p \t\t\t enable youtube playlist format (youtube playlists will be saved into a folder with playlist name and videos will be indexed in order)";
    echo -e "  -d \t\t\t uses quality of life defaults (same as using -m, -t, -s, -c, and -p)";
    echo -e "  -l \t\t\t list all supported sites";
    echo -e "  -f FORMAT \t\t specify format as yt-dlp format (default: \"bv*+ba/b --format-sort ext\" **best video + best audio, ordered by extension)";
    echo -e "  -P DIRECTORY \t\t specify download path (default: ./)";
    echo -e "  -o [TYPES:]TEMPLATE \t specify output template in yt-dlp format (overrides \"-c\" and \"-p\", and does not currently support spaces)";
    echo -e "  -u FILE \t\t specify urls file";
    echo -e "  -U FILE \t\t specify file to save urls in after completion (appends)";
    echo -e "  -M [OPTIONS] \t\t specify the sections to be marked using sponsorBlock [intro, outro, selfpromo, preview, filler, interaction, music_offtopic, poi_highlight, all]";
    echo -e "\t\t\t separated via \",\" or excluded via \"-\""
    echo -e "  -R [OPTIONS] \t\t specify the sections to be removed using sponsorBlock, overrides mark (-M), and has same options excluding \"poi_highlight\""
}

video () {
    # best video sorted by extension
    format="bv --format-sort vext";
}

audio () {
    # best audio sorted by extension
    format="ba --format-sort aext";
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

sponsorBlockMark(){
    options="--sponsorblock-mark $@ $options";
}

sponsorBlockRemove(){
    options="--sponsorblock-remove $@ $options";
}


start=`date +%s`;


# processing flags
while getopts :hvamtscpdlf:P:o:u:U:M:R: opt; do
    case $opt in
        h) printHelp; exit;;
        v) echo video option selected; video;;
        a) echo audio only option selected; audio;;
        m) echo embedding metadata; metadata;;
        t) echo embedding thumbnail; thumbnail;;
        s) echo embedding subtitles; subtitles;;
        c) echo appending content id to title; displayContentID;;
        p) echo using playlist format; usingPlaylistFormat=true;;
        d) echo using quality of life defaults; defaults;;
        l) echo listing supported sites:; yt-dlp --extractor-descriptions;;
        f) echo format $OPTARG; format=$OPTARG;;
        P) echo output path=$OPTARG; path=$OPTARG;;
        o) echo output template = \"$OPTARG\"; setOutputTemplate $OPTARG;;
        u) echo using urls file; urls=$(cat $OPTARG);;
        U) echo saving urls to $OPTARG; savedURLsFile=$OPTARG;;
        M) echo using sponsor block mark options: $OPTARG; sponsorBlockMark $OPTARG;;
        R) echo using sponsor block remove options: $OPTARG; sponsorBlockRemove $OPTARG;;
        ?) echo Unknown option -$OPTARG; exit 1;;
    esac
done


# shifts input to ignore flags, appends remaining input into urls variable
shift $(( OPTIND - 1 ));
urls="$urls "$@;


echo;
echo "parsing urls... (this may take some time if there's a long playlist or many playlists)";


# extracts urls from playlist, and if -p is used, embeds playlist info into the url string for processing later on
for playlist in $urls; do
    if [[ $playlist == *"www.youtube.com/playlist?list="* ]]; then

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

    # removes playlist references from the end of youtube videos "&list=...&index=..."
    if [[ $url = *"www.youtube.com"* ]]; then
        url=$(echo $url | sed 's%\(&list=\)[^[:space:]]\+%%g');
    fi

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
