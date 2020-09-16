#!/bin/bash
##
## Monitor dbus when CurrentHostState propertiesChanged, then set to the current_host_state sensor
##
type='signal'
org_interface='org.freedesktop.DBus.Properties'
member='PropertiesChanged'
service_name1='xyz.openbmc_project.State.Host'
obj_path1='/xyz/openbmc_project/state/host0'
obj_interface1='xyz.openbmc_project.State.Host'
pattern='CurrentHostState'
service_name2='xyz.openbmc_project.HostEventMon'
obj_path2='/xyz/openbmc_project/sensors/oem/current_host_state'
obj_interface2='xyz.openbmc_project.Sensor.Value'
value1=''
value2=''
retry_max=30
i=0

mapper wait $obj_path1
mapper wait $obj_path2

# check OEMSensor service is ready, or wait and retry it. 
until [ $i -gt $retry_max ]
do
	test_info=`busctl get-property $service_name1 $obj_path1 $obj_interface1 $pattern`
	if [ $? -gt 0 ] ; then
		i=$(( i+1 ))
		echo "get property fail, path: $obj_interface1, retry times : $i"
		sleep 1	
	else
		i=$(( $retry_max+1 ))
		echo "get property success, path: $obj_interface1"
	fi;
done
i=0
# check value is ready, or wait and retry it.
until [ $i -gt $retry_max ]
do
	# get service_name2 property value
	value2=`busctl get-property $service_name2 $obj_path2 $obj_interface2 Value | awk '{print $2}'| cut -d '"' -f 2`
	if [ "$value2" = "n/a" ] || [ "$value2" = "" ] ; then
		echo "ServiceName: $service_name2, ObjPath: $obj_path2, Interface: $obj_interface2, Value=$value2"
		echo "get property value fail, value: $value2, retry times : $i"
		# get service_name1 property value
		value1=`busctl get-property $service_name1 $obj_path1 $obj_interface1 $pattern | awk '{print $2}'| cut -d '"' -f 2`
		# set to the restart_cause sensor to avoid nil
		`busctl set-property $service_name2 $obj_path2 $obj_interface2 Value s $value1`
		i=$(( i+1 ))
		sleep 1	
	else
		i=$(( $retry_max+1 ))
		echo "ServiceName: $service_name2, ObjPath: $obj_path2, Interface: $obj_interface2, Value=$value2"
		echo "get property value success"
	fi;
done
# monitor dbus and set value when properties changed
`dbus-monitor --system "type='$type', interface='$org_interface', member='$member', path='$obj_path1', arg0='$obj_interface1'" | awk '/'$pattern'/{getline;print $3;}' | awk '{ print "busctl set-property '$service_name2' '$obj_path2' '$obj_interface2' Value s "$0 }' | sh`
