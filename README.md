# Wrapper script
`tf.sh` is a wrapper script that runs Terraform commands on *all* the folders containing `.tf` files.

The script updates the template files `*.tpl` with environment variables and copies them to the Terraform module directories. Then, it runs the Terraform command passed as arguments. 

Help message of `tf.sh`:
```bash
$ ./tf.sh -h
usage: ./tf.sh options

A simple wrapper script that runs terraform commands on multiple folders.

OPTIONS:
-h                                  Show this help message
-d dir                              Optional. The dir in which to run the terraform command.
                                    Equivalent to [dir] Terraform option. If not specified, run
                                    the Terraform commands on all the sub-directories.
-c commands                         The terraform commands to run

E.g.
Run terraform plan in ./examples/test: ./tf.sh -d ./examples/test -c plan
Run terraform init on all the folders containing .tf files: ./tf.sh -c plan

```

Note: only pg backend is supported in this script. You can add more templates for other backends though. PRs are welcome.
