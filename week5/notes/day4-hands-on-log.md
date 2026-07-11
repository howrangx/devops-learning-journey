# Day 4: Hands-On Log

## Session Summary

Explored the structure of the default VPC via CLI, confirming the
subnet layout, route table entries, and Internet Gateway attachment
that make the VPC's subnets public.

## Resources Explored (no new resources created)

### VPC
- VPC ID: vpc-0b4efe0812f9e7c1b
- CIDR Block: 172.31.0.0/16

### Subnets (six total, one per Availability Zone)
- subnet-052b99125e9a5177c - us-east-1a - 172.31.0.0/20
- subnet-07ac6e53815f66ca9 - us-east-1c - 172.31.16.0/20
- subnet-0b2a9ecfbc0723f4e - us-east-1d - 172.31.32.0/20
- subnet-0082dfdfd2e97c2c9 - us-east-1e - 172.31.48.0/20
- subnet-0a749f86aa62a36bf - us-east-1f - 172.31.64.0/20
- subnet-00753ce1c36d5fe0f - us-east-1b - 172.31.80.0/20

All six have MapPublicIpOnLaunch set to true, meaning any instance
launched into them automatically receives a public IP address.

### Route Table
- Local route: 172.31.0.0/16 -> local (automatic, present in every
  VPC, cannot be removed)
- Internet route: 0.0.0.0/0 -> igw-003f38206b4e63640

This second route is what makes all six subnets public: any traffic
not destined for another address inside the VPC is sent to the
Internet Gateway.

### Internet Gateway
- Internet Gateway ID: igw-003f38206b4e63640
- State: available, attached to the VPC

## Commands Used

List subnets in the VPC:
aws ec2 describe-subnets \
  --filters "Name=vpc-id,Values=<vpc-id>" \
  --query "Subnets[].[SubnetId,AvailabilityZone,CidrBlock,MapPublicIpOnLaunch]" \
  --output table

Inspect route table entries:
aws ec2 describe-route-tables \
  --filters "Name=vpc-id,Values=<vpc-id>" \
  --query "RouteTables[].Routes[].[DestinationCidrBlock,GatewayId]" \
  --output table

Confirm Internet Gateway attachment:
aws ec2 describe-internet-gateways \
  --filters "Name=attachment.vpc-id,Values=<vpc-id>" \
  --query "InternetGateways[].[InternetGatewayId,Attachments[0].State]" \
  --output table

## Key Takeaways

- The default VPC spans all Availability Zones in the region, one
  subnet per AZ, for built-in redundancy
- A subnet is public specifically because its route table sends
  0.0.0.0/0 traffic to an Internet Gateway, not because of any
  setting on the subnet itself
- MapPublicIpOnLaunch is a separate subnet-level setting controlling
  whether instances automatically receive a public IP, distinct from
  the routing that makes that IP actually reachable
- The subnet used by EC2 instances on Day 1 and Day 2
  (subnet-052b99125e9a5177c, us-east-1a) was auto-selected by AWS
  since no subnet was explicitly specified at launch
