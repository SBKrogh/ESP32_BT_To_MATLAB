%% Return reinterpreted ADC data 
% Input: Matrix [m x 2] uint8 raw byte data from one of the ADC channels
% Each row should corrospond to one reading..

function [ReturnVoltage] = Reinterpreted16bit(Data)

[m, n] = size(Data);
ReturnVoltage = zeros(m,1);

MaxBinaryValues = 65535; % 16 bit
VoltageRange = 24;       % 12 - (-12) volt
Data = uint8(Data);

for k = 1:m
    x = double(typecast(Data(k,:),'uint16'));
    ReturnVoltage(k) = ((x * VoltageRange)/MaxBinaryValues) - 12;
end
