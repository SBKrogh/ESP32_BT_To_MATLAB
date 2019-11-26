function [] = SendTask(ObjBT, Task)

fwrite(ObjBT, Task)
fwrite(ObjBT, '//')  % End command 