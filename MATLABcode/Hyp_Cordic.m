function powerout =Hyp_Cordic(xgo,ygo)
%%
mode = 1; %0;
An = 5.0382e-04;

%for Angle=1:N    
% xgo = 10
% ygo = 2
xn(1) = xgo + 1; %1/An %1.25;
yn(1) = xgo - 1; %1/An; %1.25; %0.9947;%0.994731;
zn(1) = 0; %2;
% xn(1) = 0;
% yn(1) = 1;
% zn(1) = 0.7857;

k = 4;
P = 16;
N = -5;

% disp([num2str(1,2), '  ', num2str(xn(1),'%f'), '  ', num2str(yn(1),'%f') ,'  ', num2str(zn(1),'%f')]);    
for j=N:0
    index = j+6;
    if(mode == 0)
        if (zn(index) < 0)   
            gama = -1;
        else
            gama = 1;
        end
    else
        if (xn(index)*yn(index) >= 0)   
            gama = -1;
        else
            gama = 1;
          end        
    end
    xn(index+1) = xn(index) + gama*yn(index) - gama*yn(index)*power(2, j-2);
    yn(index+1) = yn(index) + gama*xn(index) - gama*xn(index)*power(2, j-2);
    zn(index+1) = zn(index) - gama*atanh(1-power(2, j-2));    
%     disp([num2str(index+1,2), '  ', num2str(xn(index+1),'%f'), '  ', num2str(yn(index+1),'%f') ,'  ', num2str(zn(index+1),'%f'), '  ', num2str(gama)]);    
end
    x(1) = xn(index+1);
    y(1) = yn(index+1);
    z(1) = zn(index+1);
    disp(['   ']);
%     disp([num2str(1,2), '  ', num2str(z(1))]); 
%     disp([num2str(i+1,2), '  ', num2str(x(i+1),'%f'), '  ', num2str(y(i+1),'%f') ,'  ', num2str(z(i+1),'%f'), '  ', num2str(gama)]);

for i=1:P
    if(mode == 0)   
        if (z(i) < 0)   
            gama = -1;
        else
            gama = 1;
        end
    else
        if (x(i)*y(i) >= 0)   
            gama = -1;
        else
            gama = 1;
        end        
    end
    x(i+1) = x(i) + gama*y(i)*power(2, -1*i);
    y(i+1) = y(i) + gama*x(i)*power(2, -1*i);
    z(i+1) = z(i) - gama*atanh(power(2, -1*i));
        
    if(i == k)
%         disp(['         ', num2str(i+1,2), '  ', num2str(z(i+1))]);    
        if(mode == 0)
            if (z(i+1) < 0)   
                gama = -1;
            else
                gama = 1;
            end
        else
            if (x(i+1)*y(i+1) >= 0)   
                gama = -1;
            else
                gama = 1;
            end        
        end
        xtemp(i+1) = x(i+1) + gama*y(i+1)*power(2, -1*(i));%%%%%%%%%%%%%%%%%%%%%%%
        y(i+1) = y(i+1) + gama*x(i+1)*power(2, -1*(i));
        z(i+1) = z(i+1) - gama*atanh(power(2, -1*(i))); 
        x(i+1) = xtemp(i+1);%%%%%%%%%%%%%%%%%%%%%%%%
        k = 3*k + 1;
%         disp([num2str(i+1,2), '  ', num2str(x(i+1),'%f'), '  ', num2str(y(i+1),'%f') ,'  ', num2str(z(i+1),'%f'), '  ', num2str(gama)]);
    end
%     disp([num2str(i+1,2), '  ', num2str(x(i+1),'%f'), '  ', num2str(y(i+1),'%f') ,'  ', num2str(z(i+1),'%f'), '  ', num2str(gama)]);    
end
    

zgo = z(17) * ygo;
%%
xn(1) = 1/An; %1/An %1.25;
yn(1) = 1/An; %1/An; %1.25; %0.9947;%0.994731;
zn(1) = zgo; %2;
% xn(1) = 0;
% yn(1) = 1;
% zn(1) = 0.7857;
mode = 0;

% disp([num2str(1,2), '  ', num2str(xn(1),'%f'), '  ', num2str(yn(1),'%f') ,'  ', num2str(zn(1),'%f')]);    
for j=N:0
    index = j+6;
    if(mode == 0)
        if (zn(index) < 0)   
            gama = -1;
        else
            gama = 1;
        end
    else
        if (xn(index)*yn(index) >= 0)   
            gama = -1;
        else
            gama = 1;
          end        
    end
    xn(index+1) = xn(index) + gama*yn(index) - gama*yn(index)*power(2, j-2);
    yn(index+1) = yn(index) + gama*xn(index) - gama*xn(index)*power(2, j-2);
    zn(index+1) = zn(index) - gama*atanh(1-power(2, j-2));    
%     disp([num2str(index+1,2), '  ', num2str(xn(index+1),'%f'), '  ', num2str(yn(index+1),'%f') ,'  ', num2str(zn(index+1),'%f'), '  ', num2str(gama)]);    
end
    x(1) = xn(index+1);
    y(1) = yn(index+1);
    z(1) = zn(index+1);
    disp(['   ']);
%     disp([num2str(1,2), '  ', num2str(z(1))]); 
%     disp([num2str(i+1,2), '  ', num2str(x(i+1),'%f'), '  ', num2str(y(i+1),'%f') ,'  ', num2str(z(i+1),'%f'), '  ', num2str(gama)]);

for i=1:P
    if(mode == 0)   
        if (z(i) < 0)   
            gama = -1;
        else
            gama = 1;
        end
    else
        if (x(i)*y(i) >= 0)   
            gama = -1;
        else
            gama = 1;
        end        
    end
    x(i+1) = x(i) + gama*y(i)*power(2, -1*i);
    y(i+1) = y(i) + gama*x(i)*power(2, -1*i);
    z(i+1) = z(i) - gama*atanh(power(2, -1*i));
        
    if(i == k)
%         disp(['         ', num2str(i+1,2), '  ', num2str(z(i+1))]);    
        if(mode == 0)
            if (z(i+1) < 0)   
                gama = -1;
            else
                gama = 1;
            end
        else
            if (x(i+1)*y(i+1) >= 0)   
                gama = -1;
            else
                gama = 1;
            end        
        end
        xtemp(i+1) = x(i+1) + gama*y(i+1)*power(2, -1*(i));%%%%%%%%%%%%%%%%%%%%%%%
        y(i+1) = y(i+1) + gama*x(i+1)*power(2, -1*(i));
        z(i+1) = z(i+1) - gama*atanh(power(2, -1*(i))); 
        x(i+1) = xtemp(i+1);%%%%%%%%%%%%%%%%%%%%%%%%
        k = 3*k + 1;
%         disp([num2str(i+1,2), '  ', num2str(x(i+1),'%f'), '  ', num2str(y(i+1),'%f') ,'  ', num2str(z(i+1),'%f'), '  ', num2str(gama)]);
    end
%     disp([num2str(i+1,2), '  ', num2str(x(i+1),'%f'), '  ', num2str(y(i+1),'%f') ,'  ', num2str(z(i+1),'%f'), '  ', num2str(gama)]);    
end

powerout = x(17)
