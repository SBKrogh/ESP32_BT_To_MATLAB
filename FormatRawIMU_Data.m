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







%% Initial angle 
% https://gist.github.com/kevinmoran/b45980723e53edeb8a5a43c49f134724
return
VectorReference = [1 0 0]; % Ideally the initial vector should only affect the one axis 




%% State space
% Do not work - also a bit cheating compared to measurements of
% posistion...
return
IMU.Variables = detrend(IMU.Variables);

figure 
plot(IMU.Variables)
legend(IMU.Properties.VariableNames)
title('IMU Data')
grid on

Ts = 1/1000;

A = [eye(3) eye(3)*Ts zeros(3); zeros(3) eye(3) eye(3)*Ts; zeros(3,6) eye(3)]; % Position, Velocity and Acceleration
B = [zeros(9,3) eye(9)];
C = [eye(3) zeros(3) zeros(3); zeros(3,6) eye(3)] ;
D = zeros(6,12);

sysd = ss(A,B,C,D,Ts);
Q = diag([100 100 100 100 100 100 1000 1000 1000]);
R = diag([10000 10000 10000 1 1 1]);

[kest,L,P] = kalman(sysd,Q,R,zeros(9,6));

% x* = Ax + Bu
% y  = Cx + Du


xInit = [0 0 0 0 0 0 IMU.x1(1) IMU.y1(1) IMU.z1(1)]';
xpre(:,1) = A*xInit;

for n = 2:length(IMU.x1)
    xpre(:,n) = A*xpre(:,n-1) + L * ( [xpre(1:3,n-1); IMU.x1(1); IMU.y1(1); IMU.z1(1)] - C*xpre(:,n-1));
end










