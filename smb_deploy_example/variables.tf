variable "region" {
    description     = "azure region where resources should be created"
    default         = "East US 2"
}

variable "rg" {
    description     = "existing resource group"
    default         = "sluce.rg"
}
    
variable "vnet" {
    description     = "existing VNET"
    default         = "sluce.rg_vnet"
}  

variable "subnet" {
    description     = "desired name of ANF subnet"
    default         = "ANFSubnet"
}

variable "address_range" {
    description     = "CIDR range for ANF subnet"
    default         = "172.18.20.0/24"
}  

variable "naa" {
    description     = "name of NetApp Account to be created for ANF"
    default         = "sluce-naa"
}

variable "ad_username" {
    description     = "active directory username with add permission"
    default         = "administrator"
}

variable "ad_password" {
    description     = "active directory password"
    default         = ""
}

variable "smb_server_prefix" {
    description     = "computer account name prefix"
    default         = "anf"
}

variable "dns_servers" {
    description     = "DNS servers to resolve active directory domain"
    default         = ["192.168.10.10"]
}

variable "ad_domainname" {
    description     = "domain name of active direcotry to be joined"
    default         = "gigabuckets.com"
}

variable "organizational_unit" {
    description     = "target active directory OU for computer account"
    default         = "OU=Computers"
}
variable "pool" {
    description     = "name of capacity pool to be created"
    default         = "MyCapacityPool"
}

variable "pool_size" {
    description     = "size of capacity pool in TiB"
    default         = "4"
}

variable "service_level" {
    description     = "capacity pool service level, Standard, Premium or Ultra"
    default         = "Standard"
}

variable "volume" {
    description     = "name of volume to be created"
    default         = "myvolume"
}

variable "volume_path" {
    description     = "volume mount path, no underscores for SMB"
    default         = "myvolpath" 
}

variable "quota" {
    description     = "desired volume quota in GiB"
    default         = "100"
}

variable "alert_percent" {
    description     = "alert metric will be created to alert once logical consumed reaches this percent"
    default         = "85"
}

variable "alert_email_azapp" {
    description     = "email address for Azure App alerting"
}

variable "alert_email_address" {
    description     = "email address for email alerting"
}

variable "alert_phone_sms" {
    description     = "mobile phone number for SMS alerting"
}

variable "standard_tags" {
    description     = "tags to be applied to all resources"
    default         = {
        creator     = "luces"
        owner       = "luces"
        keepalive   = "yes"
    }
}