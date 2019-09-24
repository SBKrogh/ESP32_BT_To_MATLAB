% 82        184     14          65
% 01010010 10111000 00001110 01000001
% float 8.92
function y = reinterpret_cast(IMU_Array)
x = uint8([IMU_Array(1) IMU_Array(2) IMU_Array(3) IMU_Array(4)]);
y = typecast(x,'single');