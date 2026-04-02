function log --description 'Execute command while logging to $LOG file and terminal'
    if not set -q LOG; or test -z "$LOG"
        echo "Error: LOG environment variable is not set" >&2
        return 1
    end

    if test (count $argv) -eq 0
        echo "The log file is currently set to $LOG."
        echo "Supply a command to log to the file."
        return 0
    end

    # make sure we own the file in case sudo is being used
    touch $LOG

    # Log the command being executed
    echo "\$ $argv" >>$LOG

    # Execute the command, piping output to both terminal and logfile
    $argv 2>&1 | tee -a $LOG
    return $pipestatus[1]
end

function logcp --description 'Execute command and copy output to clipboard'
    if test (count $argv) -eq 0
        echo "Supply a command to log to the clipboard."
        return 0
    end

    set -l output ($argv 2>&1)
    set -l exit_code $status

    printf "\$ %s\n%s\n" "$argv" "$output" | tee (wl-copy | psub)
    echo "Copied to clipboard"

    return $exit_code
end

function logcopy --description 'Copy log file to clipboard'
    if not set -q LOG; or test -z "$LOG"
        echo "Error: LOG environment variable is not set" >&2
        return 1
    end
    if not test -f "$LOG"
        echo "No log contents at $LOG"
        return 0
    end
    wl-copy <$LOG
    echo "copied "(wc -l <$LOG | string trim)" lines from $LOG to the clipboard"
end

function logclear --description 'Delete log file'
    if not set -q LOG; or test -z "$LOG"
        echo "Error: LOG environment variable is not set" >&2
        return 1
    end
    if not test -f "$LOG"
        echo "The file $LOG does not exist, there is nothing to delete."
        return 1
    end
    rm -f $LOG
    echo "removed $LOG"
end

function logname --description 'Show current log file path'
    if not set -q LOG; or test -z "$LOG"
        echo "Error: LOG environment variable is not set" >&2
        return 1
    end
    echo "Log name is $LOG"
end

function logset --description 'Set LOG variable to a file path'
    if test -z "$argv[1]"
        echo "Error: specify a name for the log file or a path to a log file." >&2
        echo "       - if a path is not specified, it will be placed in ~/logs." >&2
        echo "       - if a file extension is not specified, .log will be used." >&2
        return 1
    end

    set -l newlog
    # if path starts with . or /, treat as explicit path
    if string match -qr '^[./]' -- $argv[1]
        set newlog $argv[1]
    else
        mkdir -p $HOME/logs
        set newlog $HOME/logs/$argv[1]
    end

    # if no file extension then use .log
    if not string match -qr '\.[^./]+$' -- $newlog
        set newlog $newlog.log
    end

    if test -f "$newlog"
        echo "Warning: the file $newlog already exists."
        echo " It has "(wc -l <$newlog | string trim)" lines in it currently"
        echo " Use 'logclear' if you want it to start fresh."
    end

    set -gx LOG $newlog
    echo "set LOG to $LOG"
end
