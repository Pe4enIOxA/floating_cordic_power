% This script for calculating LUT

%Generate input
x = -7:0;;
xm = (power(2,x));
xn = atanh(1-xm)
fx = num2hex(single(xn))
%% Generate input
y = 1:16;;
ym = (power(2,y));
yn = atanh(ym)
ff = (single(real(yn)))
fy = num2hex(single(real(yn)))

% %% File ID
% fileID = fopen('LUT32.txt','w');
% 
% %% Print
% fprintf(fileID, '%s\n',fx);
% fprintf(fileID, '%s\n',fy);
% 
% fclose(fileID);

% %%  1st LUT
% for i = 1:8
%     a = fx(i);
%     fprintf(fileID, '%s\n', a.hex);
% end
% 
% for i = 1:16
%     a = fy(i);
%     fprintf(fileID, '%s\n', a.hex);
% end
