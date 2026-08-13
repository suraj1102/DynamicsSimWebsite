% Problem 34 Driver
clear all; close all;

%% Basic Parameters
m = 1;
d = 1;
I = 1;
phi = pi/4;

%% Call the deriver function. This will generate our RHS function
Problem34Derive

%% Initial Conditions
xINT  = 0;
yINT  = 0;
thINT = 0;
xdINT = 1;
ydINT = 1/2;
thdINT= 1/2;
% Pack them into a single vector
z0 = [xINT xdINT yINT ydINT thINT thdINT];

% Time for ode45 solving function
tspan = 0:.01:20;
opts.RelTol = 1e-6;
opts.AbsTol = 1e-6;

%% Call the ode45 function
[tarray,zarray] = ode45(@Problem34rhs,tspan,z0,opts,flag,m,I,d,phi);

% Unpack the results into usable variables.
x = zarray(:,1);
y = zarray(:,3);
th= zarray(:,5);

%% Simple Solution
xAna = 2*d/tan(phi);
R = sqrt(d^2+xAna^2);
xSimp = -1+R*cos(th-45);   % Shift graph to account for the initial conditions
ySimp =  2+R*sin(th-45);   % Shift graph to account for the initial conditions

%% Plot the results
figure
hold on
box on
axis square
title('Two Skates on a Plane','Fontsize',14)
xlabel('X','Fontsize',14)
ylabel('Y','Fontsize',14)
% Lagrange solution
plot(x,y,'Linewidth',5)
% Simple solution
plot(xSimp,ySimp,'Linewidth',2)
legend({'Lagrange','Simple'},'Fontsize',12)

