%% Return reinterpreted raw BT data
function [FormattedData] = FormatData(TaskName, DataToFormat)

%% IMU
% Sample IMU data only [IMU1x, IMU1y, IMU1z, IMU2x, IMU2y, IMU2z]
if strcmp(TaskName,'IMU')
    % DataToFormat = reshape(DataToFormat,[4,length(DataToFormat)/4]);
    DataToFormat = uint8(reshape(DataToFormat,[4,length(DataToFormat)/4]));
    FormattedData = zeros(length(DataToFormat),1);
    for k = 1:length(DataToFormat);
        % x = uint8([DataToFormat(1,k) DataToFormat(2,k) DataToFormat(3,k) DataToFormat(4,k)]);
        x = [DataToFormat(1,k) DataToFormat(2,k) DataToFormat(3,k) DataToFormat(4,k)];
        FormattedData(k) = typecast(x,'single');
    end
    FormattedData = transpose( reshape(FormattedData,[6, length(FormattedData)/6]) );
end

%% All
% Samples FSR, EMG and IMU data [FSR[16], EMG[8], IMU[24]]
% if strcmp(TaskName,'All')
%     DataToFormat = reshape(DataToFormat,[72,length(DataToFormat)/72]); % 72 bytes for a full data frame
%     FormattedData = zeros(length(DataToFormat)/72, 18);                    % 18 readings for all sensor input, increase to 24 if Gyro are included...
%     
%     % FSR
%     for n = 1:length(FormattedData)
%         DataToFormat(1:8, n) = typecast(int8([1 0]),'uint16');
%     
%     end    
%     
%     
%     for k = 1:length(DataToFormat)
%         x = uint8([DataToFormat(1,k) DataToFormat(2,k) DataToFormat(3,k) DataToFormat(4,k)]);
%         FormattedData(k) = typecast(x,'single');
%     end
%     FormattedData = transpose( reshape(FormattedData,[6, length(FormattedData)/6]) );
% end

%% FSR
% if strcmp(TaskName,'FSR')
%     DataToFormat = reshape(DataToFormat,[4,length(DataToFormat)/4]); 
%     FormattedData = zeros(length(DataToFormat),1);
%     for k = 1:length(DataToFormat)
%         x = uint8([DataToFormat(1,k) DataToFormat(2,k) DataToFormat(3,k) DataToFormat(4,k)]);
%         FormattedData(k) = typecast(x,'single');
%     end
%     FormattedData = transpose( reshape(FormattedData,[6, length(FormattedData)/6]) );
% end

%% EMG
% if strcmp(TaskName,'EMG')
%     DataToFormat = reshape(DataToFormat,[4,length(DataToFormat)/4]); 
%     FormattedData = zeros(length(DataToFormat),1);
%     for k = 1:length(DataToFormat)
%         x = uint8([DataToFormat(1,k) DataToFormat(2,k) DataToFormat(3,k) DataToFormat(4,k)]);
%         FormattedData(k) = typecast(x,'single');
%     end
%     FormattedData = transpose( reshape(FormattedData,[6, length(FormattedData)/6]) );
% end


