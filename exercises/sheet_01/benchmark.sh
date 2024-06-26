#!/usr/bin/env bash

# make C-c kill the whole script
quit() { exit 130; }
trap quit SIGINT
trap quit SIGTERM

stats_columns=("wall" "user" "system" "mem")
stats_units=("s" "s" "s" "kB")
print_stat() {
    local stat=($1)
    >&2 echo -n "  "
    for ((col=0; col<${#stat[@]}; col++)); do
        >&2 echo -n "${stats_columns[col]} ${stat[col]}${stats_units[col]}  "
    done
    >&2 echo
}

time_cmd="/usr/bin/env time"
time_output="/tmp/$$_envtime"

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

>&2 echo "cmdline: $@"
>&2 echo "============================================================"

# gather benchmark results
runtimes=()
for run in $(seq 1 1 $arg_nruns); do
    >&2 echo "Run $run / $arg_nruns"

if [[ $arg_quiet == true ]]; then
    $time_cmd -f '%e %U %S %M' -o $time_output -q "$@" >/dev/null 2>&1
else
    >&2 echo "------------------------------------------------------------"
    >&2 $time_cmd -f '%e %U %S %M' -o $time_output -q "$@"
    >&2 echo "------------------------------------------------------------"
fi

    read stat < "$time_output"
    stats+=("$stat")

    print_stat "${stat[*]}"
    >&2 echo
done
rm -f "$time_output"

# compute means per column as <sum of measurements> / <nruns>
# keep 3 decimal places
stats_means=($(printf '%s\n' "${stats[@]}" | \
    awk '{e+=$1; u+=$2; s+=$3; m+=$4}
        END{printf "%.3f %.3f %.3f %.3f", e/NR,u/NR,s/NR,m/NR}'))

# compute variances as <sum of deviations from the mean> / <nruns>
# keep 3 decimal places
stats_variances=($(printf '%s\n' "${stats[@]}" \
    | awk "{de=\$1 - ${stats_means[0]}; se+=de*de;
            du=\$2 - ${stats_means[1]}; su+=du*du;
            ds=\$3 - ${stats_means[2]}; ss+=ds*ds;
            dm=\$4 - ${stats_means[3]}; sm+=dm*dm}
        END{printf \"%.3f %.3f %.3f %.3f\",
                   se/(NR-1),su/(NR-1),ss/(NR-1),sm/(NR-1)}"))

>&2 echo "Means:"
>&2 print_stat "${stats_means[*]}"
>&2 echo "Variances:"
>&2 print_stat "${stats_variances[*]}"
>&2 echo

# direct json output either to stdout or a specified file
if [[ ! -z "$arg_jsonout" ]] && [[ "$arg_jsonout" != "-" ]]; then
    > "$arg_jsonout"
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
            # escape literal quotes in argument
            arg="$(sed 's/"/\\"/g' <<< "$arg")"
            # quote argument if it contains spaces
            case "$arg" in *\ *)
                arg="\\\"$arg\\\""
            esac
            quoted_cmdline+=("$arg")
        done
        echo -n "\"${quoted_cmdline[@]}\","
    echo -n "\"quiet\":$arg_quiet,"
    echo -n "\"nruns\":$arg_nruns,"

    echo -n "\"runs\":["
        runs_print=()
        for stat in "${stats[@]}"; do
            stat=($stat)
            run_print=()
            for ((col=0; col<${#stats_columns[@]}; col++)); do
                run_print+=("\"${stats_columns[col]}\":${stat[col]}")
            done
            runs_print+=("{$(IFS=","; echo "${run_print[*]}")}")
        done
        echo -n $(IFS=","; echo "${runs_print[*]}")
    echo -n "],"

    means_print=()
    variances_print=()
    for ((col=0; col<${#stats_columns[@]}; col++)); do
        means_print+=("\"${stats_columns[col]}\":${stats_means[col]}")
        variances_print+=("\"${stats_columns[col]}\":${stats_variances[col]}")
    done
    echo -n "\"mean\":{$(IFS=","; echo "${means_print[*]}")},"
    echo -n "\"variance\":{$(IFS=","; echo "${variances_print[*]}")}"

    echo -n "}"
) >&3
