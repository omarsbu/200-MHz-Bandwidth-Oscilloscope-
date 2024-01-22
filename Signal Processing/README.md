  For this project, we will be interleaving two 12-bit ADCs for a total sample rate of 500 Msps and a total data rate of 6 Gbsp. The VGA controller that we are using only has a resolution of 640x480 pixels, so we 
cannot plot any more than 640 samples on the screen. The time interval in between each sample is 2 nanoseconds, therefore, 640 samples corresponds to a waveform that is 1.28 microseconds long. If the screen 
displays 10 horizontal divisions, then 1.28 us corresponds to 128 ns/div which is the highest time resolution that this oscilloscope will be capable of displaying. At this time per division setting, the oscilloscope simply 
plots the first 640 samples from the ADC versus time on the display, following the trigger event. In order to display longer time per division settings, additional processing on the data is needed before 
displaying the waveform on the screen. 

At the maximum time per division setting of 1 second/div, the oscilloscope would display a 10 second span of data across a screen with 10 divisions. Given the current data rate of 6 Gbps, this would require 60 
gigabits of memory to store all of the samples before processing them! Since we do not have enough memory to process all of the samples at once, we will need a buffer to process parts of the signal and then 
reconstruct the waveform from the segmented data. In order to do this, we will need to obtain a time-frequency representation of the signal that will provide insight to how its various frequency components vary 
over time. 





















![image](https://github.com/omarsbu/200-MHz-Bandwidth-Oscilloscope-/assets/99481191/7df976c4-fa5d-4c9b-aff6-5b584a3c8429)
