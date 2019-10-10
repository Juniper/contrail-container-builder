#!/bin/bash

declare -A params_default
declare -A params_indirect
declare -A params_module
declare -A params_containers
declare -A params_conf_vars

# Read all PARAMS.md files
for file in $(find . -name PARAMS.md); do
    while read -r line; do
        words=($line)
        # Skip empty lines
        if [ -z ${words[0]} ]; then
            continue
        # Take container name from header
        elif [ ${words[0]} == "#" ]; then
            container=${words[1]}
        # Parse table line
        elif [ ${words[0]} == "|" ]; then
            param=${words[1]}
            # Skip headers and grids
            if [[ $param == -* ]] || [[ $param == parameter ]] || [[ $param == parameters ]]; then
                continue
            # Get module's name
            elif [[ $param == \*\** ]]; then
                module=${param//\*/}
                continue
            # Check if parameter is direct or indirect
            elif [[ $param == \** ]]; then
                indirect=True
            else
                indirect=False
            fi
            # Get param's name
            param=${param//[$\*]/}
            # Get default value
            default=${words[3]}
            default=${default//|/}
            # If parameter is already present, add container to the list of containers
            if [ -v params_default[$param] ]; then
                params_containers[$param]="${params_containers[$param]}, ${container}"
            # Otherwise fill in all values
            else
                params_indirect[$param]=$indirect
                params_default[$param]=$default
                params_module[$param]=$module
                params_containers[$param]=$container
            fi
        fi
    done <"$file"
done

# Grep for usage of parameters and produce output
for param in ${!params_default[@]}; do
    # Fetch config variables into which params are set if applicable
    # Remove non-config assignments which usually are assingment to itself
    # In order to filter this out we'll check for upper-case vars assignment
    # But some parameters are not uppercase and these won't be filtered out
    if [ ${param^^} == $param ]; then
        exclude=$param
    else
        exclude="no exclude"
    fi
    IFS=":=" conf_vars=($(grep -r $param * | grep entrypoint.sh | grep = | grep -v "export " | grep -v "$exclude=" | grep -v "$exclude ="))
    params_conf_vars[$param]=${conf_vars[1]}

    # Write line for parameter
    echo "$param; ${params_indirect[$param]}; ${params_default[$param]}; ${params_module[$param]}; ${params_conf_vars[$param]}; ${params_containers[$param]}"
done
