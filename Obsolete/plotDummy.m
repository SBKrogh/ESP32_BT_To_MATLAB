clc; clear all; close all;
%% 
nmb = 1000;
data = randn(1,nmb);
time = (0:1:(length(data)-1));


dataplotter = plot(data(1),time(1),'-r');
avgTime = zeros(1,nmb);
dummy = 1;
k = 1;

for n = 1:length(time)/10
   
   set(dataplotter,'XData',time(1:n*10),'YData',data(1:n*10));
   axis([n-5000 n -5 5]);
   hold on 
   if n == dummy 
   tic
   drawnow
   dummy = dummy + 1;
   avgTime(k) = toc;
   k = k+1;
   end
end

mean(avgTime(1:max(find(avgTime ~= 0))))

zeros(1,nmb);
figure
for n = 1:nmb
    
    tic
    plot(time(1:100),data(1:100));
    drawnow
    avgTime(k) = toc;
    k = k+1;
end

mean(avgTime(1:max(find(avgTime ~= 0))))