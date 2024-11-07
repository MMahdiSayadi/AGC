clc 
clear 
close all 


% AGC Parameters
targetLevel = 200;  % Target output level range (-200 to 200)
gain = 1;           % Initial gain
stepSize = 0.0000005;  % Step size for gain adjustment

% Input Signal
Fs = 1e6;               % Sample rate (1 MHz)
t = (0:1/Fs:1).';       % 1 second of data
inputSignal = 2000 * sin(2*pi*10e3*t);  % 10 kHz sine wave, range -2000 to 2000

% AGC Processing
outputSignal = AGC(inputSignal, targetLevel, stepSize);

% Plot Results
figure;
subplot(2,1,1);
plot(t, inputSignal);
title('Input Signal');
subplot(2,1,2);
plot(t, outputSignal);
title('Output Signal (AGC Applied)');
