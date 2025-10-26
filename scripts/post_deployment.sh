#!/bin/bash
set -o pipefail

echo "Running post-deployment maintenance tasks..."

if sleep 5s && \
    php maintenance/run.php update --quick && \
    php maintenance/run.php runJobs; 
then
    echo -e "\n"
    echo "#############################################################"
    echo "# Post-deployment maintenance tasks completed successfully. #"
    echo "#############################################################"
    exit 0
else
    echo -e "\n"
    echo "#############################################################"
    echo "#     ERROR: Post-deployment maintenance tasks failed.      #"
    echo "#############################################################"
    exit 1
fi
