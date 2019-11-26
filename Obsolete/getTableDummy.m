function [returnTable] = getTableDummy()

Row = 10;
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

NameOfVariables = {'AccX1', 'AccY1', 'AccZ1', 'AccX2', 'AccY2', 'AccZ2'};
varTypes = varTypes(1:length(NameOfVariables));
Column = length(NameOfVariables);


%% Return table

SizeOfData = [Row Column];
returnTable = table('Size', SizeOfData,...
    'VariableTypes', varTypes,...
    'VariableNames', NameOfVariables);


returnTable{1:Row,:} = ones(Row,6);





