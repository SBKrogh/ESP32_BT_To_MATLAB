clc; clear all; close all; delete(instrfind)
% Troubleshooting https://se.mathworks.com/help/instrument/troubleshooting-bluetooth-interface.html

%% Create BT connection to ESP32
% It might be a good idea to restart matlab if the BT connection has been 
% established before and was not properly disconnected!
% call:: restart_matlab() 

if isfile('PreviousChannelSelected.mat')
    load('PreviousChannelSelected.mat')
else
    channel = 1;
end

try
    b = Bluetooth('Exo-Aider ESP32',channel);
    fopen(b);
catch me
    fprintf(['Initial channel selected did not work\n',...
        'Brute Force channel selection initiated\n',...
        'This might take a while\n\n']);
    b = BruteForceChannelSelectionBT(channel);
end
channel = b.Channel;
save('PreviousChannelSelected.mat', 'channel');

%%
for n = 0:1000
fwrite(b,n)

fread(b,4)
end

