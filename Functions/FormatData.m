%% Return reinterpreted raw BT data
function [FormattedData] = FormatData(TaskName, DataToFormat)

%% IMU
% Sample IMU data only [IMU1x, IMU1y, IMU1z, IMU2x, IMU2y, IMU2z]
if strcmp(TaskName,'IMU')
    DataToFormat = uint8(reshape(DataToFormat,[4,length(DataToFormat)/4]));
    FormattedData = zeros(length(DataToFormat),1);
    for k = 1:length(DataToFormat)
        x = [DataToFormat(1,k) DataToFormat(2,k) DataToFormat(3,k) DataToFormat(4,k)];
        FormattedData(k) = typecast(x,'single');
    end
    FormattedData = transpose( reshape(FormattedData,[6, length(FormattedData)/6]) );
end

%% FSR
% [FSR0 FSR1 FSR2 FSR3 FSR4 FSR5 FSR6 FSR7]
if strcmp(TaskName,'FSR')
    DataToFormat = uint8(reshape(DataToFormat,[4,length(DataToFormat)/4]));
    FormattedData = zeros(length(DataToFormat),1);
    for k = 1:length(DataToFormat)
        x = [DataToFormat(1,k) DataToFormat(2,k) DataToFormat(3,k) DataToFormat(4,k)];
        FormattedData(k) = typecast(x,'single');
    end
    FormattedData = transpose( reshape(FormattedData,[8, length(FormattedData)/8]) );
end

%% EMG
% [EMG1 EMG2 EMG3 EMG4]
if strcmp(TaskName,'EMG')
    DataToFormat = uint8(reshape(DataToFormat,[4,length(DataToFormat)/4]));
    FormattedData = zeros(length(DataToFormat),1);
    for k = 1:length(DataToFormat)
        x = [DataToFormat(1,k) DataToFormat(2,k) DataToFormat(3,k) DataToFormat(4,k)];
        FormattedData(k) = typecast(x,'single');
    end
    FormattedData = transpose( reshape(FormattedData,[4, length(FormattedData)/4]) );
end

%% All
% Samples FSR, EMG and IMU data float[FSR[8], EMG[4], IMU[6]]
if strcmp(TaskName,'All')
    DataToFormat = uint8(reshape(DataToFormat,[72,length(DataToFormat)/72])); % 72 bytes for a full data frame
    
    [~, n] = size(DataToFormat); % [[FSR[8], EMG[4], IMU[6]] ,Dataframes]
    FormattedData = zeros(n,18); % [Dataframes, FSR+EMG+IMU]
    
    
    FSR = reshape(DataToFormat(1:32,:), [numel(DataToFormat(1:32,:)) , 1]);
    FSR = reshape(FSR,[4, length(FSR)/4]);
    FSRData = zeros(length(FSR),1);
    
    EMG = reshape(DataToFormat(33:48,:),[numel(DataToFormat(33:48,:)), 1]);
    EMG = reshape(EMG,[4,length(EMG)/4]);
    EMGData = zeros(length(EMG),1);
    
    IMU = reshape(DataToFormat(49:72,:),[numel(DataToFormat(49:72,:)), 1]);
    IMU = reshape(IMU,[4,length(IMU)/4]);
    IMUData = zeros(length(IMU),1);
    
    for k = 1:length(FSR)
        x = [FSR(1,k) FSR(2,k) FSR(3,k) FSR(4,k)];
        FSRData(k) = typecast(x,'single');
    end
    
    for k = 1:length(EMG)
        x = [EMG(1,k) EMG(2,k) EMG(3,k) EMG(4,k)];
        EMGData(k) = typecast(x,'single');
    end
    
    for k = 1:length(IMU)
        x = [IMU(1,k) IMU(2,k) IMU(3,k) IMU(4,k)];
        IMUData(k) = typecast(x,'single');
    end
    
    FormattedData(:,1:8)    = transpose( reshape(FSRData,[8, length(FSRData)/8]));
    FormattedData(:,9:12)   = transpose( reshape(EMGData,[4, length(EMGData)/4]));
    FormattedData(:,13:18)  = transpose( reshape(IMUData,[6, length(IMUData)/6]));

    
end





