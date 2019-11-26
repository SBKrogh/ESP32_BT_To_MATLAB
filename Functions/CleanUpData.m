%% Remove zero rows from the allocated data buffer
function [CleanData] = CleanUpData(Data)


[~, m] = size(Data);
RowToFind = zeros(1,m);
LocateFirstZeroRow = find(Data == RowToFind);

if isempty(LocateFirstZeroRow)
    CleanData = Data;
    return;
end

CleanData = Data(1:LocateFirstZeroRow(1)-1 ,:);

