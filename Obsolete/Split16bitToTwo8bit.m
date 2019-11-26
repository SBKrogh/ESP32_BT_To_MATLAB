function [LSB MSB] = Split16bitToTwo8bit(Value)

temp = typecast(Value,'uint8');
LSB = temp(1);
MSB = temp(2);
