#!/bin/sh

set -Ceu

print_usage() {
    echo "$0"
    cat <<- USAGE
    This script will download latest release of tool that you specified.
    Only support linux_amd64

    usage
    $ $(basename $0) [OPTION | TARGET]

    - OPTION
    available options are:
    - -h / --help
        show this help
    - -a / --all / all
        download all of available tools
        if this command is passed, all other TARGET will be ignored     

    - TARGET
    available tools are:
    - robocup-ssl/ssl-game-controller
      aliases : ssl-game-controller, game-controller, gc
    - robocup-ssl/ssl-vision-client
      aliases : ssl-vision-client, vision-client, vc

    example
    $ $(basename $0) robocup-ssl/ssl-vision-client
    $ $(basename $0) gc
USAGE

    exit 1
}

TARGET_TOOL_NAME=""

# support multiple target in argments : split argment and run script itself for each
if [ "$#" -ge 2 ]; then
    for arg in "$@"; do
        env sh $0 "$arg"
        echo
    done
    exit 0
fi

if [ "$#" -eq 0 ]; then
    print_usage
    exit 0
fi

# process argment
case "$1" in
    "-h" \
    | "--help" )
        print_usage
        ;;
    "robocup-ssl/ssl-game-controller" \
    | "ssl-game-controller" \
    | "game-controller" \
    | "gc")
        TARGET_TOOL_NAME="robocup-ssl/ssl-game-controller"
        ;;
    "robocup-ssl/ssl-vision-client" \
    | "ssl-vision-client" \
    | "vision-client" \
    | "vc" \
    )
        TARGET_TOOL_NAME="robocup-ssl/ssl-vision-client"
        ;;
    "--all" \
    | "-a" \
    | "all" \
    )
        printf "Downlaod all supported tools\n\n"
        env sh "$0" gc vc
        exit 0
        ;;
    *)
        print_usage "Unexpected argment : $1"
        ;;
esac

# check architecture
case "$(uname -m)" in
    "amd64"\
    | "x86_64")
        echo "System architecture is $(uname -m) : supported"
        ;;
    *)
        echo "This system is not seems to be 64bit so not supported"
        exit 1
        ;;
esac

# check OS
TARGET_PLATFORM="";
case "$(uname -s)" in
    "Linux")
        TARGET_PLATFORM="linux_amd64"
        ;;
    "Darwin")
        TARGET_PLATFORM="darwin_amd64"
        ;;
    *)
        if [ "${OS}" = "Windows_NT" ]; then
            TARGET_PLATFORM="windows_amd64"
        else
            echo "This system is not supported"
            exit 1
        fi
        ;;
esac

# set up target and its URL, then display it
TARGET_FILE_URL="$(curl -Ss https://api.github.com/repos/${TARGET_TOOL_NAME}/releases | jq -r --arg TARGET_PLATFORM "${TARGET_PLATFORM}" '.[0].assets[] | select(.name | test($TARGET_PLATFORM)) | .browser_download_url')"
TARGET_TOOL_VERSION="$(basename ${TARGET_FILE_URL} | cut -d '_' -f 2)"
cat << TARGET_INFO
Download latest release of ${TARGET_TOOL_NAME}
version is  : ${TARGET_TOOL_VERSION}
platform is : ${TARGET_PLATFORM}
TARGET_INFO

# find existing binary to avoid duplicate
TARGET_FILE_NAME="$(basename "${TARGET_FILE_URL}")"
EXACT_MATCH_LIST="$(find ~/ -name "${TARGET_FILE_NAME}" 2>/dev/null)" && true
if [ ! "${EXACT_MATCH_LIST}" = "" ]; then
    echo "already exist on system. found at:"
    echo "${EXACT_MATCH_LIST}"
    exit 0
fi

# find older version and ask to delete before downloading latest one
EXEC_NAME_SIMPLIFIED="$(echo "${TARGET_FILE_NAME}" | cut -d "_" -f 1)"
OLDER_LIST="$(find ~/ -executable -type f -name "${EXEC_NAME_SIMPLIFIED}*")"
for older_file in ${OLDER_LIST}; do
    printf "Older version of target found:\n"
    du -h "${older_file}"
    printf "Do you want to remove it?\nThis will run 'rm' command, so cannot be undone. [y/N] "
    read -r Y_N
    case "$(echo "${Y_N}" | tr "[:upper:]" "[:lower:]")" in
        "y" | "yes")
            rm "${older_file}" && printf "successfully removed.\n\n"
            ;;
        *)
            printf "skipped...\n\n"
            ;;
    esac
done

# setup handler to delete temporal file
trap 'rm -f "${TARGET_FILE_NAME}"; echo ;echo "Process killed. deleted downloading file $(basename ${TARGET_FILE_URL})";' 2

# start downloading and make it executable
wget -q --show-progress "${TARGET_FILE_URL}"
chmod +x "${TARGET_FILE_NAME}"
