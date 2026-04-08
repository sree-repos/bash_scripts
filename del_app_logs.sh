#!/bin/bash
### cp this sccript to : /usr/local/sbin/del_app_logs  [or]  /usr/sbin/del_app_logs
### to execute this script as Linux command from any path in a host

if [ "$(id -u)" -ne 0 ]; then
    echo -e "This script requires ROOT or SUDO permission \n"
    exit 1
fi

dir1="/app/pega/logs/"
dir2="/app/pega/logs/"
dir3="/app/pega/work/Catalina/localhost/prweb/"
dir4="/"

usage () {
    echo -e "\nUsage: $0 [-l] [-d]"
    echo -e "  -l   Lists   *.gz Pega log files, catalina.out [&] prweb contents"
    echo -e "  -d   Deletes *.gz Pega log files, catalina.out [&] prweb contents\n"
    exit 1
}

list_func () {

    echo -e "Proceeding to LIST Pega log files" ; printf -- '-%.0s' {1..33}; echo -e " "
    if [ "$(ls -1 "$1" | grep .gz | wc -l)" -eq 0 ]; then
        cd "$1" && echo "Current Directory: $(pwd)" && echo -e "*.gz : No such file found \n"
    elif [ "$(ls -1 "$1" | grep .gz | wc -l)" -ge 1 ]; then
        cd "$1" && echo "Current Directory: $(pwd)" && ls -l "$1" | grep .gz | head -n 5 && echo -e "more... \n"
    fi

    if [ "$(ls -1 "$2" | grep catalina.out | wc -l)" -eq 0 ]; then
        cd "$2" && echo "Current Directory: $(pwd)" && echo -e "catalina.out : No such file found \n"
    elif [ "$(ls -1 "$2" | grep catalina.out | wc -l)" -ge 1 ]; then
        cd "$2" && echo "Current Directory: $(pwd)" && ls -l "$2" | grep catalina.out | head -n 5 && echo -e "more... \n"
    fi

    if [ "$(ls -1 "$3" | wc -l)" -eq 0 ]; then
        cd "$3" && echo "Current Directory: $(pwd)" && echo -e "No files or directories found \n"
    elif [ "$(ls -1 "$3" | wc -l)" -ge 1 ]; then
        cd "$3" && echo "Current Directory: $(pwd)" && ls -l "$3" | head -n 5 && echo -e "more... \n"
    fi

    if [ "$(ls -1 "$4" | grep .gz | wc -l)" -eq 0 ]; then
        cd "$4" && echo "Current Directory: $(pwd)" && echo -e "*.gz : No such file found \n"
    elif [ "$(ls -1 "$4" | grep .gz | wc -l)" -ge 1 ]; then
        cd "$4" && echo "Current Directory: $(pwd)" && ls -l "$4" | grep .gz | head -n 5 && echo -e "more... \n"
    fi
}

del_func () {

    echo -e "Proceeding to DELETE Pega log files" ; printf -- '-%.0s' {1..35}; echo -e " "
    if [ "$(ls -1 "$1" | grep .gz | wc -l)" -eq 0 ]; then
        cd "$1" && echo "Current Directory: $(pwd)" && echo -e "*.gz : No such file found \n"
    elif [ "$(ls -1 "$1" | grep .gz | wc -l)" -ge 1 ]; then
        cd "$1" && echo "Current Directory: $(pwd)" && ls -l "$1" | grep .gz | head -n 5 && echo -e "more..."
        rm -rf "$1"*.gz && echo -e "(above listed *.gz files are deleted) \n"
    fi

    if [ "$(ls -1 "$2" | grep catalina.out | wc -l)" -eq 0 ]; then
        cd "$2" && echo "Current Directory: $(pwd)" && echo -e "catalina.out : No such file found \n"
    elif [ "$(ls -1 "$2" | grep catalina.out | wc -l)" -ge 1 ]; then
        cd "$2" && echo "Current Directory: $(pwd)" && ls -l "$2" | grep catalina.out | head -n 5 && echo -e "more..."
        rm -rf "$2"catalina.out && echo -e "(catalina.out file was deleted) \n"
    fi

    if [ "$(ls -1 "$3" | wc -l)" -eq 0 ]; then
        cd "$3" && echo "Current Directory: $(pwd)" && echo -e "No files or directories found \n"
    elif [ "$(ls -1 "$3" | wc -l)" -ge 1 ]; then
        cd "$3" && echo "Current Directory: $(pwd)" && ls -l "$3" | head -n 5 && echo -e "more..."
        rm -rf "$3"* && echo -e "(above listed files are deleted) \n"
    fi

    if [ "$(ls -1 "$4" | grep .gz | wc -l)" -eq 0 ]; then
        cd "$4" && echo "Current Directory: $(pwd)" && echo -e "*.gz : No such file found \n"
    elif [ "$(ls -1 "$4" | grep .gz | wc -l)" -ge 1 ]; then
        cd "$4" && echo "Current Directory: $(pwd)" && ls -l "$4" | grep .gz | head -n 5 && echo -e "more..."
        rm -f "$4"*.gz && echo -e "(above listed *.gz files are deleted) \n"
    fi
}

while getopts "ld" OPTION; do
    case "$OPTION" in
        l) list_func $dir1 $dir2 $dir3 $dir4 ;;
        d) del_func $dir1 $dir2 $dir3 $dir4 ;;
        *) usage ;;
    esac
done

if [ $OPTIND -eq 1 ]; then
    usage
fi
