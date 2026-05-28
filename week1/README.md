# Week 1: Linux Fundamentals & Command Line Mastery

## Overview

This week focuses on building a solid foundation in Linux system administration and command-line proficiency. These skills are essential for all subsequent DevOps work.

## Learning Objectives

By the end of this week, you will:
- Navigate Linux filesystem confidently
- Understand and manage file permissions
- Master text processing and searching (grep, awk, sed)
- Monitor and manage system processes
- Write functional bash scripts with variables, loops, and conditionals
- Create a reusable system administration dashboard

## Daily Breakdown

### Day 1: Linux Basics & System Navigation
- **Focus**: File system hierarchy, navigation commands, file operations
- **Deliverable**: `day1-commands.txt` - Command reference
- **Time**: 2-3 hours

### Day 2: File Permissions & User Management
- **Focus**: Understanding Linux permission system, user/group management
- **Deliverable**: `day2-permissions.md` - Permission reference with examples
- **Time**: 2-3 hours

### Day 3: Text Processing & Searching
- **Focus**: grep, find, awk, sed, pipes and redirection
- **Deliverable**: `log-analyzer.sh` - Functional log analysis script
- **Time**: 3-4 hours

### Day 4: Process Management & System Monitoring
- **Focus**: Process control, system resource monitoring, top/htop
- **Deliverable**: `system_monitor.sh` - Real-time system monitoring script
- **Time**: 2-3 hours

### Day 5: Bash Scripting Fundamentals
- **Focus**: Variables, conditionals, loops, functions, error handling
- **Deliverable**: `backup_script.sh` and `deployment_checker.sh`
- **Time**: 3-4 hours

### Weekend: Capstone Project
- **Focus**: Integrate all week's learning
- **Deliverable**: `devops_dashboard.sh` - Comprehensive system admin tool
- **Time**: 4-6 hours

## Resources

### Free Learning Platforms
- [Linux Journey](https://linuxjourney.com/) - Interactive lessons
- [OverTheWire: Bandit](https://overthewire.org/wargames/bandit/) - Gamified learning
- [Bash Scripting Guide](https://www.shellscript.sh/) - Comprehensive reference
- [ExplainShell](https://explainshell.com/) - Command explanation tool

### Man Pages (Built-in Help)
```bash
man ls          # Get help for any command
man -k keyword  # Search man pages by keyword
```

## Folder Structure

week1/
├── README.md                    # This file
├── scripts/                     # Bash scripts
│   ├── log-analyzer.sh
│   ├── system_monitor.sh
│   ├── backup_script.sh
│   ├── deployment_checker.sh
│   └── devops_dashboard.sh
├── notes/                       # Learning notes
│   ├── day1-commands.txt
│   └── day2-permissions.md
├── logs/                        # Output logs (generated during execution)
└── configs/                     # Configuration files (if needed)

## Getting Started

### Prerequisites
- Linux environment (WSL2, Virtual Machine, or EC2)
- Bash shell
- Text editor (nano, vim, or VS Code)
- Internet connection for resources

### Setup Your Environment
```bash
# Verify you're in the week1 directory
cd week1

# Create subdirectories if not already done
mkdir -p scripts notes logs configs

# Verify structure
ls -la
```

## Success Criteria

You're ready to move to Week 2 when you can:
- [ ] Navigate filesystem without `ls -la` crutches
- [ ] Understand and apply file permissions correctly
- [ ] Use grep/find/awk for text processing
- [ ] Monitor system resources with various tools
- [ ] Write bash scripts with proper error handling
- [ ] Complete the devops_dashboard.sh project with 80%+ functionality
- [ ] Push all code to GitHub with clean commits

## Self-Assessment Checklist

### Linux Basics & Navigation
- [ ] Can navigate to any directory using absolute/relative paths
- [ ] Know the Linux filesystem hierarchy
- [ ] Can create, copy, move, delete files and directories
- [ ] Understand hidden files and dot notation

### Permissions & Users
- [ ] Can read permission strings (rwxrwxrwx)
- [ ] Can convert between numeric and symbolic permissions
- [ ] Know when to use chmod and chown
- [ ] Understand default permissions

### Text Processing
- [ ] Can use grep effectively for pattern matching
- [ ] Can use find to locate files
- [ ] Can write basic awk and sed commands
- [ ] Understand pipes and output redirection

### Processes & Monitoring
- [ ] Can view running processes with ps and top
- [ ] Can kill and manage processes
- [ ] Can monitor CPU, memory, and disk usage
- [ ] Understand load averages

### Bash Scripting
- [ ] Can write scripts with variables and conditionals
- [ ] Can use for/while loops
- [ ] Can define and call functions
- [ ] Can handle errors with exit codes
- [ ] Can read input from users and files

## Bonus Challenges

- [ ] Set up bash aliases for frequently used commands
- [ ] Create a cron job to run system_monitor.sh daily
- [ ] Add color output to your scripts
- [ ] Create an HTML report generator
- [ ] Implement email notifications for alerts

## Notes

- Practice typing commands instead of copy-pasting
- Use `man` pages as your friend
- Break things and learn from errors
- Document your learning as you go
- Push to Git regularly with meaningful commit messages

---

**Status**: In Progress
**Last Updated**: May 2026
