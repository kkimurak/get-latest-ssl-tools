#!/bin/sh

set -Ceu

print_usage() {
    echo $1
    cat <<- USAGE
    This script will download latest release of tool that you specified.
    Only support linux_amd64

    usage
    $ $(basename $0) [OPTION | TARGET]

    - OPTION
    available options are:
    - -h / --help
        show this help
    - -a / --all
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

if [ "$#" -lt 1 ]; then
    print_usage "Argment is too many or less"
fi

TARGET_TOOL_NAME=""

if [ "$#" -ge 2 ]; then
  for arg in "$@"; do
    env sh $0 "$arg"
    echo
  done
  exit 0
fi

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
    | "-a" )
        printf "Downlaod all supported tools\n\n"
        env sh $0 gc vc
        exit 0
        ;;
    *)
        print_usage "Unexpected argment : $1"
        ;;
esac

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

TARGET_PLATFORM="";
case "$(uname -s)" in
    "Linux")
        TARGET_PLATFORM="linux_amd64"
        ;;
    "Darwin")
        TARGET_PLATFORM="darwin_amd64"
        ;;
    *)
        echo "This system is not supported"
        exit 1
        ;;
esac

TARGET_FILE_URL="$(curl -Ss https://api.github.com/repos/${TARGET_TOOL_NAME}/releases | jq -r --arg TARGET_PLATFORM "${TARGET_PLATFORM}" '.[0].assets[] | select(.name | test($TARGET_PLATFORM)) | .browser_download_url')"
TARGET_TOOL_VERSION="$(basename ${TARGET_FILE_URL} | cut -d '_' -f 2)"
cat << TARGET_INFO
Download latest release of ${TARGET_TOOL_NAME}
version is  : ${TARGET_TOOL_VERSION}
platform is : linux_amd64
TARGET_INFO

TARGET_FILE_NAME="$(basename "${TARGET_FILE_URL}")"
FOUND_LIST="$(find ~/ -name "${TARGET_FILE_NAME}" 2>/dev/null)" && true
if [ ! "${FOUND_LIST}" = "" ]; then
    echo "already exist on system. found at:"
    echo "${FOUND_LIST}"
    exit 0
fi

trap 'rm -f "${TARGET_FILE_NAME}"; echo ;echo "Process killed. deleted downloading file $(basename ${TARGET_FILE_URL})";' 2
wget -q --show-progress "${TARGET_FILE_URL}"
chmod +x "${TARGET_FILE_NAME}"