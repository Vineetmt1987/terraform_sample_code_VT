# terraform_sample_code_VT
Terraform Sample code creation for AWS VPC

## Prerequisite to run Terraform codes 

- Must have an AWS account
- Linux Machine
- aws cli version 2 must be installed (aws 3 doesn't work with Terraform v12)
- Terraform v 12 must be installed


$ aws configure
AWS Access Key ID [****]:
AWS Secret Access Key [****]:
Default region name [us-west-1]: us-east-2
Default output format [None]:

## Terraform main Commands in use :

- tarraform init
- terraform plan
- terraform apply
- terraform destroy
- terrafrom --help
- terrafrom --version

aws cli verify version :

aws --version

## File reference :

- project.tf --> vpc and subnet for vpc private and pbulic both
- datasource.tf --> data avaiablity zone and route 53
- user.tfvars --> allowed cider blcoks with user's password
- variables.tf --> All used variables defined
- rds.tf --> Relational database and subnet for teh same 
- web.tf --> keypair, EC2 instance for web and autoscaling group
