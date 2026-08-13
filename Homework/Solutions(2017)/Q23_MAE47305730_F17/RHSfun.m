%% This function contains the system dynamics as in section - 1.1 of text

function yDot = RHSfun(t,y,para)
% Instead of supplying the parameters to 'RHSfun', it can directly access
% the parameters as I have declared them as 'Global' variables.

global G 
global m1
global m2
global m3

r12 = sqrt((y(1)-y(3))^2 + (y(2)-y(4))^2);
r23 = sqrt((y(3)-y(5))^2 + (y(4)-y(6))^2);
r31 = sqrt((y(1)-y(5))^2 + (y(2)-y(6))^2);
r21 = r12;
r32 = r23;
r13 = r31;

% Writing the differential equation as in equation: (4)-(12), in text
% yDot = ddt([x1, y1, x2, y2, x3, y3, Vx1, Vy1, Vx2, Vy2, Vx3, Vy3]')

yDot(1,1) = y(7);
yDot(2,1) = y(8);
yDot(3,1) = y(9);
yDot(4,1) = y(10);
yDot(5,1) = y(11);
yDot(6,1) = y(12);

yDot(7,1) = -G*m2*(y(1)-y(3))/(r12^3) - G*m3*(y(1)-y(5))/(r13^3);

yDot(8,1) = -G*m2*(y(2)-y(4))/(r12^3) - G*m3*(y(2)-y(6))/(r13^3);

yDot(9,1) = -G*m1*(y(3)-y(1))/(r12^3) - G*m3*(y(3)-y(5))/(r23^3);

yDot(10,1) = -G*m1*(y(4)-y(2))/(r12^3) - G*m3*(y(4)-y(6))/(r23^3);

yDot(11,1) = -G*m1*(y(5)-y(1))/(r13^3) - G*m2*(y(5)-y(3))/(r23^3);

yDot(12,1) = -G*m1*(y(6)-y(2))/(r13^3) - G*m2*(y(6)-y(4))/(r23^3);

end
