clc; clear all; close all; delete(instrfind)
% Note: Please pair the BT with Windows before running this script:
% Windows start button -> Bluetooth & other devices -> Enable Bluetooth and
% pair with ESP32..
%
% Troubleshooting https://se.mathworks.com/help/instrument/troubleshooting-bluetooth-interface.html

%% Create BT connection to ESP32
% It might be a good idea to restart matlab if the BT connection has been
% established before and was not properly disconnected!
% call:: restart_matlab()

b = EstablishConnectionBT();

%% Define task implmented on ESP32 and its package size
% If additional tasks are included, remember to include these to the 
% function: getTable()
FSR = 16;                           % Bytes
IMU = 48;                           % Bytes -> Accleration only
EMG = 8;                            % Bytes
All = FSR + IMU  + EMG;             % Bytes

TaskAvailable = table(FSR,IMU,EMG,All);
clear FSR IMU EMG All

%% Specify task - input by user Keyboard
% prompt = 'Specify task of interest\nFSR, IMU, EMG or All\n';
% while 1
%     TaskInput = input(prompt, 's');
%     if strcmp(TaskInput,'stop')
%         return
%     end
%     if sum(strcmp(TaskInput,TaskAvailable.Properties.VariableNames))
%         fprintf('Task exists\n')
%         Task = TaskAvailable(:,TaskInput);
%         break
%     else
%         clc
%         fprintf('Task: %s, - did not exist - Try again or type "stop" to end program\n\n',TaskInput)
%     end
% end

%% Receive and stop BT communication
clear counter package; % Clear memory if they exists
TaskInput = 'IMU';             % Erase this when done testing!!!!!!!!
Task = TaskAvailable(:,'IMU'); % Erase this when done testing!!!!!!!!

PackageSize = TaskAvailable.(TaskInput);     % Task package size - bytes
TestTime = 0.5*60;                           % Test time in seconds 
fHz = 1000;                                  % Sample frequency
ArraySize = PackageSize * TestTime*60 * fHz; % Specify memory alocation
BufferSizeSaftyMargin = 0;                   % Increase this if additional buffermargin is necessary


package = zeros(ArraySize, 1); % Allocate memory for raw BT data
Data = getTable(Task);         % Return inital table for storing reinterpreted data
DataRow = height(Data);

DataDummy = getTableDummy();

if strcmp(b.Status,'open') % Used to close the BT communication.
    fclose(b);             % Usefull when ESP32 is restarting and
    flushinput(b)          % communication should be established.
end
flushinput(b)

ButtonHandle = uicontrol('Style', 'PushButton', ...  % Stop button
    'String', 'Stop loop', ...
    'Callback', 'delete(gcbf)');

TimeCounter = 1;                 % Counter for buffer readings
BufferTest = zeros(ArraySize,1); % Used to store buffer size usage

PrintTime = 0;

fopen(b);                                         % Enable BT communcation
SendTask(b, char(Task.Properties.VariableNames)); % Initiate the IMU data collection
package(1:PackageSize) = fread(b,PackageSize);    % First data package received
% package = fread(b,PackageSize);    % First data package received
PackagesReceived = PackageSize;                   % Byte received counter
DataTrack = 1;                                    % Keep track of reinterpreted data stored

FormattedToo = 0;       % How much data is formatted
ii = 1;
avgTime = zeros(500,4);
k = 1;
while(1)

    BufferSize = b.BytesAvailable;    % Check if data in buffer is available
        
    if BufferSize + PackagesReceived + BufferSizeSaftyMargin > ArraySize    % Check if allocated space is exceeded
        package = cat(1,package, zeros(PackagesReceived,1));                % Increase allocation of memory
        ArraySize = length(package);
        fprintf('packagebuffer reallocated to %i\n', ArraySize)
    end
    % avgTime(k,1) = toc;
    
    
    if BufferSize > 0 % Check if bytes are received
        package(PackagesReceived + 1: PackagesReceived + BufferSize) = fread(b,BufferSize); % Store data in allocated memory
        BufferTest(TimeCounter) = BufferSize;               % Store buffer usage before reading
        TimeCounter = TimeCounter + 1;                      % Counter for buffer readings
        PackagesReceived = PackagesReceived + BufferSize;   % Increase byte counter received.
    end
    % avgTime(k,2) = toc;
    
    if ~ishandle(ButtonHandle)          % Stops program if stop button is pushed
        SendTask(b,'Stop');             % Stop ESP32 task
        pause(0.5)                      % Wait for ESP32 to empty output buffer
        disp('Loop stopped by user');   %
        BufferSize = b.BytesAvailable;  % Read amount of available bytes - Necessary for proper if statement handling
        if BufferSize > 0
            package(PackagesReceived + 1: PackagesReceived + BufferSize) = fread(b,BufferSize);
        end
        PackagesReceived = PackagesReceived + BufferSize;
        break;
    end
    
    % avgTime(k,3) = toc;

%    % Comment this statement out for continues run time
%     if toc > (TestTime)        % Stops program if time is exceded
%         SendTask(b,'Stop');
%         pause(0.5)             % Wait for ESP32 output buffer to be emptied
%         disp('Run time over');
%         BufferSize = b.BytesAvailable;
%         if BufferSize > 0
%             package(PackagesReceived + 1: PackagesReceived + BufferSize) = fread(b,BufferSize); % Read Matlab input buffer
%         end
%         PackagesReceived = PackagesReceived + BufferSize;   % Increase byte received counter.
%         break;
%     end
%     
%     if PrintTime + 10 < toc % Display time usage
%         toc
%         PrintTime = toc;
%     end
    
    if FormattedToo + PackageSize  <= PackagesReceived
        tic
        DiffPackage = PackagesReceived - FormattedToo;        % Difference in data received and data formatted
        NewPackagesReceived = floor(DiffPackage/PackageSize); % Full packages received 
        DataToFormat = package(FormattedToo + 1:FormattedToo + NewPackagesReceived*PackageSize); % Seperate new full data package(s)
        
        avgTime(k,1) = toc;
        
        Formatted = FormatData(Task.Properties.VariableNames, DataToFormat);
        [n m] = size(Formatted);
        
        avgTime(k,2) = toc;
        
        if DataRow < DataTrack + n - 1
            Hold = 1
            Data = [Data; getTable(Task)];
            DataSize = height(Data);
            DataRow = DataSize;
            fprintf('Databuffer reallocated to %i\n', DataSize)
        end
        
        avgTime(k,3) = toc; 
        
        Data{DataTrack:DataTrack + n - 1, :} = Formatted;
        
        avgTime(k,4) = toc;
        
        FormattedToo = FormattedToo + NewPackagesReceived*PackageSize;
        DataTrack = DataTrack + n;
        
        
        k  = k + 1;
    end

    % avgTime(k,4) = toc;
        
    pause(0.0000001); % Necessary to handle stop button...
    
    
    
    if k > 500
       mean(avgTime)
       k = 1;
    end
    
    
end

fclose(b);
plot(BufferTest(1:TimeCounter))
title('Buffer usage over time')
% figure
% plot(time1(1:TimeCounter))
% title('Time used to read buffer')


fprintf('Average buffer usage while reading  %i\n',mean(BufferTest(1:TimeCounter)))
fprintf('Packages received  %i\n',length(package)/24 - 1)

package = package(1:PackagesReceived);
% save('Dual_IMU_SamePlane_IMU_diff_Movement.mat','package')