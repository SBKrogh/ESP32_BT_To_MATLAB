function [b] = EstablishConnectionBT()

delete(instrfind)

if isfile('PreviousChannelSelected.mat')
    load('PreviousChannelSelected.mat')
else
    channel = 1;
end

try
    b = Bluetooth('Exo-Aider ESP32',channel,'Timeout',3);
    fopen(b);
catch me
    fprintf(['Initial channel selected did not work\n',...
        'Brute Force channel selection initiated\n',...
        'This might take a while\n\n']);
    b = BruteForceChannelSelectionBT();
end
channel = b.Channel;
save('PreviousChannelSelected.mat', 'channel');
fclose(b);
b.InputBufferSize = 4096*2;
fopen(b);