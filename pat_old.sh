#!/usr/bin/bash
# This is a script that runs all curl requests in the subdirectory
#   and checks that the response is what is expected

# TODO: Configure application-define constructs like `?force_refresh=true` as a CLI option

usage=$(cat << EOF
Pat: An HTTP API testing tool

Usage: $0 COMMAND [OPTIONS]
It runs all curl requests in the same directory.
Supported options:
    * -s: Save response as reference if no reference found
    * -f: Filepath to run requests from
    * -a: Arguments to curl
    * -p: Whether to display curl request progress
    * -v: Verbose mode
    * -h: Help
EOF
)

# Parse options
save_if_absent=false
filepath=`pwd`
curl_args=""
curl_progress=false
verbose=false
while getopts hsf:a:pv opt; do
    case $opt in
        h) echo "$usage"; exit ;;
        s) save_if_absent=true ;;
        f) filepath=${OPTARG};;
        a) curl_args=${OPTARG};;
        p) curl_progress=true;;
        v) verbose=true;;
        :) echo "Missing argument for option -$OPTARG"; echo "$usage"; exit 1;;
       \?) echo "Unknown option -$OPTARG"; echo "$usage"; exit 1;;
    esac
done
if ! "$curl_progress"; then
    curl_args+="-s"
fi
# Remove the parsed options from the positional params
shift $(( OPTIND - 1 ))

# COLORS
RED='\033[0;31m'
NC='\033[0m' # No Color
GREEN='\033[0;32m'
YELLOW='\033[1;33m'

failed=false
# List all shell files in the subdir
if $verbose; then
    echo "Filepath: $filepath"
fi
requests=(`find "$filepath" -type f -name "*.sh" -and -not -name "$0"`)
for request in "${requests[@]}"
do
    # echo "Running Request: $request"
    request_spec=`cat $request`
    curl_cmd="curl ${curl_args} ${request_spec}"
    if $verbose; then
        echo "Curl args: $curl_args"
        echo "Curl Command:"
        echo "$curl_cmd"
    fi
    response=$(eval "$curl_cmd")
    ref_file="${request::-3}.ref"
    if [ -f "$ref_file" ]; then
         expected=`cat $ref_file`
        if [[ "$expected" == "$response" ]]; then
            echo -e "$request ${GREEN}PASS${NC}"
        else
            failed=true
            echo -e "$request ${RED}FAIL${NC}; Diff:"
            diff --color $ref_file <(echo "$response" | jq .)
        fi
    else
        echo -e "$request ${YELLOW}RUN${NC}"
        echo "WARN: ref file doesn't exist"
        if $save_if_absent; then
            echo "saving response to file"
            echo "$response" | jq . > $ref_file
        else
            echo "Use -s option to save to file"
        fi
    fi
    if $verbose; then
        echo "Response:"
        echo "$response" | jq .
    fi
done

if $failed; then
    exit 1
fi
