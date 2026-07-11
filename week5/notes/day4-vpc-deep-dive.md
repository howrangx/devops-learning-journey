# Day 4: VPC Deep Dive

## VPC Recap

A VPC is an isolated virtual network within AWS, with resources like
EC2 instances launched inside it. Every AWS account gets a Default
VPC per region, pre-configured and ready to use, as explored on Day 1.

## Subnets

A subnet is a subdivision of the VPC's IP address range (CIDR block),
and is tied to exactly one Availability Zone.

Key concepts:
- Each subnet gets its own smaller CIDR block, carved out of the
  VPC's overall range (e.g. VPC is 172.31.0.0/16, a subnet inside it
  might be 172.31.0.0/20)
- Public Subnet: has a route to an Internet Gateway, so instances in
  it can be reached from (and reach) the internet, assuming security
  groups allow it
- Private Subnet: has no direct route to the internet, used for
  resources that should never be directly internet-facing, such as
  databases
- AWS reserves 5 IP addresses in every subnet for internal use
  (network address, VPC router, DNS, future use, and broadcast
  address), which reduces the usable address count

## Route Tables

A route table defines where network traffic from a subnet is
directed, based on destination IP ranges.

Key concepts:
- Every subnet is associated with exactly one route table (though one
  route table can be shared across multiple subnets)
- The default route for local VPC traffic (e.g. 172.31.0.0/16 ->
  local) is automatically present and cannot be removed
- A route to 0.0.0.0/0 (meaning "anywhere else") pointing at an
  Internet Gateway is what actually makes a subnet "public" -
  without this route, the subnet is private regardless of anything
  else

## Internet Gateway (IGW)

A horizontally scaled, redundant component attached to a VPC that
allows communication between resources in the VPC and the internet.
A VPC can have at most one Internet Gateway attached at a time. The
Default VPC already has one attached automatically.

## Security Groups Revisited

Covered briefly on Day 1 and used again on Day 2, but worth
formalizing:

- Security groups are stateful: if inbound traffic is allowed, the
  corresponding outbound response traffic is automatically allowed
  too, without needing a matching outbound rule
- Security groups are attached to individual instances (technically,
  to network interfaces), not to subnets
- Only "allow" rules exist; there is no way to explicitly "deny" in a
  security group, only omit a rule to implicitly block it
- Multiple security groups can be attached to a single instance, and
  their rules are combined (union of all allowed traffic)

## Network ACLs (brief mention)

A different, subnet-level firewall layer, separate from security
groups. Unlike security groups, Network ACLs are stateless (inbound
and outbound rules must both be defined explicitly) and support
explicit deny rules. The Default VPC's default Network ACL allows all
traffic, so security groups have been doing all the actual filtering
work so far this week.

## Key Takeaways

- Subnets subdivide a VPC's address range and are each tied to a
  single Availability Zone
- A subnet is "public" only if its route table sends 0.0.0.0/0
  traffic to an Internet Gateway
- Security groups are stateful and instance-level; Network ACLs are
  stateless and subnet-level
- The Default VPC comes pre-configured with public subnets, an
  Internet Gateway, and permissive Network ACLs, which is why
  everything has worked so far without extra networking setup
