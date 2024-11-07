clc 
clear 
close all 
addpath('fcn\')

% AGC Parameters
targetLevel = 200;  
gain = 1;          
stepSize = 0.0000005;  
Numreps = 5;


Nsamp = 1024 * Numreps;
Fs = 1e6;              
t = (0:1/Fs:(Nsamp - 1)/Fs).';      
inputSignal = 2000 * exp(1j*2*pi*10e3*t);  
[o_int_real, o_bin_real] = fim(real(inputSignal), 1, 16, 0);
[o_int_imag, o_bin_imag] = fim(imag(inputSignal), 1, 16, 0);




%% write to file 
writeKey = 0;
fileName_real = ['../../FPGA/SRC/TB/TestFiles/', 'Mat_Out_INPSIG_00_Real.txt'];
fileName_imag = ['../../FPGA/SRC/TB/TestFiles/', 'Mat_Out_INPSIG_00_Imag.txt'];
if writeKey 
    write2file(fileName_real, o_bin_real);
    write2file(fileName_imag, o_bin_imag);
    disp('write success!!');
end 

