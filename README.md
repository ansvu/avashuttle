# What is shuttle?
sshuttle allows you to create a VPN connection from your machine to any remote server that you can connect to via ssh, as long as that server has python 3.6 or higher.


# what is avashuttle?
avashuttle is using sshuttle to wrap with golang and shellscript to answer auto-password and open tunnel on diff terminal per subnet. Simple function, not sure if it is helpful to others. But it does a job for me.

## Requirements
- sshuttle tool must install
  https://github.com/sshuttle/sshuttle
  
- avashuttle.sh must run on root only due go script not wanted to answer password twice e.g. sudo and your password might expose.

## Usage
```diff
+ bash avashuttle.sh --rhost root@172.27.17.56 --subnets "172.27.0.0/16,192.168.0.0/16" --password 100yard-
[2022-01-07 17:23:29]: INFO: The following file ./avashuttle is existed
[2022-01-07 17:23:29]: INFO: The following file /bin/sshuttle is existed
[2022-01-07 17:23:29]: INFO: Your Operating System Type: Linux
[2022-01-07 17:23:29]: INFO: Checking/Set avashuttle and avashuttle.sh scripts permission
[2022-01-07 17:23:29]: INFO: Start the tunnel for following source subnet: 172.27.0.0/16
[2022-01-07 17:23:29]: INFO: Start the tunnel for following source subnet: 192.168.0.0/16



