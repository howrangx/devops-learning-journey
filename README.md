# DevOps and Cloud Learning Journey

A structured 16-week program taking Linux fundamentals through to
production-ready DevOps practice, worked end to end and documented as it
was built.

This repository is the record of that work. Every week folder contains the
notes written while learning the material, the scripts and configuration
produced, and a log of what was actually run and what broke along the way.
The commit history is the timeline; the folders are the evidence.

## How to read this repository

Each week is self-contained. Start with the week folder's own `README.md`
for its objectives, deliverables and status, then:

- `notes/` - daily reference documents, and a hands-on log per day
  recording the commands actually executed, the output they returned, and
  the mistakes made and corrected
- `scripts/` - working tools produced that week
- `configs/` - configuration and policy documents
- `logs/` - generated output, where a week produces any

The per-week READMEs are the authoritative status for each week. This file
deliberately does not track progress, so that it never contradicts the
repository it describes.

## Curriculum

**Phase 1 - Foundations**

- Week 1: Linux fundamentals and the command line
- Week 2: Networking and Git
- Week 3: Python for DevOps
- Week 4: Docker fundamentals

**Phase 2 - Cloud platforms**

- Week 5: AWS fundamentals, part 1 (EC2, S3, VPC)
- Week 6: AWS fundamentals, part 2 (IAM, RDS, load balancing, auto scaling)
- Week 7: AWS advanced services (Lambda, CloudWatch, SNS/SQS)
- Week 8: Multi-cloud overview

**Phase 3 - Infrastructure as code**

- Week 9: Terraform fundamentals
- Week 10: Advanced IaC and configuration management with Ansible

**Phase 4 - CI/CD and orchestration**

- Week 11: CI/CD with GitHub Actions
- Week 12: Jenkins and advanced pipelines
- Week 13: Kubernetes fundamentals

**Phase 5 - Operations, security and portfolio**

- Week 14: Monitoring and logging (Prometheus, Grafana, ELK)
- Week 15: DevSecOps - scanning, secrets management, least privilege
- Week 16: Capstone project and portfolio

## Selected work

A sample of what the week folders contain, rather than a complete index.

**System administration dashboard** (`week1/scripts/devops_dashboard.sh`)
An interactive bash tool for system monitoring and reporting, with menu
navigation, health thresholds, timestamped report generation and activity
logging. Supported by a log analyzer, a backup tool and a deployment
readiness checker.

**Team Git standards system** (`week2/`)
A complete collaboration framework: branching strategy, commit and code
review standards, branch protection rules, PR and issue templates, a new
developer onboarding guide, and a troubleshooting reference covering the
failure modes people actually hit.

**DevOps toolkit** (`week3/`, containerized in `week4/`)
`devops_toolkit.py`, a multi-command CLI built with argparse, logging,
subprocess and requests, exposing health, logs, ping and report
subcommands. Later packaged into a container image with a Dockerfile and
Compose stack.

**AWS infrastructure work** (`week5/`, `week6/`)
Provisioning done through the AWS CLI rather than the console, so that
every step is reproducible and reviewable: EC2 with user data and IMDSv2,
S3 policies and lifecycle rules, VPC subnets and routing, boto3
automation, and hand-written least-privilege IAM policies and roles.

## Conventions

These hold across every week.

**Documentation**
Plain ASCII markdown. No emoji, no decorative characters. Section dividers
use equals signs, lists use hyphens. Commands are given with their
expected output so a reader can tell whether their own run matched.

**Commits**
Conventional commits, for example `docs(week6): add day1 IAM deep dive
notes` or `feat(week4-day3): add Dockerfile and containerized status app`.
Notes are committed before the hands-on work begins; produced artifacts
are committed after, and only the files actually produced are staged.

**Structure**
Every week uses the same four subdirectories, so anything is findable
without reading a map.

**Security**
Account identifiers, key material, security group IDs and public addresses
are kept out of committed documentation. Credentials are never pasted into
notes or logs. Cloud resources are torn down in the session that creates
them, and each day's notes end with the teardown commands used.

## Technologies

Linux, Bash, Git, Python, Docker, AWS (EC2, S3, VPC, IAM, RDS, ELB,
CloudWatch), Terraform, Ansible, Jenkins, GitHub Actions, Kubernetes,
Prometheus, Grafana, ELK.

## License

MIT. See `LICENSE`.
