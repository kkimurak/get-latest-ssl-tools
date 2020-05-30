# get-latest-ssl-tools

This is simple shell script to download latest release of tool for RoboCup Small Size League.  

Supported OS are listed below (additionally POSIX shell also required)

- linux_amd64

## usage

```sh
$ get_latest_ssl_tools.sh [OPTION | TARGET]
```

### OPTION

available options are:

- -h / --help  
show this help
- -a / --all  
download all of supported TARGET

### TARGET

available tools are:

- [robocup-ssl/ssl-game-controller](https://github.com/robocup-ssl/ssl-game-controller)  
    aliases : ssl-game-controller, game-controller, gc
- [robocup-ssl/ssl-vision-client](https://github.com/robocup-ssl/ssl-vision-client)  
    aliases : ssl-vision-client, vision-client, vc

## example usage

```sh
$ ./get_latest_ssl_tools.sh robocup-ssl/ssl-vision-client
$ ./get_latest_ssl_tools.sh gc
```

## dependency

This script depends on those tools

- cat (with here-document support)
- chmod
- echo
- find
- jq
- rm
- wget or curl
