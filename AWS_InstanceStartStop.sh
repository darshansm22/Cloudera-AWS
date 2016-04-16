#!/bin/bash
#=======================================================================================================================
# Script name   : AWS_InstanceStartStop.sh
# Date Created  : 04/10/2016
# Author        : Kiran Anand
# Description   : Script to Start/Stop AWS instances
# OS            : Linux (Red Hat)
# Shell         : Bash
# Command       : AWS_InstanceStartStop.sh <command (start/stop) projectcode - optional parameter (default value "")>
# Prerequisites : The user executing the script should have the following.
#			1) AWS CLI installed in the local machine executing the script.
#			2) Setup AWS CLI environment variables in ~/.aws directory - If not include those in the script.
#			3) The user executing should be able to run AWS CLI executable "aws".
#			4) Write access to the Present Working Directory ($PWD).
#			5) Choose one of the options for executing the script as listed below.
#			5a) Predefined aws_instances.txt file (list of AWS instances to be started/stopped) is present in $PWD.
#			5b) Pass the Project-Code as a parameter which would be used to identify the instances through tags.
# Dependency    : aws_instances.txt file if option 5a is chosen.
# Other Remarks : Necessary comments are provided in the script inline.
#
# 				  If option 5a is chosen, all corresponding AWS Instances should be provided in aws_instances.txt -
#				  The AWS Instance IDs should be separated by single space, " " in aws_instances.txt file.
#
# 				  If option 5b is chosen, all corresponding AWS Instances should be tagged using the following -
# 				  Tag Name: "Project" and Tag Value: Same as the project code passed as parameter (case-sensitive).
#----------------------------------------------------------------------------------------------------------------------
# Change log:
#
#    Date       Updated by      Ver.    Description
#  ----------  -------------  -------  --------------------------------------------------------------------------------
#  04-10-2016  Kiran Anand      1.0     Initial write
#
#=======================================================================================================================

### Set AWS environment variables - If these are not set in the AWS CLI or want to use a different access id
##export AWS_ACCESS_KEY_ID = 
##export AWS_SECRET_ACCESS_KEY =
##export AWS_DEFAULT_REGION = 

### Function to display usage
function display_usage
{
	echo "Usage: AWS_InstanceStartStop.sh <command (start/stop) projectcode (optional parameter)>"
}

### Initialize arguments passed
if [ $# -ge 1 ]; then
	cmd=$1
fi

logfile=$PWD/AWS_Instance${cmd}.log
rm -f $PWD/AWS_Instance${cmd}.log

### Get the project code which is used to tag the instances. Instances should be tagged using the following
### Tag Name: "Project" and Tag Value: Same as the project code passed above (case-sensitive)
if [ $# -eq 1 ]; then
	prjcode=""
	echo "No Project Code passed in" >> ${logfile}
	echo "Expecting the list of AWS instances to be provided in $PWD" >> ${logfile}
elif [ $# -eq 2 ]; then
	prjcode=$2
	echo "Project Code passed in -> ${prjcode}" >> ${logfile}
	echo "Searching AWS instances using the Tag Name: Project and Tag Value: ${prjcode}" >> ${logfile}
	aws ec2 describe-instances --filters Name=tag:Project,Values=${prjcode} | grep InstanceId | awk -F '"' '{print $4}' > tmp_aws_instances.txt
	cat tmp_aws_instances.txt | tr '\n' ' ' > aws_instances.txt
	rm -f tmp_aws_instances.txt
else
	echo "Wrong number of arguments passed..!" >> ${logfile}
	display_usage >> ${logfile}
	exit 1
fi

### Check if the AWS Instance list is present, if not exit 
file=$PWD/aws_instances.txt

if [ ! -f ${file} ]; then
	echo "List of AWS instances not found - ${file}" >> ${logfile}
	exit 1
fi

### Execute the Start/Stop Commands on AWS Instances using AWS CLI commands
for instids in `cat ${file}`
do
	if [ ${cmd} == start ]; then
		echo "Starting AWS instances - ${instids}" >> ${logfile}
		aws ec2 start-instances --instance-ids ${instids}
	elif [ ${cmd} == stop ]; then
		echo "Stopping AWS instances - ${instids}" >> ${logfile}
	 	aws ec2 stop-instances --instance-ids ${instids}
	else
		echo "Wrong command passed - ${cmd}" >> ${logfile}
		display_usage >> ${logfile}
		exit 1
	fi
done

exit
