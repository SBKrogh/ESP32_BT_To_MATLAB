clc; clear all; close all; 
%%
addpath(genpath('TestData'))
load Dual_IMU_SamePlane.mat

ColumnNmb = length(package)/24;

IMU_Data = reshape(package,[],ColumnNmb );

x1 = reinterpret_cast(IMU_Data(1:4,:));
y1 = reinterpret_cast(IMU_Data(5:8,:));
z1 = reinterpret_cast(IMU_Data(9:12,:));

x2 = reinterpret_cast(IMU_Data(13:16,:));
y2 = reinterpret_cast(IMU_Data(17:20,:));
z2 = reinterpret_cast(IMU_Data(21:24,:));

IMU = table(x1,y1,z1,x2,y2,z2);

plot(IMU.Variables)
legend(IMU.Properties.VariableNames)
title('IMU Data')
grid on