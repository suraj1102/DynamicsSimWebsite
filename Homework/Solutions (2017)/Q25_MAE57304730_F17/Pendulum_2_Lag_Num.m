%{
Author:     Aaron Sandoval
Course:     MAE 5730 - Intermediate Dynamics and Vibrations
Assignment: Homework Solutions
Problem:    25c

Description:
This function models the dynamics of a double pendulum from DAEs.
It formats the arguments and calls the auto-generated
Pendulum_2_DAE_Raw.
It assembles the outputs to return the full state derivative.
%}

function res = Pendulum_2_Lag_Num(t,Z0,p)

% Unpack Parameters
L1 = p.L(1); L2 = p.L(2);
m1 = p.m(1); m2 = p.m(2);
g = p.g;

% Unpack State Variables
th1 = Z0(1); th2 = Z0(2); thD1 = Z0(3); thD2 = Z0(4);

% Call function to numerically calculate accelerations
[numMat] = Pendulum_2_Lag_Num_Raw(L1,L2,g,m1,m2,th1,th2,thD1,thD2);

% Post-process output to extract mass matrix and rhs_stripped vector
rhs_stripped = numMat(:,end);
M = numMat(:,1:end-1);

% Calculate accelerations
rhs = -M\rhs_stripped;

res = [thD1; thD2; rhs];