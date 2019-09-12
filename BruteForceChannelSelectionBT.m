function [b] = BruteForceChannelSelectionBT(channel)
for n = 0:40
    if n ~= channel
        try
            b = Bluetooth('Exo-Aider ESP32',n);
            fopen(b);
        catch me
            fprintf('Channel number %d: Unsuccessful\n',n)
        end
        
        if strcmp(b.Status,'open')
            fprintf('Channel number %d: Successful\n',n)
            break
        end
    end
end