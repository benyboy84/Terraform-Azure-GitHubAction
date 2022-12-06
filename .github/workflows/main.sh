#!/bin/bash

# Eliminate `-recursive` option for Terraform 0.11.x.
fmtRecursive="-recursive"
tfVersion=$(terraform -version)
if [[ ${tfVersion} == *"0.11."* ]]; then
  fmtRecursive=""
fi

# Gather the output of `terraform fmt`.
echo "Terraform Format | INFO  | Checking if Terraform files in $GITHUB_REPOSITORY are correctly formatted"
fmtOutput=$(terraform fmt -check=true -write=false -diff ${fmtRecursive} ${*} 2>&1)
fmtExitCode=${?}

echo "fmtExitCode=${fmtExitCode}" >> $GITHUB_OUTPUT
echo "fmtOutput=${fmtOutput}" >> $GITHUB_OUTPUT

# Exit code of 0 indicates success. Print the output and exit.
if [ ${fmtExitCode} -eq 0 ]; then
echo "Terraform Format | INFO  | Terraform files in $GITHUB_REPOSITORY are correctly formatted"
echo "${fmtOutput}"
echo
exit ${fmtExitCode}
fi

# Exit code of 2 indicates a parse error. Print the output and exit.
if [ ${fmtExitCode} -eq 2 ]; then
echo "Terraform Format | Error | Failed to parse Terraform files"
echo "${fmtOutput}"
echo
exit ${fmtExitCode}
fi

# Exit code of !0 and !2 indicates failure.
echo "Terraform Format | Error | Terraform files in $GITHUB_REPOSITORY are incorrectly formatted"
echo "${fmtOutput}"
echo
echo "Terraform Format | Error | The following files in $GITHUB_REPOSITORY are incorrectly formatted"
fmtFileList=$(terraform fmt -check=true -write=false -list ${fmtRecursive})
echo "${fmtFileList}"
echo



exit ${fmtExitCode}