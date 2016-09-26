# vmware-vcli

Modified scripts from VMware SDK to support VCenter.

You need to add datacenter name on each command. If not known, use vifs with '-C' option.

Use --help for more information.

Concerning <path> format, can be:
* '[datastore] directory/file' like '[iSCSI DS] my_vm/my_vm.vmx'
* '/vmfs/volumes/iSCSI DS/my_vm/my_vm.vmx'

Known issue:
* don't work for some operation on ESXi free edition

## vifs

Needed parms:
* --server <host> : ESX or VCenter
* --dc <datacenter> : if host is VCenter

Operations:
* -C : list datacenters
* -S : list datastore
* -M <path> : create directory in datastore
* -r <path> : delete direcoty in datastore
* -D <path> [--detail] : list directory content, detail option display file type and physical/provisionned size for VmDisk
* -g <path> <local> : download a file
* -c <path> <path> : copy a file (same as Copy in Browse Datastore)

## vmkfstools

Needed parms:
* --url <url> : url to the ESX/VCenter like https://hostname/sdk/webService
* --vihost <host/ip> : if VCenter, hostname or ip of an ESX
* --datacenter <datacenter> : if VCenter

Operations:
* -c <size> <path> [-d <format>] : create a vmdk with size format numberUNIT with unit eq g,m,k
* -E <path> <path> : rename a VMDK OR move a VMDK (will keep thin provisionning)
* -i <path> <path> [-d <format>] : clone a VMDK (will keep thin provisionning)
* -U <path> : delete a VMDK

Supportedd format for disk: zeroedthick|eagerzeroedthick|thin|rdm:dev|rdmp:dev|2gbsparse

## vmfolder

Note: totally new tool

Needed parms:
* --url <url> : url to the ESX/VCenter like https://hostname/sdk/webService
* --datacenter <datacenter> : if VCenter
* --folder <folder> : folder name

Operations:
* --operation <create/delete>

## vmregister

Needed parms:
* --url <url> : url to the ESX/VCenter like https://hostname/sdk/webService
* --datacenter <datacenter> : if VCenter
* --vmxpath <path> : path to vmx file

Option:
* --folder <folder> : folder name (for register)
* --hostname <host> : host to register VM
* --cluster <cluster> : cluster name (for register)

Operations:
* --operation <register/unregister>

## vmclone

Needed parms:
* --url <url> : url to the ESX/VCenter like https://hostname/sdk/webService
* --vmhost : host on which the new vm will be registered (even if you are running on cluster, this is the host which will proceed to the operation)
* --vmname <src> / --vmname_destination <dst> : VM source/destination. If you want to keep the same name, you need to use folder

Option:
* --datastore <path> : on which datastore copy the new VM
* --folder <folder name> : in which folder register the new VM

