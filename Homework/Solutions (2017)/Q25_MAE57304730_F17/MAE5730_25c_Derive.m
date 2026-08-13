%{
Author:     Aaron Sandoval
Course:     MAE 5730 - Intermediate Dynamics and Vibrations
Assignment: Homework Solutions
Problem:    25c

Description:
This script derives the equations of motion for a double pendulum.
Lagrange equations are used for the derivation.
The equations are derived symbolically.
It uses matlabFunction to write a RHS file with the equations of motion.
The CSYS is oriented with x in the direction of gravity
%}

clc; close all;

% Parameters
numLinks = 2;
numDim = 3;
zeroRow = zeros(1,numLinks);
zeroCol = zeroRow';
syms g real;
L = sym('L', [1 numLinks], 'positive');
m = sym('m', [1 numLinks], 'real');
th = sym('th', [1 numLinks], 'real');
thD = sym('thD', [1 numLinks], 'real');
thDD = sym('thDD', [1 numLinks], 'real');

% Moments of Inertia
I_G = 1/12 * m .* L.^2;

% Unit Vectors
sinTh = sin(th); cosTh = cos(th);
i = [1;0;0]; k = [0;0;1];
lamHat = [cosTh;sinTh;zeroRow]; 

% Position Vectors
rG1_O = L(1)/2*lamHat(:,1);     LG1_O = norm(rG1_O);
rE_O = 2 * rG1_O;               LE_O  = norm(rE_O);
rG2_E = L(2)/2*lamHat(:,2);     LG2_E = norm(rG2_E);
rG2_O = rE_O+rG2_E;             LG2_O = norm(rG2_O);

% Velocity Vectors
vG1_O =  thD(1)*cross(k,rG1_O);
vE_O = 2 * vG1_O;
vG2_E = thD(2)*cross(k,rG2_E);
vG2_O = vG2_E + vE_O;

% Energy Expressions
KETrans = 1/2*m(1)*(vG1_O'*vG1_O) + 1/2*m(2)*(vG2_O'*vG2_O);
KERot =   sum(1/2*I_G.*thD.^2);
KE = KETrans + KERot;
xG = [dot(rG1_O, i), dot(rG2_O, i)];
PE = sum(-m*g.*xG);

% Lagrange Quantities
Lag = KE - PE;
q = th; qDot = thD; qDDot = thDD;
% dLdq = jacobian(Lag, q);
% dLdqDot = jacobian(Lag, qDot);
% ddt_dLdqDot = jacobian(dLdqDot, [q qDot])*[qDot, qDDot]';

% Lagrange Equations
EoM = jacobian(jacobian(Lag, qDot), [q qDot])*[qDot, qDDot]' - jacobian(Lag, q)';

% Solution for thetaDoubleDot
M = jacobian(EoM, thDD);
rhs_stripped = simplify(EoM - M*qDDot');
% rhs = -M\rhs_stripped;

% matlabFunction(rhs, 'File', 'Pendulum_2_Lag_Raw');
matlabFunction([M, rhs_stripped], 'File', 'Pendulum_2_Lag_Num_Raw');
