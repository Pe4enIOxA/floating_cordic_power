%% This script generates the in_bench.txt (input data for final project test
%  bench). By Kazumi Malhan

% input generation for ex
% Obtain file ID for in_bench.txt
fileID = fopen('in_bench_ex.txt','w');

% For Rotation Mode
zr = -12.42:0.1:12.42;

for i = 1:249
    
ZR = num2hex(double(zr(i)));
    fprintf(fileID, '%s\n', ZR);
end
fclose(fileID);