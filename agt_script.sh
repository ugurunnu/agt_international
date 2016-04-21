#!/bin/bash

###############################################################
#                                                             #
#     Automated AWS instance creator for AGT INTERNATIONAL    #
#                                                             #
###############################################################
# Usage :                                                     #
# Run agt_script.sh with following parameters;                #
# 1-Region                                                    #
# 2-VPC Cidr Block                                            #
# 3-Subnet cidr block                                         #
# 4-Subnet availability zone                                  #
# 5-security group name                                       #
# 6-security group ingress port to permit                     #
# 7-key name                                                  #
# 8-instance image ID                                         #
# 9-instance type                                             #
#                                                             #
# Example:                                                    #
#                                                             #
# agt_script.sh <parameter1> ... <parameter9>                 #
#                                                             #
# agt_script.sh eu-central-1 10.0.0.0/16 10.0.1.0/24 eu-centra#
# l-1b agt-sg 22 agt-key ami-87564feb t2.micro                #
#                                                             #
# requirements:                                               #
# HDD file is required for disk utilization                   #
# file should be as follows;                                  #
# [                                                           #
# {                                                           #
#   "DeviceName": "/dev/sdh",                                 #
#   "Ebs": {                                                  #
#     "VolumeSize": 10                                        #
#   }                                                         #
# }                                                           #
# ]                                                           #
#                                                             #
# file location shall be set with parameter :                 #
# HDD_FILE=                                                   #
# example :                                                   #
# HDD_FILE="~/hdd.json"                                       # 
###############################################################

REGION=$1
VPC_IP=$2
SUBNET_IP=$3
SUBNET_AZ=$4
SEC_GROUP_NAME=$5
SEC_PORT=$6
KEY_NAME=$7
AMI_ID=$8
INSTANCE_TYPE=$9

if [ -z $9 ]; then

echo "There is an error with the provided parameters please enter parameters one by one."
echo "Please enter Region (default = eu-central-1)"
read REGION
if [ -z $REGION]; then 
REGION="eu-central-1"
fi
echo "Please enter VPC IP Range (default = 10.0.0.0/16)"
read VPC_IP
if [ -z $VPC_IP]; then 
VPC_IP="10.0.0.0/16"
fi
echo "Please enter Subnet IP Range (default = 10.0.1.0/24)"
read SUBNET_IP
if [ -z $SUBNET_IP]; then 
SUBNET_IP="10.0.1.0/24"
fi
echo "Please enter Subnet Availability Zone (default = eu-central-1b)"
read SUBNET_AZ
if [ -z $SUBNET_AZ]; then 
SUBNET_AZ="eu-central-1b"
fi
echo "Please enter Security Group Name (default = agt-sg)"
read SEC_GROUP_NAME
if [ -z $SEC_GROUP_NAME]; then 
SEC_GROUP_NAME="agt-sg"
fi
echo "Please enter ingress Port number to permit (default = 22)"
read SEC_PORT
if [ -z $SEC_PORT]; then 
SEC_PORT="22"
fi
echo "Please enter Security Key name (default = agt-key)"
read KEY_NAME
if [ -z $KEY_NAME]; then 
KEY_NAME="agt-key"
fi
echo "Please enter Ami ID (default = ami-87564feb)"
read AMI_ID
if [ -z $AMI_ID]; then 
AMI_ID="ami-87564feb"
fi
echo "Please enter Instance type (default = t2.micro)"
read INSTANCE_TYPE
if [ -z $INSTANCE_TYPE]; then 
INSTANCE_TYPE="t2.micro"
fi
fi

HDD_FILE="~/hdd.json"
VPC_IPRANGE=""
VPC_ID=""
SUBNET_ID=""
SEC_GRP_ID=""
INSTANCE_ID=""
INSTANCE_IP=""

# 1 - Create VPC in specified region

VPC_ID=`aws ec2 create-vpc --cidr-block $VPC_IP --region $REGION | awk '{print $6}'`
echo " VPC with the ID $VPC_ID and IP Range $VPC_IP have been created!"


# 2 - Create subnet to the new created VPC

SUBNET_ID=`aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block $SUBNET_IP --availability-zone $SUBNET_AZ | awk '{print $6}'`
echo " Subnet with the ID $SUBNET_ID and IP Range $SUBNET_IP have been created!"


# 3 - Create security group

SEC_GRP_ID=`aws ec2 create-security-group --group-name $SEC_GROUP_NAME --description "agt_test" --vpc-id $VPC_ID`
echo " Security group with the ID $SEC_GRP_ID have been created!"

# 4 - Configure security group

aws ec2 authorize-security-group-ingress --group-id $SEC_GRP_ID --protocol tcp --port $SEC_PORT --cidr 0.0.0.0/0
echo " Access granted for port $SEC_PORT!"

# 5 - Create an instance 

aws ec2 create-key-pair --key-name $KEY_NAME --query 'KeyMaterial' --output text > /tmp/$KEY_NAME.pem
chmod 400 /tmp/$KEY_NAME.pem

echo "Key with key name $KEY_NAME have been created!"

if [ -e $HDD_FILE ]; then
INSTANCE_IP=`aws ec2 run-instances --image-id $AMI_ID --count 1 --instance-type $INSTANCE_TYPE --key-name $KEY_NAME --security-group-ids $SEC_GRP_ID --subnet-id $SUBNET_ID --block-device-mappings file://$HDD_FILE --associate-public-ip-address | grep "NETWORKINTERFACES" | awk '{print $5}'`
else 
INSTANCE_IP=`aws ec2 run-instances --image-id $AMI_ID --count 1 --instance-type $INSTANCE_TYPE --key-name $KEY_NAME --security-group-ids $SEC_GRP_ID --subnet-id $SUBNET_ID --associate-public-ip-address | grep "NETWORKINTERFACES" | awk '{print $5}'`
fi 

echo " Instance created!! IP address for connection is ; $INSTANCE_IP"
