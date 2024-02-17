#!/usr/bin/bash


# Flow:
# A request is specified in a file with extension `curlf`
# The tool runs the file and:
#   1.  Dumps response to stdout
#   2.  Pretty prints response to stdout
#   3.  Opens it in a scrollable pane

usage=$(cat << EOF
Pat: An HTTP API development toolkit

Usage: $0 [OPTIONS]
It runs HTTP requests specified in a file
and runs them.

Supported options:
    * -f: Filepath to run requests from (default present dir)
    * -s: Open the response in a terminal pager
    * -p: Pretty print the response.
        The response is piped to a pretty printer.
        You can specify your own with the RESP_FMT variable.
        The default is \`jq .\` if it is available on the system.
    * -h: Print help message
EOF
)

# COLORS
RED='\033[0;31m'
NC='\033[0m' # No Color
GREEN='\033[0;32m'
YELLOW='\033[1;33m'

filepath=`pwd`
curl_args=""
# TODO: Add option to show curl progress
curl_progress=false
pretty_print=false
while getopts f:hp opt; do
    case $opt in
        h) echo "$usage"; exit;;
        f) $filepath=${OPTARG};;
        p) pretty_print=true;;
        :) echo "Missing argument for option -$OPTARG"; echo "$usage"; exit 1;;
       \?) echo "Unknown option -$OPTARG"; echo "$usage"; exit 1;;
    esac
done

formatter=${RESP_FMT:-"jq ."}

if ! "$curl_progress"; then
    curl_args+="-s"
fi

shift $(( OPTIND - 1 ))

requests=(`find "$filepath" -type f -name "*.curlf" -and -not -name "$0"`)
for request in "${requests[@]}"
do
    # Read file
    request_spec=`cat $request`

    # Concatenate with curl
    curl_cmd="curl ${curl_args} ${request_spec}"
    # Run curl request
    response=$(eval "$curl_cmd")

    # Print response in desired manner
    if "$pretty_print"; then
        echo "$response" | (eval "$formatter")
    else
        echo "$response"
    fi
done
