%% Code written by Vikram Shree, Mechanical & Aerospace Engineering
%% Cornell University
%% MAE 5730, Nice Solution for Problem 23

%% This is the main file which needs to be run
% In this problem I have obtained periodic solutions for Three particles 
% moving under Inverse Square Gravity by posing it as a optimization problem 
% (Refer to text section-1.2)

clc;
close all;
clear all;

global G m1 m2 m3
% Setting the stucture containing the system parameters
m1 = 1; % in kg
m2 = 1; % in kg
m3 = 1; % in kg
G = 1;

%% Formulating the minimization problem as in section - 1.2 of text

% No Inequality Constraints, 
A =[];
b = [];

% No Equality Constraints
Aeq = [];
beq = [];
% No non-linear constraints
nonlcon = [];

% Bounds on the variables
% ub = [-0.7, 0.4, 1.2, 0, 0.1, 0.1, 1, 0.1, 0.2, 0.5, 1, 0.9, 8.2]';
% lb = [-1, 0.2, 0.9, -0.3, -0.5, -0.4, -0.5, -0.5, -0.5, -0.5, -1.2, -0.6, 6]';

% For Periodic orbit #2
lb = [-5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, -5, 2]';
ub = [5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 15]';

%% Setting Optimization Parameters

options = optimoptions('fmincon','Display','iter');
options.Algorithm = 'active-set';
options.MaxIter = 1500; % Max number of iterations
options.MaxFunEvals  = 2e3; % Max number of function evaluations

% Setting Solver Tolerance
options.TolX = 1e-7;
options.TolCon = 1e-7;
options.TolFun = 1e-7;

%%  This set of guess for solver
% x1 = -0.755; y1 = 0.355;
% x2 = 1.155; y2 = -0.0755;
% x3 = -0.4055; y3 = -0.3055;
% 
% Vx1 = 0.9955; Vy1 = 0.07855;
% Vx2 = 0.1055; Vy2 = 0.4755;
% Vx3 = -1.1055; Vy3 = -0.5355;
% T = 8; % Initial guess for Time period

%% New Initial Guess to obtain another periodic orbit #2
x1 = -0.32; y1 = 0.42;
x2 = -2; y2 = -0.45;
x3 = 1; y3 = 0.42;

Vx1 =0; Vy1 = -1;
Vx2 = 0; Vy2 = 0.1;
Vx3 = -0; Vy3 = 0.8;
T = 11; % Initial guess for Time period

x0 = [x1, y1, x2, y2, x3, y3, Vx1, Vy1, Vx2, Vy2, Vx3, Vy3, T];


% Solving the minimization problem where 'errorNorm' is the function which
% we are interesed in minimizing

[x,fval] = fmincon(@errorNorm,x0,A,b,Aeq,beq,lb,ub,nonlcon,options)


%% Obtaining the trajectories for the 3 masses for converged initial conditions.
% After obtaining the solution for minimization problem, I am using the 
% converged result as initial condition for my system and obtined the
% trajectories to verify that they are indeed periodic.

inits = x(1:12); % Initial condition for ODE45
tf = 5*x(end); % I am interested in obtaining the trajectory for 5x(Time Period)

% Setting Tolerances for ODE45
opts.RelTol = 1e-7;
opts.AbsTol = 1e-7;

% Obtaining numeriacal solution
[time, yArray] = ode45(@RHSfun,[0,tf],inits,opts);

% Extracting the positions of the 3-masses
trajX1 = yArray(:,1);
trajY1 = yArray(:,2);
trajX2 = yArray(:,3);
trajY2 = yArray(:,4);
trajX3 = yArray(:,5);
trajY3 = yArray(:,6);

%% Interpolating the result on a uniform time scale
delT = 0.1;
uniformTime = [0:delT:tf];

traj.X1 = interp1(time(:,1),yArray(:,1),uniformTime(:));
traj.Y1 = interp1(time(:,1),yArray(:,2),uniformTime(:));
traj.X2 = interp1(time(:,1),yArray(:,3),uniformTime(:));
traj.Y2 = interp1(time(:,1),yArray(:,4),uniformTime(:));
traj.X3 = interp1(time(:,1),yArray(:,5),uniformTime(:));
traj.Y3 = interp1(time(:,1),yArray(:,6),uniformTime(:));

%% Animation for periodic solution
delT = 0.1; % This is the time interval for the simulation
% setting it to '0.1' will show the positions of the masses at interval of
% about 0.1 seconds.
animation(traj, delT);
