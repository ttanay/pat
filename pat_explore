#!/usr/bin/bash

usage=$(cat << EOF
Pat: An HTTP API development toolkit

Usage: $0 [OPTIONS] FILEPATH
It runs HTTP requests specified in a file
and runs them.

Supported options:
    * -s: Open the response in a terminal pager
        The response is piped to a terminal pager.
        You can specify your own with the TERM_PAGE variable.
        The default is \`less\`.
    * -p: Pretty print the response.
        The response is piped to a pretty printer.
        You can specify your own with the RESP_FMT variable.
        The default is \`jq .\` if it is available on the system.
    * -h: Print help message
EOF
)

# Backends
formatter=${RESP_FMT:-"jq ."}
scroller=${TERM_PAGE:-"less"}

# COLORS
RED='\033[0;31m'
NC='\033[0m' # No Color
GREEN='\033[0;32m'
YELLOW='\033[1;33m'

if [ -z "$1" ]; then
    echo "Error: filepath not specified"
    echo "$usage"
    exit 1
fi

curl_args=""
# TODO: Add option to show curl progress
curl_progress=false
scroll_mode=false
pretty_print=false
while getopts f:hps opt; do
    case $opt in
        h) echo "$usage"; exit;;
        p) pretty_print=true;;
        s) scroll_mode=true;;
        :) echo "Missing argument for option -$OPTARG"; echo "$usage"; exit 1;;
       \?) echo "Unknown option -$OPTARG"; echo "$usage"; exit 1;;
    esac
done

# Unset flags if commands not available
if [ "$pretty_print" = true ] && ! command -v "${formatter%% *}" &> /dev/null ; then
    echo "Specified pretty printer \`$formatter\` not found; Skipping pretty printing..."
    pretty_print=false
fi
if [ "$scroll_mode" = true ] && ! command -v "${scroller%% *}" &> /dev/null ; then
    echo "Specified terminal pager \`$scroller\` not found; Skipping terminal pager..."
    scroll_mode=false
fi

if ! "$curl_progress"; then
    curl_args+="--silent --show-error --fail"
fi

shift $(( OPTIND - 1 ))
filepath="$1"
shift 1

exit_code=0
requests=(`find "$filepath" -type f -path "*.curlf" -and -not -path "$0"`)
for request in "${requests[@]}"
do
    echo "Running $request ..."
    # Read file
    request_spec=`cat $request`

    # Concatenate with curl
    curl_cmd="curl ${curl_args} ${request_spec}"
    # Run curl request
    response=$(eval "$curl_cmd" 2>&1)

    curl_exit_code=`echo $?`
    if [ "$curl_exit_code" != 0 ]; then
        echo "Curl encountered an error: "
        echo "$response"
        exit_code=1
        continue
    fi

    # Print response in desired manner
    if [ "$pretty_print" = true ] && [ "$scroll_mode" = true ]; then
        echo "$response" | (eval "$formatter") | (eval "$scroller")
    elif [ "$pretty_print" = true ] && [ "$scroll_mode" = false ]; then
        echo "$response" | (eval "$formatter")
    elif [ "$pretty_print" = false ] && [ "$scroll_mode" = true ]; then
        echo "$response" | (eval "$scroller")
    else
        echo "$response"
    fi
done

exit $exit_code
