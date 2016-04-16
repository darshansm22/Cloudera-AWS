#!/bin/bash
#=======================================================================================================================
# Script name   : CDH_StartStop.sh
# Date Created  : 04/11/2016
# Author        : Kiran Anand
# Description   : Script to Start/Stop CDH Hadoop Cluster Services using CM REST APIs
# OS            : Linux (Red Hat)
# Shell         : Bash
# Command       : CDH_StartStop.sh <CM-Host-FQDN CM-Port Cluster-Name Command (start/stop) CM-Admin-Username CM-Admin-Password>
# Prerequisites : The user executing the script should have the following.
#			1) Admin user rights on Cloudera Manager managing the CDH cluster
#			2) Python should be installed on the machine from which the script is executed.
#			3) The user executing should be able to run python CLI executable.
#			4) Write access to the Present Working Directory ($PWD).
# Dependency    : None.
# Other Remarks : Necessary comments are provided in the script inline.
#
#----------------------------------------------------------------------------------------------------------------------
# Change log:
#
#    Date       Updated by      Ver.    Description
#  ----------  -------------  -------  --------------------------------------------------------------------------------
#  04-11-2016  Kiran Anand      1.0     Initial write
#
#=======================================================================================================================

### Declare the variables used within the script that might need editing for different versions
api_ver=v11

### Function to display usage
function display_usage
{
	echo "Usage: CDHStartStop.sh <CM-Host-FQDN CM-Port Cluster-Name Command (start/stop) CM-Admin-Username CM-Admin-Password>"
}

### Function to find the active command count in CM
function cm_active_cmd_count
{
	curl -su ${cmadmuser}:${cmadmpswd} -X GET "${prtcl}://${cmhost}:${cmport}/api/${api_ver}/clusters/${clustname}/commands" | python -c 'import json,sys;j=json.load(sys.stdin);print len(j["items"])'
}

### Function to wait for active commands in CM to finish
function wait_for_cm_active_cmd
{
	### Give a chance for the command to appear the in the active list
	sleep 20 
	while true; 
	do
		if [ "$(cm_active_cmd_count)" == 0 ]; then
			break
		fi
		sleep 5
	done
}

### Initialize arguments passed
if [ $# -ne 6 ]; then
	echo "Wrong number of arguments passed..!" >> ${logfile}
	display_usage >> ${logfile}
	exit 1
else
	cmhost=$1
	cmport=$2
	clustname=$3
	cmd=$4
	cmadmuser=$5
	cmadmpswd=$6
fi

logfile=$PWD/CDH${cmd}.log
rm -f $PWD/CDH${cmd}.log

### Check if the CM is up using the details provided above
val=$(curl --insecure -su ${cmadmuser}:${cmadmpswd} -X GET "http://${cmhost}:${cmport}/api/${api_ver}/tools/echoError?message=Ping" | grep -i ping | wc -l)
if [ ${val} == 1 ]; then
	echo "Communication with CM server tested successfully.." >> ${logfile}
	prtcl=http
else
	val=$(curl --insecure -su ${cmadmuser}:${cmadmpswd} -X GET "https://${cmhost}:${cmport}/api/${api_ver}/tools/echoError?message=Ping" | grep -i ping | wc -l)
	if [ ${val} == 1 ]; then
		echo "Communication with CM server tested successfully.." >> ${logfile}
		prtcl=https
	else
		echo "Not able to communicate with CM server..!" >> ${logfile}
		echo "Verify if proper arguments are provided." >> ${logfile}
		exit 1
	fi
fi

### Check if the provided cluster is managed by the CM
clust=$(curl -su ${cmadmuser}:${cmadmpswd} -X GET "${prtcl}://${cmhost}:${cmport}/api/${api_ver}/clusters" | python -c 'import json, sys; j=json.load(sys.stdin); print ",".join([i["name"] for i in j["items"]])')
if [ ${clust} == ${clustname} ]; then
	echo "Cluster - ${clustname} is managed by CM on ${cmhost}." >> ${logfile}
else
		echo "Not able find the cluster - ${clustname} on ${cmhost}..!" >> ${logfile}
		echo "Verify if proper arguments are provided." >> ${logfile}
		exit 1
fi

### Execute the Start/Stop Commands on CDH cluster and CM services using CM REST APIs
if [ ${cmd} == start ]; then
	echo "Starting CM services" >> ${logfile}
	curl --insecure -su ${cmadmuser}:${cmadmpswd} -X POST "${prtcl}://${cmhost}:${cmport}/api/${api_ver}/cm/service/commands/start" >> ${logfile}
	wait_for_cm_active_cmd
	echo "Starting CDH cluster - ${clustname}" >> ${logfile}
	curl --insecure -su ${cmadmuser}:${cmadmpswd} -X POST "${prtcl}://${cmhost}:${cmport}/api/${api_ver}/clusters/${clustname}/commands/start" >> ${logfile}
	wait_for_cm_active_cmd
elif [ ${cmd} == stop ]; then
	echo "Stopping CDH Cluster - ${clustname}" >> ${logfile}
	curl --insecure -su ${cmadmuser}:${cmadmpswd} -X POST "${prtcl}://${cmhost}:${cmport}/api/${api_ver}/clusters/${clustname}/commands/stop" >> ${logfile}
	wait_for_cm_active_cmd
	echo "Stopping CM services" >> ${logfile}
	curl --insecure -su ${cmadmuser}:${cmadmpswd} -X POST "${prtcl}://${cmhost}:${cmport}/api/${api_ver}/cm/service/commands/stop" >> ${logfile}
	wait_for_cm_active_cmd
else
	echo "Wrong command passed - ${cmd}" >> ${logfile}
	display_usage >> ${logfile}
	exit 1
fi

exit
