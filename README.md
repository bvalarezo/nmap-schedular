# nmap-schedular
Schedule an nmap job

## Requirements
- nmap
- at
## FAQ
### How do I install `at(1)`
On apt

  # apt update && apt install at
  
After, you install `at(1)`, make sure you enable the `atd` daemon.

  # systemctl eable atd
  # systemctl start atd
