clc; clear all; close all; 
%% This script is for the initial testing of time tables to see its "real time" performace..
% https://se.mathworks.com/help/matlab/ref/timetable.html

%% Create randome data 
SampleRate = 1000; % Hz
SizeOfData = [1000000 24];
varTypes = {'single', 'single', 'single', 'single',... % FSR 1 - 4
            'single', 'single', 'single', 'single',... % FSR 5 - 8
            'single', 'single', 'single', 'single',... % EMG 1 - 4
            'single', 'single', 'single',...           % Acceleration xyz IMU1 
            'single', 'single', 'single',...           % Acceleration xyz IMU2
            'single', 'single', 'single',...           % Gyro xyz IMU1 
            'single', 'single', 'single'};             % Gyro xyz IMU2
            
            
NameOfVariables = {'FSR1', 'FSR2', 'FSR3', 'FSR4', 'FSR5', 'FSR6', 'FSR7', 'FSR8',...
                   'EMG1', 'EMG2', 'EMG3', 'EMG4',...
                   'AccX1', 'AccY1', 'AccZ1', 'AccX2', 'AccY2', 'AccZ2',...
                   'GyrX1', 'GyrY1', 'GyrZ1', 'GyrX2', 'GyrY2', 'GyrZ2'};

TT = timetable('Size', SizeOfData,...
               'VariableTypes', varTypes,... 
               'SampleRate', SampleRate,...
               'VariableNames', NameOfVariables);

