CDH_StartStop.sh 
Script to stop and start Cloudera CDH Hadoop Clusters using Rest APIs. This script can be used to automate stop and start of Cloudera hadoop clusters. 

Command: CDH_StartStop.sh <CM-Host-FQDN CM-Port Cluster-Name Command (start/stop) CM-Admin-Username CM-Admin-Password>
eg - CDHStartStop.sh cmhost.test.com testcluster start admin	admin

Prerequisites: The user executing the script should have the following.
1) Admin user rights on Cloudera Manager managing the CDH cluster
2) Python should be installed on the machine from which the script is executed.
3) The user executing should be able to run python CLI executable.
4) Write access to the Present Working Directory ($PWD).
