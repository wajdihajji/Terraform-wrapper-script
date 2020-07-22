#!/usr/bin/env bash
#
# Wrapper script to run terraform command on multiple folders.
# 
# The script populates and copies the templates "provider.tpl", "pg_backend.tpl",
# "variables.tpl" to the terraform directories, then it runs the terraform
# command passed as arguments and finally clean up those directories
# by deleting the initially copied files.
#
# The env variables in the templates should be defined before running the script.

# Exit on error
set -e

# Get the directory of this script
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

# Get Terraform directories
TERRAFORM_DIRS="$(find . -not -path '*/\.*' -type f -name '*.tf' | sed -r 's|/[^/]+$||' | sort | uniq)"

# Get template files
TPL_FILES="$(ls *.tpl)"

# Description: show help message
usage() {
cat << EOF
usage: $0 options

A simple wrapper script that runs terraform commands on multiple folders.

OPTIONS:
-h                                  Show this help message
-d dir                              Optional. The dir in which to run the terraform command.
                                    Equivalent to [dir] Terraform option. If not specified, run
                                    the Terraform commands on all the sub-directories.
-c commands                         The terraform commands to run

E.g.
Run terraform plan in ./examples/test: $0 -d ./examples/test -c plan
Run terraform init on all the folders containing .tf files: $0 -c plan

EOF
}

# Description: update and copy template files to a terraform module directory
# Args: dir
create_config_files() {
    # Copy template files to terraform directory. Overwrite exising files if exist
    for tpl_file in $TPL_FILES
    do
        tf_file="generated.$(echo $tpl_file | cut -f 1 -d '.').tf"
        cp "$tpl_file" "$1/$tf_file"
        envsubst < $1/$tf_file | tee $1/$tf_file > /dev/null

        # Particular customisation for pg_backend.tpl
        if [[ "$tf_file" == "generated.pg_backend.tf" ]];then
            # Infer pg_schema from dir path. Example: ./path/to/foo --> path_to_foo
            pg_schema=$(echo $dir | sed 's/\.\///g; s/\//_/g; s/\-/_/g')
            sed -i "s/TF_SCHEMA/$pg_schema/g" "$1/$tf_file"
        fi
    done
}

# Description: run terraform command in a directory
# Args: SELECTED_DIR
#       TF_CMDS
run_terraform() {
    create_config_files $1

    # Run the terraform command passed in argument
    printf "\n*** Run \"terraform $2\" in $1:\n\n"
    terraform $2 $1
}

# Parse the script args
while getopts "hd:c:" opt
do
  case $opt in
    h)
      usage
      exit
      ;;
    d)
      SELECTED_DIR=$OPTARG
     ;;
    c)
      TF_CMDS=$OPTARG
     ;;
    ?)
      usage
      exit
      ;;
  esac
done

# Check required arguments
if [ -z "$TF_CMDS" ]
then
   usage
   exit
fi

# Check if SELECTED_DIR is specified
if [ ! -z "$SELECTED_DIR" ]
then
    run_terraform $SELECTED_DIR $TF_CMDS
    exit 0
fi

for dir in $TERRAFORM_DIRS
do
    run_terraform $dir $TF_CMDS
done
