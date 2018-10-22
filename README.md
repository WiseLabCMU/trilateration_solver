# trilateration_solver

1) Power on the LinkSys router that hosts "cantTouchThis" network. Password: on the router
2) Connect "johnpi" Rpi to the router
3) Turn on mud + all nodes (aesir, bohr, day, earth..)

Upon starup, johnpi.local starts hosting the MQTT server.
Upon startup, mud.local runs a script that ranges to nodes 0-3. To make it range to more nodes, 
modify in .bashrc - the line that is calling the ranging script with parameter "4" 
To log into mud.local: pi@mud.local, password: J***z

Upon startup, each beacon listens for ranging packets and respond. Each beacon has been programed with its ID (0, 1, 2..)

To start ranging, send command "mud.local" on topic/uwb_ctrl 
mosquitto_pub -h johnpi.local -t topic/uwb_ctrl -m 'mud.local'
This command makes mud range for about 10 seconds
Currently, if you turn on the "Competition App" it publishes the above command every 9 seconds.

To view the ranges, subscribe to channel: topic/uwb_range_mud 
mosquitto_sub -v -h johnpi.local -t topic/uwb_range_mud

To run the solver, run StreamUwbLoc.m.
It requires this MQTT library to be installed: https://in.mathworks.com/matlabcentral/fileexchange/64303-mqtt-in-matlab

The MATLAB code continuously subscribes to "johnpi.local  topic/uwb_range_mud"
It runs trialteration and publishes the location to "johnpi.local  topic/uwb_loc" 
in this format: topic/uwb_loc {"x":2.10,"y":8.15,"z":1.22}





