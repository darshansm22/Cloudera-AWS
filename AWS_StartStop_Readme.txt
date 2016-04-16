AWS_InstanceStartStop.sh
Script to stop and start AWS EC2 Instances using AWS CLI commands. This script can be used to automate stop and start of AWS EC2 instances. The script would not terminate the AWS instances.

Command: AWS_InstanceStartStop.sh <command (start/stop) projectcode - optional parameter (default value "")>
eg - AWS_InstanceStartStop.sh start testproj

Prerequisites: The user executing the script should have the following.
1) AWS CLI installed in the local machine executing the script.
2) Setup AWS CLI environment variables in ~/.aws directory - If not include those in the script.
3) The user executing should be able to run AWS CLI executable "aws".
4) Write access to the Present Working Directory ($PWD).
5) Choose one of the options for executing the script as listed below.
  5a) Predefined aws_instances.txt file (list of AWS instances to be started/stopped) is present in $PWD.
  5b) Pass the Project-Code as a parameter which would be used to identify the instances through tags.
Dependency: aws_instances.txt file if option 5a is chosen.

If option 5a is chosen, all corresponding AWS Instances should be provided in aws_instances.txt -
The AWS Instance IDs should be separated by single space, " " in aws_instances.txt file.
#cat aws_instances.txt
i-5203422c i-3603753f

If option 5b is chosen, all corresponding AWS Instances should be tagged using the following -
Tag Name: "Project" and Tag Value: Same as the project code passed as parameter (case-sensitive).