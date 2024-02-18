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
    * -S: Save the response of a request to corresponding file.
        The response is saved to the same filepath with the same filename
        with the extension .ref.
    * -t: Test mode. Compares the response of the request with the reference
        file. A test is considered to have passed if the response matches the
        one in the reference file. Otherwise, the test fails and displays the
        diff of the two responses.
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
save_if_absent=false
test_mode=false
while getopts f:hpsSt opt; do
    case $opt in
        h) echo "$usage"; exit;;
        p) pretty_print=true;;
        s) scroll_mode=true;;
        S) save_if_absent=true;;
        t) test_mode=true;;
        :) echo "Missing argument for option -$OPTARG"; echo "$usage"; exit 1;;
       \?) echo "Unknown option -$OPTARG"; echo "$usage"; exit 1;;
    esac
done

# Unset flags if commands not available
formatter_exists=$(which "${formatter%% *}")
if [ "$pretty_print" = true ] && [ -z "$formatter_exists" ] ; then
    echo "Specified pretty printer \`$formatter\` not found; Skipping pretty printing..."
    pretty_print=false
fi
scroller_exists=$(which "${scroller%% *}")
if [ "$scroll_mode" = true ] && [ -z "$scroller_exists" ] ; then
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
    failed=false
    if [ "$curl_exit_code" != 0 ]; then
        echo -e "$request ${RED}FAIL${NC}; Reason:"
        echo "Curl encountered an error: "
        echo "$response"
        failed=true
        continue
    fi


    ref_file="${request::-6}.ref"
    query_file="${request::-6}.query"
    query="jq ."
    if [ -f "$query_file" ]; then
        query=$(cat "$query_file")
    fi

    formatted_resp=$(echo "$response" | eval "$query")
    if [ "$test_mode" = true ] && [ -f "$ref_file" ]; then
        expected=$(cat "$ref_file")
        if [[ "$expected" == "$formatted_resp" ]]; then
            echo -e "$request ${GREEN}PASS${NC}"
        else
            failed=true
            echo -e "$request ${RED}FAIL${NC}; Diff:"
            diff --color $ref_file <(echo "$formatted_resp")
        fi
    elif [ "$test_mode" = true ]; then
        echo -e "$request ${YELLOW}RUN${NC}"
        echo "WARN: ref file doesn't exist"
        if $save_if_absent; then
            echo "$response" | (eval "$formatter") > $ref_file
            echo "Saved response to file"
        else
            echo "Use -S option to save to file"
        fi
    else
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

        if [ ! -f "$ref_file" ] && [ "$save_if_absent" = true  ]; then
            echo "$response" | (eval "$formatter") > $ref_file
            echo "Saved response to file"
        fi
    fi

done

exit $exit_code
