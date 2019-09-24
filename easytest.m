function [] = easytest(b, command)

fclose(b);
fopen(b);
SendTask(b,command);