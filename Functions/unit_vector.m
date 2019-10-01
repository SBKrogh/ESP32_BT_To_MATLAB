function [x, y, z, angle] = unit_vector(vector_acc_xyz)

ArraySize = length(vector_acc_xyz);
UnitVectorScalar = zeros(ArraySize);
ReturnArray = zeros(ArraySize,3);

VectorReference = [1 0 0]'; % force vector of reference. 

for n = 1:ArraySize
   UnitVectorScalar(n) = norm([vector_acc_xyz(n,1) vector_acc_xyz(n,2) vector_acc_xyz(n,3)]);
end

for n = 1:ArraySize
    ReturnArray(n,:) = vector_acc_xyz(n,:)/UnitVectorScalar(n);
end

% https://gist.github.com/kevinmoran/b45980723e53edeb8a5a43c49f134724
% We also know the dot product of two unit vectors is equal to the cosine 
% of the angle between them, so we calculate that and call acos() 
% (the inverse cosine) to get the desired angle.

dotproduct = ReturnArray*VectorReference;
angle = acos(dotproduct);

x = ReturnArray(:,1);
y = ReturnArray(:,2);
z = ReturnArray(:,3);

