  For this project, we will be interleaving two 12-bit ADCs for a total sample rate of 500 Msps and a total data rate of 6 Gbsp. The VGA controller that we are using only has a resolution of 640x480 pixels, so we 
cannot plot any more than 640 samples on the screen. The time interval in between each sample is 2 nanoseconds, therefore, 640 samples corresponds to a waveform that is 1.28 microseconds long. If the screen 
displays 10 horizontal divisions, then 1.28 us corresponds to 128 ns/div which is the highest time resolution that this oscilloscope will be capable of. At this time per division setting, the oscilloscope simply 
plots the first 640 samples from the ADC versus time on the display, following the trigger event. In order to display a longer time per division settings, additional processing on the data is needed before 
displaying the waveform on the screen. 
























![image](https://github.com/omarsbu/200-MHz-Bandwidth-Oscilloscope-/assets/99481191/7df976c4-fa5d-4c9b-aff6-5b584a3c8429)
