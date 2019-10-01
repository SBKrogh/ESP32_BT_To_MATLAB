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


return
%% Receive and stop test ( Nmb of bytes in the buffer reading)
clear counter package; 

PackageSize = 24;   % IMU
TestTime = 0.5;      % Minutes
fHz = 1000;         % Sample frequency
ArraySize = PackageSize * TestTime*60 * fHz % Specify size of Array for alocation 
PrintTime = 0;

package = zeros(ArraySize, 1); % Allocate memory

if strcmp(b.Status,'open') % Used to close the BT communication. 
    fclose(b);             % Usefull when ESP32 is restarting and
    flushinput(b)          % communication should be established.
end
flushinput(b)


fopen(b);   % Enable BT communcation 

ButtonHandle = uicontrol('Style', 'PushButton', ...  % Stop button
                         'String', 'Stop loop', ...
                         'Callback', 'delete(gcbf)');

SendTask(b, 'IMU') % Initiate the IMU data collection                                       

counter = 1;
TimeCounter = 1;

BufferTest = zeros(ArraySize,1);
time1 = zeros(ArraySize,1);

tic 
package(1:PackageSize) = fread(b,PackageSize); % First data package received 
PackagesReceived = PackageSize;

while(1)
  BufferSize = b.BytesAvailable;
  
  if BufferSize + PackagesReceived > ArraySize % Check if Allocated space is exceeded
     TempBuffer = package; 
     package = cat(1,package, zeros(PackagesReceived,1));
     ArraySize = length(package);  
     fprintf('Databuffer reallocated to %i\n', ArraySize)
  end
  
  if BufferSize > 0 % Check if bytes is received
    time = cputime;
    package(PackagesReceived + 1: PackagesReceived + BufferSize) = fread(b,BufferSize); 
    BufferTest(TimeCounter) = BufferSize;
    time1(TimeCounter) = cputime - time;
    TimeCounter = TimeCounter + 1;
    PackagesReceived = PackagesReceived + BufferSize;
  end
  
  if ~ishandle(ButtonHandle) % Stops program if stop button is pushed
      SendTask(b,'Stop');
      pause(0.5)
      disp('Loop stopped by user');
      BufferSize = b.BytesAvailable;
      if BufferSize > 0
            package(PackagesReceived + 1: PackagesReceived + BufferSize) = fread(b,BufferSize);  
      end
      PackagesReceived = PackagesReceived + BufferSize;
    break;
  end
  
  if toc > (TestTime * 60) % Stops program if time is exceded 
      SendTask(b,'Stop');
      pause(0.5)
      disp('Run time over');
      BufferSize = b.BytesAvailable;
      if BufferSize > 0
            package(PackagesReceived + 1: PackagesReceived + BufferSize) = fread(b,BufferSize);  
      end
      PackagesReceived = PackagesReceived + BufferSize;
      break;
  end
  
  if PrintTime + 10 < toc
      toc
      PrintTime = toc;
  end
  
  pause(0.000001); % Needed to handle stop button...
end

fclose(b); 
plot(BufferTest(1:TimeCounter))
title('Buffer usage over time')
mean(BufferTest(1:TimeCounter))
figure 
plot(time1(1:TimeCounter))
title('Time used to read buffer')
length(package)/24 - 1
package = package(1:PackagesReceived);
% save('Dual_IMU_SamePlane_IMU_diff_Movement.mat','package')