% This is a rough angular estimate as it do not take the gravitational effect into consideration! 
% This will only work for a movement in a 2D plane!
% In a stationary position the precision of the estimation is at it highest.
%
% Input: IMU_Up_Acceleration -> upper arm IMU data set
% Input: IMU_Low_Acceleration -> Lower arm IMU data set
% Return: AngleUp -> The angle between the vector of reference (the axsis
% perpendicular to ground) 
% Return: AngleLow -> The angle between the two IMUs 

function [AngleUp, AngleLow] = AngularEstimation(IMU_Up_Acceleration, IMU_Low_Acceleration)

ArraySize = length(IMU_Up_Acceleration);    % Used for allocation of memory
UnitVectorScalar1 = zeros(ArraySize);       % Allocated space
UnitVectorScalar2 = zeros(ArraySize);       % Allocated space
NormUp = zeros(ArraySize,3);               % Allocated space
NormLow = zeros(ArraySize,3);              % Allocated space

VectorReference = [1 0 0]';                 % Force vector of reference. 

% Normalize row vector
for n = 1:ArraySize
   UnitVectorScalar1(n) = norm([IMU_Up_Acceleration(n,1) IMU_Up_Acceleration(n,2) IMU_Up_Acceleration(n,3)]);
   UnitVectorScalar2(n) = norm([IMU_Low_Acceleration(n,1) IMU_Low_Acceleration(n,2) IMU_Low_Acceleration(n,3)]);
   
   NormUp(n,:) = IMU_Up_Acceleration(n,:)/UnitVectorScalar1(n);
   NormLow(n,:) = IMU_Low_Acceleration(n,:)/UnitVectorScalar2(n);
end


% https://gist.github.com/kevinmoran/b45980723e53edeb8a5a43c49f134724
% We also know the dot product of two unit vectors is equal to the cosine 
% of the angle between them, so we calculate that and call acos() 
% (the inverse cosine) to get the desired angle.

dotproductUp = NormUp*VectorReference;
AngleUp = acos(dotproductUp);

dotproductLow = dot(NormLow',NormUp');
AngleLow = acos(dotproductLow);


