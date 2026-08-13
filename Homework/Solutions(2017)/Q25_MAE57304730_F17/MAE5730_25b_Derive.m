%{
Author:     Aaron Sandoval
Course:     MAE 5730 - Intermediate Dynamics and Vibrations
Assignment: Homework Solutions
Problem:    25b

Description:
This script derives the equations of motion for a double pendulum.
DAEs in Cartesian coordinates are used for the derivation.
The DAEs have 6 DOF with 4 constraint equations to form a 10x10 matrix
The equations are derived symbolically.
It uses matlabFunction to write a RHS file with the dynamics model.
The CSYS is oriented with x in the direction of gravity
%}

clc; close all;

% Parameters
numLinks = 2;
numDim = 3;
zeroRow = zeros(1,numLinks);
zeroCol = zeroRow';
syms g real;
L = sym('L', [1 numLinks], 'real');
m = sym('m', [1 numLinks], 'real');
x = sym('x', [1 numLinks], 'real'); %x for points [G1, G2]
y = sym('y', [1 numLinks], 'real'); %y for points [G1, G2]
th = sym('th', [1 numLinks], 'real'); %theta for objects [1 2]
xD = sym('xD', [1 numLinks], 'real'); %xDot for points [G1, G2]
yD = sym('yD', [1 numLinks], 'real'); %yDot for points [G1, G2]
thD = sym('thD', [1 numLinks], 'real'); %thetaDot for objects [1 2]
xDD = sym('xDD', [1 numLinks], 'real'); %xDoubleDot for points [G1, G2]
yDD = sym('yDD', [1 numLinks], 'real'); %yDoubleDot for points [G1, G2]
thDD = sym('thDD', [1 numLinks], 'real'); %thetaDoubleDot for objects [1 2]
syms FOx FOy FEx FEy real

% Position Vectors
rG1_O = [x(1); y(1)]; 
rE_O = 2*rG1_O;
rG2_O = [x(2); y(2)];
rG2_E = rG2_O - rE_O;

% Moments of Inertia
I_G = 1/12 * m .* L.^2;

% Trig Functions
sinTh = sin(th); cosTh = cos(th);

% Link 1 LMB, AMB
F1x = FOx - FEx + m(1)*g;
F1y = FOy - FEy;
M_G(1) = L(1)/2 * (FOx*sinTh(1) - FOy*cosTh(1) + FEx*sinTh(1) - FEy*cosTh(1));

% Link 2 LMB, AMB
F2x = FEx + m(2)*g;
F2y = FEy;
M_G(2) = L(2)/2 * (FEx*sinTh(2) - FEy*cosTh(2));

% Link Momentum Balance Equations
FNetx = [F1x; F2x];
FNety = [F1y; F2y];
eq(1:2) = (FNetx./m') - xDD';
eq(3:4) = (FNety./m') - yDD';
eq(5:6) = (M_G./I_G) - thDD;

% Constraint Equations
% x(1)*xDD(1) + xD(1)^2 + y(1)*yDD(1) + yD(1)^2; %Equation
eq(7:8) = -xDD - L/2.*(thD.^2.*cosTh + thDD.*sinTh);
eq(8) = eq(8) + 2*xDD(1);
eq(9:10) = -yDD + L/2.*(-thD.^2.*sinTh + thDD.*cosTh);
eq(10) = eq(10) + 2*yDD(1);

% Solve equation
stateVars = [xDD, yDD, thDD, FOx, FOy, FEx, FEy];
M = jacobian(eq, stateVars);
rhs_stripped = simplify(eq' - M*stateVars');
% rhs = simplify(-M\rhs_stripped);

matlabFunction([M, rhs_stripped], 'File', 'Pendulum_2_DAE_Num_Raw');