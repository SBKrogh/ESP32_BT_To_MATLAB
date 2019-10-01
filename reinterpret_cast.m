% Reinterprete four uint8 bytes IMU data to float
% Input array should only contain full packages ie. length(IMU_Array)/24 = int 
% See example in FormatRawIMU_Data.m

function y = reinterpret_cast(IMU_Array)

ArraySize = length(IMU_Array);
y = zeros(ArraySize,1);

for n = 1:length(IMU_Array)
    x = uint8([IMU_Array(1,n) IMU_Array(2,n) IMU_Array(3,n) IMU_Array(4,n)]);
    y(n) = typecast(x,'single');
end