#  Batch
## Description:  
 Creates a POC AWS Batch environment, includes IAM resources, S3, Lambda, and Batch.
## Parameters
Parameter|Description|Type|DefaultValue
----|----|----|----
Release|Release Identifier|String|*no default*
CloudToolsBucket|S3 Bucket where CFN and Lambda archives are stored.|String
Environment|Environment Name|String|*no default*
QueueName|Name of Queue to be created|String|*no default*
VPCCidr|Cidr Block of the VPC, allows for ssh access internally.|String|*no default*
VPC|VPC ID to boot compute into|AWS::EC2::VPC::Id
Subnets|List of Subnets to boot into|List<AWS::EC2::Subnet::Id>
AMI|AMI to use for Compute Environment|AWS::EC2::Image::Id|*no default*
Ec2KeyPair|Ec2KeyPair to use for Compute Environment|AWS::EC2::KeyPair::KeyName
StartImageName|Name and tag of Start Container Image|String|*no default*
ProcessImageName|Name and tag of Process Container Image|String|*no default*


## Resources
Resource|Type
----|----
LambdaTriggerIAMRole|AWS::IAM::Role
BatchContainerIAMRole|AWS::IAM::Role
BatchServiceRole|AWS::IAM::Role
BatchInstanceIAMRole|AWS::IAM::Role
BatchInstanceProfile|AWS::IAM::InstanceProfile
TriggerFunction|AWS::Lambda::Function
S3LambdaEvent|AWS::Lambda::Permission
TriggeredBucket|AWS::S3::Bucket
BatchSecGroup|AWS::EC2::SecurityGroup
BatchCompute|AWS::Batch::ComputeEnvironment
Queue|AWS::Batch::JobQueue
StartJob|AWS::Batch::JobDefinition
ProcessJob|AWS::Batch::JobDefinition

