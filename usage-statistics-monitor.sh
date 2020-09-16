#!/bin/bash
##
# Monitoring of BMC utilization statistics. The following metrics shall be supported:
# BMC CPU usage
# BMC RAM usage
# BMC flash usage
##
flag=0
sleep_sec=5
tmp_cpu_file="/tmp/cupUsage.txt"
tmp_ram_file="/tmp/ramUsage.txt"
tmp_fash_file="/tmp/flashUsage.txt"

service_name='xyz.openbmc_project.HealthStatistics'
obj_path1='/xyz/openbmc_project/sensors/utilization/CPU'
obj_path2='/xyz/openbmc_project/sensors/utilization/Memory'
obj_path3='/xyz/openbmc_project/sensors/utilization/Storage'
obj_interface='xyz.openbmc_project.Sensor.Value'

# BMC CPU usage
function cpuUtil()
{
	`cat /proc/stat > $tmp_cpu_file`
	cpu1=`grep -iw cpu $tmp_cpu_file | cut -d " " -f 3`
	cpu2=`grep -iw cpu $tmp_cpu_file | cut -d " " -f 4`
	cpu3=`grep -iw cpu $tmp_cpu_file | cut -d " " -f 5`
	cpu4=`grep -iw cpu $tmp_cpu_file | cut -d " " -f 6`
	cpu5=`grep -iw cpu $tmp_cpu_file | cut -d " " -f 7`
	cpu6=`grep -iw cpu $tmp_cpu_file | cut -d " " -f 8`
	cpu7=`grep -iw cpu $tmp_cpu_file | cut -d " " -f 9`
	cpu8=`grep -iw cpu $tmp_cpu_file | cut -d " " -f 10`
	cpu8=`grep -iw cpu $tmp_cpu_file | cut -d " " -f 11`
	cpu10=`grep -iw cpu $tmp_cpu_file | cut -d " " -f 12`
	cpu_use="$(($cpu1+$cpu2+$cpu3+$cpu5+$cpu6+$cpu7+$cpu8+$cpu9+$cpu10))"
	cpu_total="$(($cpu1+$cpu2+$cpu3+$cpu4+$cpu5+$cpu6+$cpu7+$cpu8+$cpu9+$cpu10))"
	cpu_util=`awk "BEGIN {printf \"%.2f\", ($cpu_use/$cpu_total)*100}"`
	#cpu_usage=${cpu_util::-2}
	`rm $tmp_cpu_file`
	#echo $cpu_use
	#echo $cpu_total
	#echo "cpu usage:" $cpu_util "%"
	# set cpu sensor value
	re='^[0-9]+([.][0-9]+)?$'
	if ! [[ $cpu_util =~ $re ]] ; then
		echo "error: Not a number"
		`busctl set-property $service_name $obj_path1 $obj_interface Value d 0`
	else
		`busctl set-property $service_name $obj_path1 $obj_interface Value d $cpu_util`
	fi;
}

# BMC RAM usage
function ramUtil()
{
	`cat /proc/meminfo > $tmp_ram_file`
	mem_total=`grep -iw MemTotal $tmp_ram_file | cut -d ":" -f 2`
	mem_free=`grep -iw MemFree $tmp_ram_file | cut -d ":" -f 2`
	mem_total_val=${mem_total::-2}
	mem_free_val=${mem_free::-2}
	mem_util=`awk "BEGIN {printf \"%.2f\", ($mem_total_val-$mem_free_val)/$mem_total_val*100}"`
	#mem_usage=${mem_util::-2}
	`rm $tmp_ram_file`
	#echo $mem_total_val
	#echo $mem_free_val
	#echo "mem usage:" $mem_util "%"
	# set mem sensor value
	re='^[0-9]+([.][0-9]+)?$'
	if ! [[ $mem_util =~ $re ]] ; then
		echo "error: Not a number"
		`busctl set-property $service_name $obj_path2 $obj_interface Value d 0`
	else
		`busctl set-property $service_name $obj_path2 $obj_interface Value d $mem_util`
	fi;
}

# BMC flash usage
function dfUtil()
{
	`df > $tmp_fash_file`
	root_info=`grep -ir /dev/mtdblock5 $tmp_fash_file | cut -d "%" -f 1`
	#echo $root_info
	root_usage=`echo $root_info | tr ' ' '\n' | tail -1`
	#echo "root usage:" $root_usage "%" 
	`rm $tmp_fash_file`
	# set df sensor value 
	re='^[0-9]+?$'
	if ! [[ $root_usage =~ $re ]] ; then
		echo "error: Not a number"
		`busctl set-property $service_name $obj_path3 $obj_interface Value d 0`
	else
		`busctl set-property $service_name $obj_path3 $obj_interface Value d $root_usage`
	fi;
}

mapper wait $obj_path1
mapper wait $obj_path2
mapper wait $obj_path3

while [ $flag == 0 ]
do 
	#CPU usage statistics
	cpuUtil
	#RAM usage statistics
	ramUtil
	#flash usage statistics 
	dfUtil
		
	for ((a=sleep_sec;a>=0;a--))
	do	
		echo -ne "\rplease wait $a seconds"
		sleep 1
	done
	echo ""
done			

