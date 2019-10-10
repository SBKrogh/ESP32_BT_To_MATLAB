function [returnTable] = getTable(Task)

Row = 1000000; % Each row corrosponds to 1 ms 
SampleRate = 1000; % Hz

%%
varTypes = {'single', 'single', 'single', 'single',... % FSR 1 - 4
            'single', 'single', 'single', 'single',... % FSR 5 - 8
            'single', 'single', 'single', 'single',... % EMG 1 - 4
            'single', 'single', 'single',...           % Acceleration xyz IMU1
            'single', 'single', 'single',...           % Acceleration xyz IMU2
            'single', 'single', 'single',...           % Gyro xyz IMU1
            'single', 'single', 'single'};             % Gyro xyz IMU2


% NameOfVariables = {'FSR1', 'FSR2', 'FSR3', 'FSR4', 'FSR5', 'FSR6', 'FSR7', 'FSR8',...
%                    'EMG1', 'EMG2', 'EMG3', 'EMG4',...
%                    'AccX1', 'AccY1', 'AccZ1', 'AccX2', 'AccY2', 'AccZ2',...
%                    'GyrX1', 'GyrY1', 'GyrZ1', 'GyrX2', 'GyrY2', 'GyrZ2'};

%% IMU
if strcmp(Task.Properties.VariableNames,'IMU')
    NameOfVariables = {'AccX1', 'AccY1', 'AccZ1', 'AccX2', 'AccY2', 'AccZ2'};
    varTypes = varTypes(1:length(NameOfVariables));
    Column = length(NameOfVariables);
end
%% FSR
if strcmp(Task.Properties.VariableNames,'FSR')
    NameOfVariables = {'FSR1', 'FSR2', 'FSR3', 'FSR4', 'FSR5', 'FSR6', 'FSR7', 'FSR8'};
    varTypes = varTypes(1:length(NameOfVariables));
    Column = length(NameOfVariables);
end
%% EMG
if strcmp(Task.Properties.VariableNames,'EMG')
    NameOfVariables = {'EMG1', 'EMG2', 'EMG3', 'EMG4'};
    varTypes = varTypes(1:length(NameOfVariables));
    Column = length(NameOfVariables);
end
%% All
if strcmp(Task.Properties.VariableNames,'All')
    NameOfVariables = {'FSR1', 'FSR2', 'FSR3', 'FSR4', 'FSR5', 'FSR6', 'FSR7', 'FSR8',...
                       'EMG1', 'EMG2', 'EMG3', 'EMG4',...
                       'AccX1', 'AccY1', 'AccZ1', 'AccX2', 'AccY2', 'AccZ2'};
    varTypes = varTypes(1:length(NameOfVariables));
    Column = length(NameOfVariables);
end

%% Return table 

SizeOfData = [Row Column];
returnTable = timetable('Size', SizeOfData,...
                        'VariableTypes', varTypes,...
                        'SampleRate', SampleRate,...
                        'VariableNames', NameOfVariables);
                    
