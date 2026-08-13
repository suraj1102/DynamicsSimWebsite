%{
Author:     Aaron Sandoval
Course:     MAE 5730 - Intermediate Dynamics and Vibrations
Assignment: Homework Solutions
Problem:    25a

Description:
This script derives the equations of motion for a double pendulum.
AMB is used for the derivation.
The equations are derived symbolically.
It uses matlabFunction to write a RHS file with the dynamics model.
The CSYS is oriented with x in the direction of gravity
%}

clc; close all;

% Parameters
numLinks = 2;
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
i = [1;0;0];
k = [0;0;1];
lamHat = [cosTh;sinTh;zeroRow]; 
nHat = [-sinTh;cosTh;zeroRow];

% Position Vectors and Scalar Distances
rG1_O = L(1)/2*lamHat(:,1);   LG1_O = norm(rG1_O);
rE_O = L(1)*lamHat(:,1);      LE_O  = norm(rE_O);
rG2_E = L(2)/2*lamHat(:,2);   LG2_E = norm(rG2_E);
rG2_O = rE_O+rG2_E;           LG2_O = norm(rG2_O);

% Acceleration Vectors
aG1_O = -thD(1)^2 * rG1_O + LG1_O*thDD(1) * nHat(:,1);
aE_O =  -thD(1)^2 * rE_O  + LE_O *thDD(1) * nHat(:,1);
aG2_E = -thD(2)^2 * rG2_E + LG2_E*thDD(2) * nHat(:,2);
aG2_O = aE_O + aG2_E;

% Derivative of Angular Momentum of System
HdotSys_O = sym('Hdot_O', [3 numLinks], 'real'); 
HdotSys_O(:,1) = m(1)*cross(rG1_O,aG1_O) + I_G(1)*thDD(1)*k;
HdotSys_O(:,2) = m(2)*cross(rG2_O,aG2_O) + I_G(2)*thDD(2)*k;

% Derivative of Angular Momentum of Link 2
Hdot2_P1 = sym('Hdot2_P1', [3 1], 'real'); 
Hdot2_P1(:,1) = m(2)*cross(rG2_E,aG2_O) + I_G(2)*thDD(2)*k;

% Net Moment Vector on System
Msys_O = m(1)*g*cross(rG1_O,i) + m(2)*g*cross(rG2_O,i);

% Net Moment Vector on Link 2
M2_E = m(2)*g*cross(rG2_E,i);

% De-vectorize quantities
HdotSys = sum(sum(HdotSys_O));
Msys = sum(Msys_O);
Hdot2 = sum(sum(Hdot2_P1));
M2 = sum(M2_E);

% AMB Equations
eq1 = HdotSys - Msys;
eq2 = Hdot2 - M2;

% Solve
EoM = [eq1; eq2];
M = simplify(jacobian(EoM, thDD));
rhs_stripped = simplify(EoM - M*thDD');
% rhs = simplify(-M\rhs_stripped);

matlabFunction([M, rhs_stripped], 'File', 'Pendulum_2_AMB_Num_Raw');
% matlabFunction(rhs, 'File', 'Pendulum_2_AMB_Raw_REV2');