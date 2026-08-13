function zdot = HW27_RHS(time,state,p)

x = state(1);
y = state(2);
theta = state(3);
vc = state(4);
thetadot = state(5);

f_mag = sqrt(vc^2+(p.L*thetadot)^2);

thetaddot = -(((p.Ff*thetadot*p.L^2)/f_mag)+(p.m*p.d1*vc*thetadot))/((p.m*p.d1^2)+p.I);

ac = (p.d1*thetadot^2) - ((p.Ff*vc)/(f_mag*p.m));

xdot = vc*cos(theta);
ydot = vc*sin(theta);

zdot = [xdot ydot thetadot ac thetaddot]';