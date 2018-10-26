#
# hyperv_create_vm.ps1
#

### environment settings
param (
   [Parameter(Mandatory=$true)]
   $VMlist
)
$templatepath = “E:\HyperV Vorlagen\Server 2012 R2 DC_Gen1.vhdx”
$path = "D:\HyperV\Virtual Machines"
$diskpath = "D:\HyperV\Virtual Hard Disks"
### selesct one of these 3 Disktypes ###
$vhdtype = "Differencing"
#$vhdtype = "Fixed"
#$vhdtype = "Dynamic"
### configure RAM-settings ###
$maxbytes = 4GB
$minbytes = 512MB
$startbytes = 2GB

foreach ($vm in $vmlist)
{
#prepare folder
$vmpath = “$path\$vm”
New-Item -Path $vmpath -ItemType “Directory”
# create VHD
if ($vhdtype -eq „Differencing“)
 {
 New-VHD -ParentPath $templatepath -Path "$diskpath\$vm.vhdx" -Differencing
 }
 else
 {
 if ($vhdtype -eq „Fixed“)
 {
 Convert-VHD $templatepath $diskpath\$vm.vhdx -VHDType $vhdtype
 }
 else
 {
 Copy-Item $templatepath $diskpath\$vm.vhdx
 }
 }
if ($vhdtype -eq „Fixed“)
 {
 New-VM -VHDPath $diskpath\$vm.vhdx -Name $vm -Path $vmpath -SwitchName intern01
 }
 else
 {
 New-VM -VHDPath $diskpath\$vm.vhdx -Name $vm -Path $vmpath -SwitchName intern01
 }
Set-VMMemory -VMName $vm -DynamicMemoryEnabled $True -MaximumBytes $maxbytes -MinimumBytes $minbytes -StartupBytes $startbytes
Start-VM $vm
}
