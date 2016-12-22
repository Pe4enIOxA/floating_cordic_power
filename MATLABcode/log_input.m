%% This script generates the in_bench.txt (input data for final project test
%  bench). By Kazumi Malhan

% input generation for log
% Obtain file ID for in_bench.txt
fileID = fopen('in_bench_ln.txt','w');

%% For Rotation Mode
zr = 0.1:1:200;
zr1 = zr + 1;
zr2 = zr - 1;
%%
zrf = 210:100000000:(6.215*10^10);
zrf1 = zrf + 1;
zrf2 = zrf - 1;

for i = 1:200    
ZR1 = num2hex(double(zr1(i)));
    fprintf(fileID, '%s\n', ZR1);
    ZR2 = num2hex(double(zr2(i)));
    fprintf(fileID, '%s\n', ZR2);
end
for i = 1:622    
ZR1 = num2hex(double(zrf1(i)));
    fprintf(fileID, '%s\n', ZR1);
    ZR2 = num2hex(double(zrf2(i)));
    fprintf(fileID, '%s\n', ZR2);
end

fclose(fileID);