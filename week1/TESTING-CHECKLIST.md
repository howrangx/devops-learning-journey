DEVOPS DASHBOARD TESTING CHECKLIST
Week 1 Capstone Project Verification

PRE-TESTING
[_] Script file exists and is executable
[_] chmod 755 has been applied
[_] No syntax errors (bash -n script)
[_] Script starts without errors

MENU TESTING
[_] Main menu displays correctly
[_] Menu options are numbered 1-9
[_] Invalid input handled gracefully
[_] Menu redisplays after each action
[_] Exit option (9) closes cleanly

OPTION 1: SYSTEM INFORMATION
[_] Displays hostname correctly
[_] Shows kernel version
[_] Displays OS information
[_] Shows CPU core count
[_] Shows CPU model name
[_] Displays memory information
[_] Shows disk space summary
[_] Returns to menu after viewing

OPTION 2: SYSTEM MONITORING
[_] Shows load average
[_] Displays memory usage percentage
[_] Shows disk usage percentage
[_] Lists top 5 CPU processes
[_] Lists top 5 memory processes
[_] Shows listening ports count
[_] Shows established connections count
[_] Returns to menu after viewing

OPTION 3: PROCESS MANAGEMENT
[_] Prompts for process name
[_] Shows all processes if blank entry
[_] Searches for specific process
[_] Displays process details correctly
[_] Handles non-existent process
[_] Returns to menu after viewing

OPTION 4: FILE MANAGEMENT
[_] Shows current directory
[_] Prompts for navigation
[_] Changes directory successfully
[_] Lists files with details
[_] Shows permissions correctly
[_] Shows first 15 files (no overflow)
[_] Handles invalid directory gracefully
[_] Returns to menu after viewing

OPTION 5: LOG ANALYSIS
[_] Finds system log file
[_] Counts total lines
[_] Counts error entries
[_] Counts warning entries
[_] Shows last 10 log entries
[_] Displays log file path
[_] Handles missing log file
[_] Returns to menu after viewing

OPTION 6: HEALTH CHECK
[_] Displays load average
[_] Shows memory percentage
[_] Shows disk percentage
[_] Detects memory warnings (>80%)
[_] Detects disk warnings (>80%)
[_] Counts warnings correctly
[_] Shows overall health status
[_] Returns to menu after viewing

OPTION 7: GENERATE REPORT
[_] Creates report file
[_] Uses timestamped filename
[_] Saves to ~/devops-reports/
[_] Includes system information
[_] Includes resource information
[_] Includes top processes
[_] Shows report preview
[_] Confirms file location
[_] Returns to menu after viewing

OPTION 8: VIEW LOGS
[_] Displays log file location
[_] Shows recent actions (last 20)
[_] Logs are formatted correctly
[_] Timestamps are accurate
[_] All actions are logged
[_] Returns to menu after viewing

OPTION 9: EXIT
[_] Displays exit message
[_] Shows log file location
[_] Shows reports directory
[_] Closes cleanly
[_] Returns to shell prompt
[_] No errors on exit

LOGGING VERIFICATION
[_] ~/.devops-dashboard/ directory created
[_] Dashboard log file created
[_] All actions logged with timestamps
[_] Correct action descriptions
[_] Proper timestamp format

REPORTING VERIFICATION
[_] ~/devops-reports/ directory created
[_] Report file created with timestamp
[_] Report contains system info
[_] Report contains resources
[_] Report contains processes
[_] Report is readable
[_] Report is properly formatted

ERROR HANDLING
[_] Invalid menu options handled
[_] Non-existent files handled
[_] Missing directories handled
[_] Permission errors handled
[_] Empty search results handled
[_] No bash errors displayed
[_] Graceful degradation

FUNCTIONALITY INTEGRATION
[_] All Week 1 concepts used
[_] Functions properly structured
[_] Error handling throughout
[_] Variables used correctly
[_] Conditionals work properly
[_] Loops function correctly
[_] Text processing works
[_] Process monitoring works

DOCUMENTATION
[_] Script has header comments
[_] Functions documented
[_] Configuration variables explained
[_] Usage instructions clear
[_] Features listed
[_] Examples provided
[_] Troubleshooting included

CLEANUP AND GIT
[_] No temporary files left
[_] Script is clean
[_] Documentation is complete
[_] All changes staged
[_] Commit message clear
[_] Push to GitHub successful

TOTAL CHECKS PASSED: ____ / 90+

NOTES AND OBSERVATIONS:

