clc; clear all; close all
% Test normal matrix performance
%% 
Data = zeros(100000,6);
DataDummy = ones(10,6);
timeAvg = zeros(length(Data)/10,2);
track = 1;

for n= 1:floor(length(Data)/10)
   tic;
   Data(track:track + length(DataDummy)-1,:) = DataDummy;
   track = track + length(DataDummy);
   timeAvg(n,1) = toc;
end

%% Table 
track = 1;
Data = table('Size',[100000 6], 'VariableTypes',{'single', 'single', 'single', 'single', 'single', 'single'});

for n= 1:floor(height(Data)/10)
   tic;
   Data{track:track + length(DataDummy)-1,:} = DataDummy;
   track = track + length(DataDummy);
   timeAvg(n,2) = toc;
end


%% AverageTime
mean(timeAvg)