clc; clear all; close all; delete(instrfind)
% Note: Please pair the BT with Windows before running this script:
% Windows start button -> Bluetooth & other devices -> Enable Bluetooth and
% pair with ESP32..
%
% Troubleshooting https://se.mathworks.com/help/instrument/troubleshooting-bluetooth-interface.html

%% Include path 
addpath(genpath('Functions'));
addpath(genpath('Data'));

%% Create BT connection to ESP32
% It might be a good idea to restart matlab if the BT connection has been
% established before and was not properly disconnected!
% call:: restart_matlab()

b = EstablishConnectionBT();

%% Commands defined on ESP32
% SendTask(b,'CalibrateFSR'); % Ues this when doing maximum contraction 

%% Define task implmented on ESP32 and its package size
% Data is received as four uint8_t reinterpreted from float 
FSR = 32;                           % Bytes
IMU = 24;                           % Bytes -> Accleration only
EMG = 16;                           % Bytes
All = FSR + EMG + IMU;              % Bytes

TaskAvailable = table(FSR,IMU,EMG,All);
% clear FSR IMU EMG All

%% Specify task - input by user Keyboard
prompt = 'Specify task of interest\nFSR, IMU, EMG, All or stop\n';
while 1
    TaskInput = input(prompt, 's');
    if strcmp(TaskInput,'stop')
        fclose(b);
        return
    end
    
    if sum(strcmp(TaskInput,TaskAvailable.Properties.VariableNames))
        fprintf('Task exists\n')
        Task = TaskAvailable(:,TaskInput);
        break
    else
        clc
        fprintf('Task: %s, - did not exist - Try again or type "stop" to end program\n\n',TaskInput)
    end
end

%% Receive and stop BT communication
clear counter package; % Clear memory if they exists
% TaskInput = 'All';             % Erase this when done testing!!!!!!!!
% Task = TaskAvailable(:,'All'); % Erase this when done testing!!!!!!!!

PackageSize = TaskAvailable.(TaskInput);     % Task package size - bytes
TestTime = 15*60;                            % Test time in seconds 
fHz = 1000;                                  % Sample frequency
ArraySize = PackageSize * TestTime * fHz;    % Specify memory alocation
BufferSizeSaftyMargin = 0;                   % Increase this if additional buffermargin is necessary

package = zeros(ArraySize, 1);      % Allocate memory for raw BT data
[Data, VarName] = getMatrix(Task);  % Return inital buffer for storing reinterpreted data and column names
DataRow = length(Data);

if strcmp(b.Status,'open') % Used to close the BT communication.
    fclose(b);             % Usefull when ESP32 is restarting and
    flushinput(b)          % communication should be re-established.
end
flushinput(b)              % Empty BT buffer

ButtonHandle = uicontrol('Style', 'PushButton', ...  % Stop button
    'String', 'Stop loop', ...
    'Callback', 'delete(gcbf)');

TimeCounter = 1;                 % Counter for buffer readings
BufferTest = zeros(ArraySize,1); % Used to store buffer size usage


fopen(b);                                         % Enable BT communcation
SendTask(b, char(Task.Properties.VariableNames)); % Initiate the IMU data collection
package(1:PackageSize) = fread(b,PackageSize);    % First data package received
PackagesReceived = PackageSize;                   % Byte received counter
DataTrack = 1;                                    % Keep track of reinterpreted data stored

FormattedToo = 0;       % How much data is reinterpreted
avgTime = zeros(500,4); % Used to measure function elaps time 
k = 1;

print200 = 200;                     % Specify plot update speed 
time = 0; ydata = 0;                % Initial plot data
StopPlot = 0;                       % Used for stopping the plotter 
DataPlot = plot(time,ydata,'-r');

PlotCount = 1;

% PlotArray = zeros(1,2000);
% PlotArray2 = PlotArray;

while(1)
    tic
    BufferSize = b.BytesAvailable;    % Check if data in buffer is available
        
    if BufferSize + PackagesReceived + BufferSizeSaftyMargin > ArraySize    % Check if allocated space is exceeded
        package = cat(1,package, zeros(PackagesReceived,1));                % Increase allocation of memory
        ArraySize = length(package);
        fprintf('packagebuffer reallocated to %i\n', ArraySize)
    end
    avgTime(k,1) = toc;
    
    if BufferSize > 0 % Check if bytes are received
        package(PackagesReceived + 1: PackagesReceived + BufferSize) = fread(b,BufferSize); % Store data in allocated memory
        BufferTest(TimeCounter) = BufferSize;               % Store buffer usage before reading
        TimeCounter = TimeCounter + 1;                      % Counter for buffer readings
        PackagesReceived = PackagesReceived + BufferSize;   % Increase byte counter received.
    end
    avgTime(k,2) = toc;
    
    if ~ishandle(ButtonHandle)          % Stops program if stop button is pushed
        SendTask(b,'Stop');             % Stop ESP32 task
        pause(0.5)                      % Wait for ESP32 to empty output buffer
        disp('Loop stopped by user');   %
        BufferSize = b.BytesAvailable;  % Read amount of available bytes - Necessary for proper if statement handling
        if BufferSize > 0
            package(PackagesReceived + 1: PackagesReceived + BufferSize) = fread(b,BufferSize);
        end
        PackagesReceived = PackagesReceived + BufferSize;
        StopPlot = 1;
        break;
    end
    
    avgTime(k,3) = toc;

    if FormattedToo + PackageSize  <= PackagesReceived
        
        DiffPackage = PackagesReceived - FormattedToo;        % Difference in data received and data formatted
        NewPackagesReceived = floor(DiffPackage/PackageSize); % Full packages received 
        DataToFormat = package(FormattedToo + 1:FormattedToo + NewPackagesReceived*PackageSize); % Seperate new full data package(s)
        
        Formatted = FormatData(Task.Properties.VariableNames, DataToFormat); % Reinterpreted raw BT data
        [n m] = size(Formatted);
        
        % Check if reinterpreted buffersize is exceeded
        if DataRow < DataTrack + n - 1      
            Data = [Data; getMatrix(Task)]; % Reallocate new buffer size
            DataSize = length(Data);
            DataRow = DataSize;
            fprintf('Databuffer reallocated to %i\n', DataSize)
        end

        Data(DataTrack:DataTrack + n - 1, :) = Formatted;               % Store reinterpreted data
        FormattedToo = FormattedToo + NewPackagesReceived*PackageSize;  % Raw data pointer 
        DataTrack = DataTrack + n;                                      % Reinterpreted data pointer
        
        avgTime(k,4) = toc;   
        k  = k + 1;
    end
    
     
    pause(0.0000001); % Necessary to handle stop button...

    if k > 500
       diff([0 mean(avgTime)])
       k = 1;
    end

    
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%% Include "Near Real Time" functionalities below %%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

% Plot example - This is heavy on the computer side and the buffer usage will
% increase over time if used!
if DataTrack - 1 > print200 && StopPlot == 0   % Slow down the graph update speed to freq = 1/print200
   
    if strcmp(Task.Properties.VariableNames,'IMU')
        set(DataPlot,'XData',PlotCount:DataTrack - 1,'YData',Data(PlotCount:DataTrack - 1,VarName.AccX1)); 
    end
   
    if strcmp(Task.Properties.VariableNames,'FSR')
        set(DataPlot,'XData',PlotCount:DataTrack - 1,'YData',Data(PlotCount:DataTrack - 1,VarName.FSR0)); 
    end
    
    if strcmp(Task.Properties.VariableNames,'EMG')
        set(DataPlot,'XData',PlotCount:DataTrack - 1,'YData',Data(PlotCount:DataTrack - 1,VarName.EMG1));
    end
    
    if strcmp(Task.Properties.VariableNames,'All')
        % set(DataPlot,'XData',PlotCount:DataTrack - 1,'YData',Data(PlotCount:DataTrack - 1,VarName.EMG1));
        % set(DataPlot,'XData',PlotCount:DataTrack - 1,'YData',Data(PlotCount:DataTrack - 1,VarName.FSR0)); 
        set(DataPlot,'XData',PlotCount:DataTrack - 1,'YData',Data(PlotCount:DataTrack - 1,VarName.AccX1));
    end
   
   xticks([]);
   xticklabels({});
   hold on;
   drawnow
   axis([DataTrack-2000 DataTrack -10 10])
end

end

fclose(b);

%% Clean and store data in TimeTable
Data = CleanUpData(Data); % Remove zero rows 
DataTable = getTable(Task,Data);
RawDataBT = package(1:PackagesReceived);

%% Plot
plot(BufferTest(1:TimeCounter))
title('Buffer usage over time')
