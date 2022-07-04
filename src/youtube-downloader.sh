#!/bin/bash

urls=""
format="bv+ba/b"
path="./"

start=`date +%s`

while getopts :hvamf:P:u: opt; do
    case $opt in
        h) echo -e "Options: \n -h \t print help \n -v \t save as mp4 file \n -a \t save as m4a file \n -f \t specify format as yt-dlp format (default: \"bv+ba/b\") \n -P \t specify download path (default: ./) \n -u \t specify urls file"; exit;;
        v) echo video option selected; format="mp4";;
        a) echo audio only option selected; format="m4a";;
        f) echo fromat $OPTARG; format=$OPTARG;;
        P) echo output path=$OPTARG; path=$OPTARG;;
        u) echo use urls file; urls=$(cat $OPTARG);;
        ?) echo "Unknown option -$OPTARG"; exit 1;;
    esac
done

shift $(( OPTIND - 1 ))
urls="$urls "$@

echo -e "\nparsing urls... (this may take some time if there's a long playlist or many playlists)"

for playlist in $urls; do
    if [[ $playlist == *"playlist?list="* ]]; then
        for id in $(yt-dlp --print id $playlist); do
            urls="$urls https://www.youtube.com/watch?v="$id;
        done
        urls=$(printf '%s\n' "${urls//$playlist /}")
    fi
done

echo $urls | tr " " "\n"
echo $urls | wc -w
echo

trap 'jobs -p | xargs kill' SIGINT

for url in $urls; do
    yt-dlp -f $format -P $path --embed-thumbnail --embed-subs --add-metadata --compat-options embed-metadata -q --progress --newline --progress-template "$(echo -e '\033[1;97m[%(info.title)s]\033[1;0m')[%(info.id)s]$(echo -e "\n\r")%(progress._default_template)s)" $url &
done

wait

end=`date +%s`
runtime=$((end-start))

echo
date -d@$runtime -u +%H:%M:%S | xargs echo runrime:
