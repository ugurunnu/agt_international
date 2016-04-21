# agt_international
Bash script for the task that is requested by AGT International

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
