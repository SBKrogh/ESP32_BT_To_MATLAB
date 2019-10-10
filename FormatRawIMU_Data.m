clc; clear all; close all; 
%%
addpath(genpath('TestData'))
% load Dual_IMU_SamePlane.mat
% load Dual_IMU_SamePlane_0_90_-90_0.mat % 0 -> 90  ->  0  ->  -90  -> 0
load Dual_IMU_SamePlane_IMU_diff_Movement.mat % The two IMU can move independten of each other

ColumnNmb = length(package)/24;

IMU_Data = reshape(package,[],ColumnNmb );

x1 = reinterpret_cast(IMU_Data(1:4,:));
y1 = reinterpret_cast(IMU_Data(5:8,:));
z1 = reinterpret_cast(IMU_Data(9:12,:));

x2 = reinterpret_cast(IMU_Data(13:16,:));
y2 = reinterpret_cast(IMU_Data(17:20,:));
z2 = reinterpret_cast(IMU_Data(21:24,:));

IMU = table(x1,y1,z1,x2,y2,z2); % unit vector
[Angle1, Angle2] = AngularEstimation([x1 y1 z1], [x2 y2 z2]);

subplot(2, 1, 1);
plot(IMU.Variables)
legend(IMU.Properties.VariableNames)
title('IMU Acceleration')
ylabel('Acceleration [rad/s^2]')
grid on

subplot(2, 1, 2);
plot(Angle1)
hold on 
plot(Angle2)
legend('Upper arm IMU','Lower arm IMU')
title('Angular Estimation ')
ylabel('Angle [rad]')
xlabel('Sample Number')
grid on

