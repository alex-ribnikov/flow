#!/bin/sh

# Initialize variables with default values (optional)
CPU_VALUE=""
MEMORY_VALUE=""
LABEL_VALUE=""

# --- Argument Parsing Loop ---
# This loop iterates through the arguments, processes known flags,
# and removes them from the argument list for further processing if needed.

# Use 'set -- "$@"' to rebuild the argument list without processed args if you need to
# process the remaining arguments later. If not, this step can be simplified.

args_to_pass=() # Array to store arguments that are NOT consumed by our script

while [ "$#" -gt 0 ]; do
  case "$1" in
    -CPU)
      if [ -n "$2" ]; then # Check if the next argument exists for the value
        CPU_VALUE="$2"
        shift # Consume -CPU
        shift # Consume <number>
      else
        echo "Error: -CPU requires a value." >&2
        exit 1
      fi
      ;;
    -MEMORY)
      if [ -n "$2" ]; then
        MEMORY_VALUE="$2"
        shift # Consume -MEMORY
        shift # Consume <number>
      else
        echo "Error: -MEMORY requires a value." >&2
        exit 1
      fi
      ;;
    -LABEL)
      if [ -n "$2" ]; then
        LABEL_VALUE="$2"
        shift # Consume -LABEL
        shift # Consume <text>
      else
        echo "Error: -LABEL requires a value." >&2
        exit 1
      fi
      ;;
    --) # End of options marker
      shift
      args_to_pass+=("$@") # Add all remaining arguments to our list
      break
      ;;
    -*) # Unknown option
      echo "Warning: Unknown option '$1'. Ignoring." >&2
      shift # Consume the unknown option
      ;;
    *) # Positional argument or something else not starting with '-'
      args_to_pass+=("$1") # Add to the list of arguments to pass on
      shift # Consume the argument
      ;;
  esac
done

# --- Now you have your variables set ---
echo "CPU Value: $CPU_VALUE" > argv
echo "Memory Value: $MEMORY_VALUE" >> argv
echo "Label Value: $LABEL_VALUE" >> argv
echo "Remaining arguments to potentially pass on:" >> argv
for arg in "${args_to_pass[@]}"; do
  echo "- $arg" >> argv
done

# --- Example of using the variables and passing remaining args ---
# You can now use $CPU_VALUE, $MEMORY_VALUE, $LABEL_VALUE in your script.
# For instance, if you were building a Kubernetes manifest:
#
# if [ -n "$CPU_VALUE" ]; then
#   echo "Setting CPU limit to $CPU_VALUE"
#   # kubectl set resources deployment my-app --limits=cpu=$CPU_VALUE
# fi
#
# if [ -n "$MEMORY_VALUE" ]; then
#   echo "Setting Memory limit to $MEMORY_VALUE"
#   # kubectl set resources deployment my-app --limits=memory=$MEMORY_VALUE
# fi
#
# if [ -n "$LABEL_VALUE" ]; then
#   echo "Applying label: my-label=$LABEL_VALUE"
#   # kubectl label deployment my-app my-label="$LABEL_VALUE"
# fi

# If you had other commands that needed the '(...)' part of your original command,
# you would pass "${args_to_pass[@]}" to them.
# Example: my_other_command "${args_to_pass[@]}"

envlist="$(printenv | grep -E '^CDPL|^FM|^FLEXLM_|^SYNOPSYS|^LM')"

envs=""

 
for env in $envlist

do
echo 
  env=${env//=/ }

  envs="${envs}setenv ${env}; "

done

echo "Running '${envs} $@'" > mytest.log
echo "/tools/common/bin/nextk8s run  -queue-name backend -cpu ${CPU_VALUE} -memory ${MEMORY_VALUE} -desc ${CDPL_WORKERID} -label ${LABEL_VALUE} -command "${envs} ${args_to_pass}"" > mytest.log
/tools/common/bin/nextk8s run  -queue-name backend -cpu ${CPU_VALUE} -memory ${MEMORY_VALUE} -desc ${CDPL_WORKERID} -label ${LABEL_VALUE} -command "${envs} ${args_to_pass}"

#env -i csh -c "${envs} $@"

