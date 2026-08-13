% Greg Cristina
% MAE 5730
% Homework Problem 27

clc
clear
close all

% initialize system parameters
sim_time = 5;
mu = 0.3; % friction coefficient
p.g = 10; % acceleration of gravity
p.m = 1; % mass of car
p.I = 1; % moment of inertia of car
p.d1 = -0.5; % distance from  skate to CoM
p.d2 = -0.5; % distance from CoM to skid point
p.L = p.d1+p.d2; % distance from skate to skid point
p.Ff = mu*p.m*p.g; % friction force

% ICs
xc_0 = 1; % initial x pos of skate (c)
yc_0 = 0; % initial y pos of skate (c)
theta_0 = 0; % initial point angle
thetadot_0 = 0.5; % initial angular velocity
vc_0 = 10; % initial velocity

%initialize state for ODE45
inits = [xc_0 yc_0 theta_0 vc_0 thetadot_0];

%ODE45 tolerances
opts.RelTol = 1e-6;
opts.AbsTol = 1e-6;

%% the first solution is the case when the rear wheels lock up

%solve equations
[t,z] = ode45(@HW27_RHS,[0,sim_time],inits,opts,p);

%extract data
xcs = z(:,1);
ycs = z(:,2);
ths = z(:,3);
vcs = z(:,4);
ws = z(:,5);

% find positions of CoM (g) and skidding wheels (p)
xgs = xcs + p.d1*cos(ths);
ygs = ycs + p.d1*sin(ths);
xps = xcs + p.L*cos(ths);
yps = ycs + p.L*sin(ths);

% plotting
figure
plot(xcs,ycs)
hold on
plot(xgs,ygs)
plot(xps,yps)
hold off
legend('Skate','CoM','Locked Wheels')
axis equal
title('Position of Car when Rears Lock Up')
xlabel('X Pos')
ylabel('Y Pos')
grid on

figure
plot(t,vcs)
grid on
title('Velocity of Car at Skate when Rears Lock Up')
xlabel('Time (s)')
ylabel('Velocity (m/s)')

figure
subplot(1,2,1)
plot(t,ths)
title('Pointing Angle when Rears Lock Up')
xlabel('Time (s)')
ylabel('Angle (rad)')
axis equal
grid on
subplot(1,2,2)
plot(t,ws)
title('Angular Velocity when Rears Lock Up')
xlabel('Time (s)')
ylabel('Anglular Velocity (rad/s)')
axis equal
grid on

%% now solved with front wheels locking, same initial conditions

p.d1 = 0.5;
p.d2 = 0.5;
p.L = p.d1+p.d2;

% ICs
xc_0 = 0;

%initialize state for ODE45
inits = [xc_0 yc_0 theta_0 vc_0 thetadot_0];

[t,z] = ode45(@HW27_RHS,[0,sim_time],inits,opts,p);

xcs = z(:,1);
ycs = z(:,2);
ths = z(:,3);
vcs = z(:,4);
ws = z(:,5);

xgs = xcs + p.d1*cos(ths);
ygs = ycs + p.d1*sin(ths);
xps = xcs + p.L*cos(ths);
yps = ycs + p.L*sin(ths);

% plotting
figure
plot(xcs,ycs)
hold on
plot(xgs,ygs)
plot(xps,yps)
hold off
legend('Skate','CoM','Locked Wheels')
axis equal
title('Position of Car when Fronts Lock Up')
xlabel('X Pos')
ylabel('Y Pos')
grid on

figure
plot(t,vcs)
grid on
title('Velocity of Car at Skate when Fronts Lock Up')
xlabel('Time (s)')
ylabel('Velocity (m/s)')

figure
subplot(1,2,1)
plot(t,ths)
title('Pointing Angle when Fronts Lock Up')
xlabel('Time (s)')
ylabel('Angle (rad)')
axis equal
grid on
subplot(1,2,2)
plot(t,ws)
title('Angular Velocity when Fronts Lock Up')
xlabel('Time (s)')
ylabel('Anglular Velocity (rad/s)')
axis equal
grid on

%% Limiting Cases (Part D)
% Here are some tests to conclude that the EoM and code are running
% properly based on intuition.  The cases are as follows:
%
%       1) Zero Friction
%       2) Friction with no initial rotation
%       3) Set CoM on skate

%% Case 1: Zero Friction
p.Ff = 0;
p.d1 = 0.5;
p.d2 = 0.5;
p.L = p.d1+p.d2;

xc_0 = 0;
thetadot_0 = 0;

inits = [xc_0 yc_0 theta_0 vc_0 thetadot_0];

[t,z] = ode45(@HW27_RHS,[0,sim_time],inits,opts,p);

xcs = z(:,1);
ycs = z(:,2);
ths = z(:,3);
vcs = z(:,4);
ws = z(:,5);

xgs = xcs + p.d1*cos(ths);
ygs = ycs + p.d1*sin(ths);
xps = xcs + p.L*cos(ths);
yps = ycs + p.L*sin(ths);

figure
plot(xcs,ycs)
hold on
plot(xgs,ygs)
plot(xps,yps)
hold off
legend('Skate','CoM','Locked Wheels')
axis equal
title('Position of Car No Friction')
xlabel('X Pos')
ylabel('Y Pos')
grid on

figure
plot(t,vcs)
grid on
title('Velocity of Car at Skate No Friction')
xlabel('Time (s)')
ylabel('Velocity (m/s)')

% with some initial omega
thetadot_0 = 0.5;

inits = [xc_0 yc_0 theta_0 vc_0 thetadot_0];

[t,z] = ode45(@HW27_RHS,[0,sim_time],inits,opts,p);

xcs = z(:,1);
ycs = z(:,2);
ths = z(:,3);
vcs = z(:,4);
ws = z(:,5);

xgs = xcs + p.d1*cos(ths);
ygs = ycs + p.d1*sin(ths);
xps = xcs + p.L*cos(ths);
yps = ycs + p.L*sin(ths);

figure
plot(xcs,ycs)
hold on
plot(xgs,ygs)
plot(xps,yps)
hold off
legend('Skate','CoM','Locked Wheels')
axis equal
title('Position of Car No Friction')
xlabel('X Pos')
ylabel('Y Pos')
grid on

figure
plot(t,vcs)
grid on
title('Velocity of Car at Skate No Friction')
xlabel('Time (s)')
ylabel('Velocity (m/s)')

figure
subplot(1,2,1)
plot(t,ths)
title('Pointing Angle No Friction')
xlabel('Time (s)')
ylabel('Angle (rad)')
axis equal
grid on
subplot(1,2,2)
plot(t,ws)
title('Angular Velocity No Friction')
xlabel('Time (s)')
ylabel('Anglular Velocity (rad/s)')
axis equal
grid on


% With no friction, the velocity of the car maintains it's initial given
% value as well as maintains a straight path through time.  Even with some
% initial anglular velocity, the car does not slow down, rather the angular
% velocity goes to zero but slightly increases the car velocity.  Energy is
% conserved in this case.

%% Case 2: Friction with no initial rotation

p.Ff = mu*p.m*p.g;
thetadot_0 = 0;

inits = [xc_0 yc_0 theta_0 vc_0 thetadot_0];

[t,z] = ode45(@HW27_RHS,[0,sim_time],inits,opts,p);

xcs = z(:,1);
ycs = z(:,2);
ths = z(:,3);
vcs = z(:,4);
ws = z(:,5);

xgs = xcs + p.d1*cos(ths);
ygs = ycs + p.d1*sin(ths);
xps = xcs + p.L*cos(ths);
yps = ycs + p.L*sin(ths);

figure
plot(xcs,ycs)
hold on
plot(xgs,ygs)
plot(xps,yps)
hold off
legend('Skate','CoM','Locked Wheels')
axis equal
title('Position of Car w/ Friction')
xlabel('X Pos')
ylabel('Y Pos')
grid on

figure
plot(t,vcs)
grid on
title('Velocity of Car at Skate w/ Friction')
xlabel('Time (s)')
ylabel('Velocity (m/s)')

% The car's velocity decreases linearly with time or at constant
% deaccleration.

%% Case 3: Set CoM on Skate no Friction

p.d1 = 0;
p.d2 = -1;
p.L = p.d1+p.d2;

xc_0 = 1;
thetadot_0 = 0.5;

inits = [xc_0 yc_0 theta_0 vc_0 thetadot_0];

[t,z] = ode45(@HW27_RHS,[0,sim_time],inits,opts,p);

xcs = z(:,1);
ycs = z(:,2);
ths = z(:,3);
vcs = z(:,4);
ws = z(:,5);

xgs = xcs + p.d1*cos(ths);
ygs = ycs + p.d1*sin(ths);
xps = xcs + p.L*cos(ths);
yps = ycs + p.L*sin(ths);

figure
plot(xcs,ycs)
hold on
plot(xgs,ygs)
plot(xps,yps)
hold off
legend('Skate','CoM','Locked Wheels')
axis equal
title('Position of Car')
xlabel('X Pos')
ylabel('Y Pos')
grid on

% here the car follows a stable path despite the skate leading. The problem
% is set up such that there is no weight of the car over the skidding
% wheels thus they effectively drag behind the car with zero effect on the
% system