# ufw_log_parser
Uncomplicated Firewall log parser displays UFW events in an easy to view/understand output. 
It parses logs for the Timestamp, Blocked/Allowed status, Source MAC, Source IP, and Destination IP and Port.    

## ufw logging verbosity 
ufw has 4 levels of verbosity: low (default), medium, high, full 
Set ufw's verbosity: 
```Bash
sudo ufw logging medium
```


## Usage

Parse entire 'ufw.log' file:
```Bash
./ufw_log_parser.sh
```

Parse the last 30 entries in UFW log:
```Bash
./ufw_log_parser.sh | tail -n 30
```

Watch a running feed of UFW logs: 
```Bash
watch -n5 "./ufw_log_parser.sh | tail -n 30"
```

Example use cases:
* Validate proper vlan segmentation.
* Determining if a network route is open to a system. 
* Parse ufw logs while troubleshooting or performing incident response.  
* See when your system is being poked and scanned at the local ☕ coffee shop.
* Watch your Chrome cast, etc. constantly scanning your systems. 
* Hours of entertainment at IT/Security conferences. 

![alt text](https://github.com/ArronJablonowski/ufw_log_parser/blob/main/ufw_parser.png?raw=true)
