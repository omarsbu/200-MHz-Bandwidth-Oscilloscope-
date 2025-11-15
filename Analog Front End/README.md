<img width="1880" height="872" alt="image" src="https://github.com/user-attachments/assets/a6f66322-5d59-40fa-9f95-0e7c16923dee" />

The purpose of an analog front end is to condition the input signal so that it maximizes the ADC’s dynamic range and limits the bandwidth to the ADC’s Nyquist frequency. Attenuators extend the measurable range by scaling down large input signals to within the appropriate voltage range and a programmable gain amplifier boosts small signals so they make full use of the ADC’s resolution. DC offsetting is also applied to bias the signal so that it fits well within the ADC’s input range. A high impedance JFET LNA buffer allows the oscilloscope input to be terminated with 1 MΩ or 50 Ω impedance.

<img width="2197" height="1477" alt="image" src="https://github.com/user-attachments/assets/4b8f5d5a-84cb-4dcb-b7b4-b6fc57d68020" />

The input stage of each channel consists of a set of relay switches to select between AC and DC coupling, as well as different attenuation levels. A compensated 1 MΩ L-pad attenuator is used for normal measurements with standard probes, while 50 Ω pi-attenuators are used for high-fidelity measurements from a 50 Ω source. Protection diodes clamp the input voltage if it exceeds the positive or negative supply rails.

<img width="2342" height="1670" alt="image" src="https://github.com/user-attachments/assets/60f245b9-53fe-4f19-8048-275fcd5a2923" />

The BUF802 is used in conjunction with the OPA140 to form a composite amplifier that delivers strong performance at both high and low frequencies. The BUF802, with its JFET input, provides exceptional AC performance but poor DC precision, while the OPA140 offers excellent DC precision but lacks sufficient bandwidth and slew rate for high-frequency signals. To leverage the strengths of both, the main input is AC-coupled to the BUF802, while the auxiliary input is driven by the OPA140’s DC offset circuitry. This circuitry uses a differential amplifier along with a DAC (0–5 V) and a 2.5 V reference to shift the output within a programmable range of ±2.5 V. A resistor in series with the differential amplifier output allows the DAC to modify the DC feedback network to the OPA140, which drives the BUF802 auxiliary input, thereby enabling a programmable DC offset of the input signal. To prevent the BUF802 output from exceeding the ±1 V differential input range of the LMH6518, Zener diodes are used to clamp the output to ±1 V. Additionally, a 50 Ω series resistor allows the BUF802 to drive the subsequent stages of the analog front-end signal chain as a 50 Ω source.

<img width="2645" height="1722" alt="image" src="https://github.com/user-attachments/assets/02ce70f2-cafe-4c60-8ae5-f02b951b3f3e" />

The ideal input condition of the LMH6518 are shown below:
<img width="168.7" height="22.7" alt="image" src="https://github.com/user-attachments/assets/ad15335a-d3a1-4635-a71a-f0a67e6306b5" />
The LMH6552 is used as a level-shifter and single-ended to differential converter with drives the LMH6518 with a balanced differential input with 2.5V common-mode voltage. 


<img width="1872" height="1485" alt="image" src="https://github.com/user-attachments/assets/2ba2368d-d504-40e0-8401-7547149d89f9" />
