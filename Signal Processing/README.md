For this project, we will be interleaving two 12-bit ADCs for a total sample rate of 500MHz, therefore we are looking at a total data rate of the 6 Gbps. In order to display the data we will be using the Basys 3
FPGA board which supports a 12-bit color VGA video interface. Since the VGA controller we are using only has 640x480 resolution, we cannot plot anymore than 640 samples on the screen. This is fine if we only wish 
to display 1.28 microeconds of a signal


Since the VGA controller we are using only has 640x480 resolution, we cannot plot anymore than 640 samples on the screen. This is fine if we only wish 
to display 1.28 microeconds of a signal






therefore we will need to perform some processing on the data before plotting it on the 
display. 



![image](https://github.com/omarsbu/200-MHz-Bandwidth-Oscilloscope-/assets/99481191/7df976c4-fa5d-4c9b-aff6-5b584a3c8429)
