% Parameters
duration = 5;           % Signal duration in seconds
fs = 1000;              % Sampling frequency in Hz

% Time vector
t = 0:1/fs:duration;

% Parameters for the Gaussian curve
mu = 0;        % Mean
sigma = 10;     % Standard deviation

% Custom Gaussian PDF
gaus = 10*exp(-(t - mu).^2 / (2 * sigma^2)) / (sigma * sqrt(2 * pi));

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
morlet_wavelet = morlet(-3, 3, 5001); % Morlet wavelet with frequency 1

% Multiply the signal by Gaussian PDF and perform FFT and IFFT

amplitude_modulated_signal2 = amplitude_modulated_signal .* gaus;
fft_result1 = fft(amplitude_modulated_signal2);
ifft_result1 = ifft(fft_result1);

chirp_signal2 = chirp_signal .* gaus;
fft_result2 = fft(chirp_signal2);
ifft_result2 = ifft(fft_result2);

random_signal2 = random_signal .* gaus;
fft_result3 = fft(random_signal2);
ifft_result3 = ifft(fft_result3);

square_wave2 = square_wave .* gaus;
fft_result4 = fft(square_wave2);
ifft_result4 = ifft(fft_result4);

triangle_wave2 = triangle_wave .* gaus;
fft_result5 = fft(triangle_wave2);
ifft_result5 = ifft(fft_result5);

morlet_wavelet2 = morlet_wavelet .* gaus;
fft_result6 = fft(morlet_wavelet2);
ifft_result6 = ifft(fft_result6);

% Plot original and reconstructed signals on the same grid
figure;

% Subplot 1: Amplitude-Modulated Sine Wave
subplot(3, 2, 1);
plot(t, amplitude_modulated_signal, 'LineWidth', 1.2);
hold on;
plot(t, ifft_result1, 'r', 'LineWidth', 1.2);
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
plot(t, ifft_result2, 'r', 'LineWidth', 1.2);
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
plot(t, ifft_result3, 'r', 'LineWidth', 1.2);
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
plot(t, ifft_result4, 'r', 'LineWidth', 1.2);
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
plot(t, ifft_result5, 'r', 'LineWidth', 1.2);
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
plot(t, ifft_result6, 'r', 'LineWidth', 1.2);
hold off;
title('Morlet Wavelet and Reconstruction');
xlabel('Time (s)');
ylabel('Amplitude');
legend('Original', 'Reconstructed');
grid on;

% Increase the height of the y-axis for Subplot 6
new_ylim6 = get(gca, 'YLim') * 2; % Adjust the multiplier as needed
ylim(new_ylim6);

% Adjust layout
sgtitle('Original Signals and Their Reconstructions');


