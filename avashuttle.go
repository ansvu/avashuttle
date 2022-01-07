package main

import (
	"fmt"
	"os"
	"strings"

	//"log"
	"flag"

	"github.com/Yaqdata/gexpect"
)

func main() {
	//var list SrcSubnet
	//flag.Var(&list, "subnets", "list of source subnets")
	var (
		rhost    = flag.String("rhost", "", "Eg. root@192.168.250.56")
		subnets  = flag.String("subnets", "", "Eg. 192.168.205.0/24/24 192.168.206.0/24/24 or all traffic 0/0")
		password = flag.String("password", "Test123-", "your user password")
		version  = flag.Bool("version", false, "Version of this tool ")
		help     = flag.Bool("help", false, "to print help. Example, ./avashuttle --rhost root@192.168.250.56 --subnets 172.27.0.0/16 --password Test123-")
	)
	flag.Parse()
	switch {
	case *version:
		fmt.Println("0.0.1")
		os.Exit(0)
	case *help:
		flag.PrintDefaults()
		return
	case *subnets == "":
		fmt.Println("You missed the --subnets the source subnet, e.g 192.168.206.0/24 or 192.168.205.0/24/24,192.168.206.0/24/24")
		os.Exit(0)
	case *rhost == "":
		fmt.Println("--rhost is destination IP address is required! E.g --rhost root@172.27.17.56")
		os.Exit(0)
	}
	fmt.Printf("Welcome to JumpHost Sshuttle Tunnel!!\n")
	SpawnSshuttle(*rhost, *subnets, *password)

}
func SpawnSshuttle(rhost, subnet, password string) error {
	child, err := gexpect.Spawn(fmt.Sprintf("sshuttle -e 'ssh -q -o CheckHostIP=no -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null' --dns -r %s %s", rhost, subnet))
	if err != nil {
		panic(err)
	}
	child.Expect("assword:")
	child.SendLine(password)
	child.Interact()
	fmt.Printf("Successfully Disconected from sourceSubnet: %s and rhost: %s\n", subnet, rhost)
	return nil
}

//gnome-terminal --tab --title="Sshuttle Tunnel Child1" --command="bash -c 'pwd; $SHELL'"
//gnome-terminal --tab --title=Sshuttle --command="bash -c 'sshuttle --dns -r root@172.27.17.56 192.167.20.0/24; $SHELL'"
//sshuttle -r kubo@10.92.21.17 30.0.0.0/16 192.168.111.0/24 192.168.150.0/24 192.167.0.0/24
// SrcSubnet is string slice
type SrcSubnet []string

func (ss *SrcSubnet) String() string {
	return fmt.Sprintln(*ss)
}

// Set string value in SrcSubnet
func (ss *SrcSubnet) Set(s string) error {
	*ss = strings.Split(s, ",")
	return nil
}
