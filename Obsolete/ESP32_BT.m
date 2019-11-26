clc; clear all; close all; delete(instrfind)
% Note: Please pair the BT with Windows before running this script:
% Windows start button -> Bluetooth & other devices -> Enable Bluetooth and
% pair with ESP32..
%
% Troubleshooting https://se.mathworks.com/help/instrument/troubleshooting-bluetooth-interface.html

%% Create BT connection to ESP32
b = EstablishConnectionBT();

%% Send 
SendTaskESP32(b, 'Test')
pause(0.0001);
% fclose(b);

%% Functions 
function [] = SendTaskESP32(ObjBT, Task)
fwrite(ObjBT, Task)
end

%%
