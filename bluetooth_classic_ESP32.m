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
%% RTT 


timeAvg = zeros(1000,1);
for n = 1:1000
    time = cputime();
    [LSB MSB] = Split16bitToTwo8bit(uint16(n));
    fwrite(b,MSB);
    fwrite(b,LSB);
    package = fread(b,2);
    concat = bitshift(package(1),8) + package(2);
    
    timeAvg(n) = cputime-time;
    
end
total = mean(timeAvg)
plot(timeAvg)
return
%%
PackageSize = 32;
fwrite(b,1);
timeAvg = zeros(10000,1);
for n = 1:10000
    time = cputime();
    package = fread(b,PackageSize);
    PackAvailable(n) = b.BytesAvailable;
    
    for q = 1:PackageSize-1
        concat(n,q) = bitshift(package(q),8) + package(q+1);
    end
    timeAvg(n) = cputime-time;
    
end
total = mean(timeAvg)
plot(timeAvg)
hold on 
plot(PackAvailable)
%figure

for n=1:PackageSize
   % plot(concat(n:))
end

%% Get curve for visual optimal package size 

fclose(b)
timeAvg = zeros(10000,1);
fopen(b);

for k = 1:50
PackageSize = 32 * k;
fwrite(b,k);
k
for n = 1:floor(1000)
    
         time = cputime();
         package = fread(b,PackageSize);
         PackAvailable(n) = b.BytesAvailable;
         timeAvg1(n) = cputime-time;
    
         for q = 1:PackageSize-1
             concat(n,q) = bitshift(package(q),8) + package(q+1);
         end
         timeAvg2(n) = cputime-time;
    
end
TotalTime1(k) = mean(timeAvg1);
TotalTime2(k) = mean(timeAvg2);
PackageNmb(k) = mean(PackAvailable);
end

figure
plot(PackageNmb)
figure
plot(TotalTime1)
hold on 
plot(TotalTime2)

%%
clc
if strcmp(b.Status,'open')
    fclose(b);
    flushinput(b)
    
end

fopen(b);
PackageSize = 24;
SendTask(b, 'IMU')

    time = cputime();
    package = fread(b,PackageSize)
    % reinterpret_cast(package)
    PackAvailable = b.BytesAvailable;
    

    timeAvg = cputime-time;
    SendTask(b,'Stop');


total = mean(timeAvg)

package = reshape(package,[4,6])

for n = 1:length(package)
    TimeCounter(n) = reinterpret_cast(package(:,n));    
end
TimeCounter

%% Receive and stop test ( 24 bytes reading)
clc
if strcmp(b.Status,'open')
    fclose(b);
    flushinput(b)
end
flushinput(b)
clear counter package;

fopen(b);

ButtonHandle = uicontrol('Style', 'PushButton', ...
                         'String', 'Stop loop', ...
                         'Callback', 'delete(gcbf)');

PackageSize = 24;
SendTask(b, 'IMU')                                          

counter = 1;

while(1)
  BufferSize(counter) = b.BytesAvailable;
  %time = cputime;
  package(:,counter) = fread(b,PackageSize);  
  %time1(counter) = cputime - time;
  counter = counter + 1;
     
  if ~ishandle(ButtonHandle)
      SendTask(b,'Stop');
      disp('Loop stopped by user');
      while(PackageSize < b.BytesAvailable)
             package(:,counter) = fread(b,PackageSize); 
             counter = counter + 1;
      end
    pause(0.5);
    break;
  end
  pause(0.000001);
end

fclose(b); 
fprintf('The number of received packages is equal to %i \n',length(package))
plot(BufferSize)
mean(BufferSize)


%% Receive and stop test ( Nmb of bytes in the buffer reading)
% This solution is too slow ! 
clc
if strcmp(b.Status,'open')
    fclose(b);
    flushinput(b)
end
flushinput(b)
clear counter package;

fopen(b);

ButtonHandle = uicontrol('Style', 'PushButton', ...
                         'String', 'Stop loop', ...
                         'Callback', 'delete(gcbf)');

PackageSize = 24;
SendTask(b, 'IMU')                                          

counter = 1;
package = fread(b,24);
TimeCounter = 1;
while(1)
  BufferSize(counter) = b.BytesAvailable;
  
  if BufferSize(counter) > 0
    time = cputime;
    package = [package; fread(b,BufferSize(counter))]; % This solution is too slow ! 
    time1(TimeCounter) = cputime - time;
    TimeCounter = TimeCounter + 1;
  end
  
  if ~ishandle(ButtonHandle)
      SendTask(b,'Stop');
      pause(0.5)
      disp('Loop stopped by user');
      BytesAvailable = b.BytesAvailable;
      if BytesAvailable > 0
            package = [package; fread(b,BytesAvailable)]; 
      end
    break;
  end
  pause(0.000001);
  counter = counter + 1;
end

fclose(b); 

plot(BufferSize)
mean(BufferSize)
length(package)/24 - 1

%% Receive and stop test ( Nmb of bytes in the buffer reading)
% This solution is too slow ! 
clc
if strcmp(b.Status,'open')
    fclose(b);
    flushinput(b)
end
flushinput(b)
clear counter package;

fopen(b);

ButtonHandle = uicontrol('Style', 'PushButton', ...
                         'String', 'Stop loop', ...
                         'Callback', 'delete(gcbf)');

PackageSize = 24;
SendTask(b, 'IMU')                                          

counter = 1;
package = fread(b,24);
TimeCounter = 1;

while(1)
  BufferSize(counter) = b.BytesAvailable;
  
  if BufferSize(counter) > 0
    time = cputime;
    package = cat(1,package,fread(b,BufferSize(counter))); % This solution is too slow ! 
    time1(TimeCounter) = cputime - time;
    TimeCounter = TimeCounter + 1;
  end
  
  if ~ishandle(ButtonHandle)
      SendTask(b,'Stop');
      pause(0.5)
      disp('Loop stopped by user');
      BytesAvailable = b.BytesAvailable;
      if BytesAvailable > 0
            package = cat(1,package,fread(b,BufferSize(counter))); 
      end
    break;
  end
  pause(0.000001);
  counter = counter + 1;
end

fclose(b); 

plot(BufferSize)
mean(BufferSize)
length(package)/24 - 1


%% Receive and stop test ( Nmb of bytes in the buffer reading)
% "Works"
clc

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