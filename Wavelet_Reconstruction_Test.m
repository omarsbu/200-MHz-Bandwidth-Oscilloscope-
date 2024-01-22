% Parameters
duration = 5;           % Signal duration in seconds
fs = 1000;              % Sampling frequency in Hz

% Time vector
t = 0:1/fs:duration;

% Generate amplitude-modulated sine wave
carrier_frequency = 50;         % Carrier frequency in Hz
modulation_frequency = 5;      % Modulation frequency in Hz
amplitude_modulated_signal = sin(2*pi*carrier_frequency*t) .* (1 + 0.5*sin(2*pi*modulation_frequency*t));

% Generate chirp signal
f0 = 10;                % Initial frequency in Hz
f1 = 50;                % Final frequency in Hz
chirp_signal = sin(2*pi * (f0 + (f1 - f0) ./ (2*duration) .* t) .* t);

% Generate random signal
random_signal = randn(size(t));

% Generate square wave
square_wave = square(2*pi*5*t); % 5 Hz square wave

% Generate triangle wave
triangle_wave = sawtooth(2*pi*5*t, 0.5); % 5 Hz triangle wave

% Generate Morlet wavelet
morlet_wavelet = morlet(-2.5, 2.5, 5001); % Morlet wavelet with frequency 1

% Reconstruct from inverse wavelet transform
wt_am = cwt(amplitude_modulated_signal, fs);
xrec_am = icwt(wt_am);

wt_chirp = cwt(chirp_signal, fs);
xrec_chirp = icwt(wt_chirp);

wt_random = cwt(random_signal, fs);
xrec_random = icwt(wt_random);

wt_square = cwt(square_wave, fs);
xrec_square = icwt(wt_square);

wt_triangle = cwt(triangle_wave, fs);
xrec_triangle = icwt(wt_triangle);

wt_morlet = cwt(morlet_wavelet, fs);
xrec_morlet = icwt(wt_morlet);

% Plot original and reconstructed signals on the same grid
figure;

% Subplot 1: Amplitude-Modulated Sine Wave
subplot(3, 2, 1);
plot(t, amplitude_modulated_signal, 'LineWidth', 1.2);
hold on;
plot(t, xrec_am, 'r', 'LineWidth', 1.2);
hold off;
title('Amplitude-Modulated Sine Wave and Reconstruction');
xlabel('Time (s)');
ylabel('Amplitude');
legend('Original', 'Reconstructed');
grid on;

% Subplot 2: Chirp Signal
subplot(3, 2, 2);
plot(t, chirp_signal, 'LineWidth', 1.2);
hold on;
plot(t, xrec_chirp, 'r', 'LineWidth', 1.2);
hold off;
title('Chirp Signal and Reconstruction');
xlabel('Time (s)');
ylabel('Amplitude');
legend('Original', 'Reconstructed');
grid on;

% Subplot 3: Random Signal
subplot(3, 2, 3);
plot(t, random_signal, 'LineWidth', 1.2);
hold on;
plot(t, xrec_random, 'r', 'LineWidth', 1.2);
hold off;
title('Random Signal and Reconstruction');
xlabel('Time (s)');
ylabel('Amplitude');
legend('Original', 'Reconstructed');
grid on;

% Subplot 4: Square Wave
subplot(3, 2, 4);
plot(t, square_wave, 'LineWidth', 1.2);
hold on;
plot(t, xrec_square, 'r', 'LineWidth', 1.2);
hold off;
title('Square Wave and Reconstruction');
xlabel('Time (s)');
ylabel('Amplitude');
legend('Original', 'Reconstructed');
grid on;

% Subplot 5: Triangle Wave
subplot(3, 2, 5);
plot(t, triangle_wave, 'LineWidth', 1.2);
hold on;
plot(t, xrec_triangle, 'r', 'LineWidth', 1.2);
hold off;
title('Triangle Wave and Reconstruction');
xlabel('Time (s)');
ylabel('Amplitude');
legend('Original', 'Reconstructed');
grid on;

% Subplot 6: Morlet Wavelet
subplot(3, 2, 6);
plot(t, morlet_wavelet, 'LineWidth', 1.2);
hold on;
plot(t, xrec_morlet, 'r', 'LineWidth', 1.2);
hold off;
title('Morlet Wavelet and Reconstruction');
xlabel('Time (s)');
ylabel('Amplitude');
legend('Original', 'Reconstructed');
grid on;

% Adjust layout
sgtitle('Original Signals and Their Reconstructions');
