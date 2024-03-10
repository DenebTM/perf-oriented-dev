#!/usr/bin/env bash

# configure timing command
time_cmd="/usr/bin/env time"
time_output="/tmp/$$_envtime"
time_args="-f %e -o $time_output -q"

# available command-line arguments
arg_nruns=5
arg_quiet=false
arg_jsonout=

# parse command-line arguments
while [[ $# -gt 0 ]]; do
    arg="$1"
    case "$arg" in
        -n|--nruns)
            shift
            arg_nruns=$1
            
            # validate argument given for -n|--nruns
            case $arg_nruns in
                ''|*[!0-9]*)
                    >&2 echo "$0: bad value for $arg; must be a positive integer."
                    exit 2
                    ;;
            esac
            ;;
        -q|--quiet)
            arg_quiet=true
            ;;
        -o|--output)
            shift
            arg_jsonout=$1
            ;;
        --)
            shift
            break
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS] COMMAND"
            echo
            echo "Available options:"
            echo "  -q, --quiet         suppress output of benchmarked command"
            echo "  -n, --nruns COUNT   number of benchmark passes to run (default 5)"
            echo "  -o, --output FILE   write JSON benchmark results to file instead of stdout"
            exit 0
            ;;
        -*)
            >&2 echo "$0: unrecognized option '$arg'; see --help for more information."
            exit 1
            ;;
        *)
            break
            ;;
    esac
    shift
done

if [[ -z "$@" ]]; then
    >&2 echo "Missing command to benchmark; see --help for more information"
    exit 3
fi

>&2 echo
# gather benchmark results
runtimes=()
for run in $(seq 1 1 $arg_nruns); do
    >&2 echo "Run $run / $arg_nruns"
    >&2 echo "====================="

if [[ $arg_quiet == true ]]; then
    $time_cmd $time_args "$@" >/dev/null 2>&1
else
    >&2 $time_cmd $time_args "$@"
    >&2 echo "---------------------"
fi
    
    read runtime < "$time_output"
    >&2 echo "Runtime: $runtime s"
    
    runtimes+=($runtime)
    
    >&2 echo
done
rm -f "$time_output"

runtimes_count=${#runtimes[@]}
runtimes_sum=$(IFS="+"; bc -l <<< "${runtimes[*]}")
runtimes_mean=$(bc -l <<< "$runtimes_sum / $runtimes_count")

# compute variance as <sum of deviations from the mean> / <nruns>
sos=0
for runtime in "${runtimes[@]}"; do
    sqdev=$(bc -l <<< "($runtime - $runtimes_mean)^2")
    sos=$(bc -l <<< "$sos + $sqdev")
done
runtimes_variance=$(bc -l <<< "$sos / $runtimes_count")

# prettify results
runtimes_mean=$(printf "%.3f" $runtimes_mean)
runtimes_variance=$(printf "%.3f" $runtimes_variance)

>&2 echo "Mean:     $(printf "%7s" $runtimes_mean) s"
>&2 echo "Variance: $(printf "%7s" $runtimes_variance) s"
>&2 echo

# direct json output either to stdout or a specified file
if [[ ! -z "$arg_jsonout" ]] && [[ "$arg_jsonout" != "-" ]]; then
    exec 3<> "$arg_jsonout"
else
    exec 3>&1
fi

# produce json output
(
    echo -n "{"
    echo -n "\"cmdline\":"
        quoted_cmdline=()
        for arg in "$@"; do
            case "$arg" in
                # TODO: fix literal quotes
                *\ *)
                    quoted_cmdline+=("\\\"$arg\\\"")
                    ;;
                *)
                    quoted_cmdline+=("$arg")
                    ;;
            esac
        done
        echo -n "\"${quoted_cmdline[@]}\","
    echo -n "\"quiet\":$arg_quiet,"
    echo -n "\"nruns\":$arg_nruns,"
    echo -n "\"runs\":["
        echo -n $(IFS=","; echo "${runtimes[*]}")
    echo -n "],"
    echo -n "\"mean\":$runtimes_mean,"
    echo -n "\"variance\":$runtimes_variance"
    echo "}"
) >&3
