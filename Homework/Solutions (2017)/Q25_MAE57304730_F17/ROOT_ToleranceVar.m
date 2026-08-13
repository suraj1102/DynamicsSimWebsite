%{
Author:     Aaron Sandoval
Course:     MAE 5730 - Intermediate Dynamics and Vibrations
Problem:    25: Double Pendulum

Description:
This script tests the RHS files created for a double pendulum.
The RHS files tested use AMB, DAEs, and Lagrange equations.
It calculates the paths using varying ode45 tolerances.
It plots the errorr in theta2 with respect to the most precise AMB trial.
%}

clc; close all;
clear plotY; clear errorTh; clear lineNames;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% INPUTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parameters
tFinal = 120; %Simulation time
L = 1;
m = 1;
p.g = 1; %Gravitational acceleration
p.m = [m m]; %Link masses
p.L = [L L]; %Full link length

% Initial Conditions
thInit = deg2rad([90 180]); %Measured from +x, the direction of gravity

% Tolerances
tolMin = 1e-12; %Min abs tolerance
tolMax = 1e-4; %Max abs tolerance
relMult = 1000; %Multiplier: reltol = absTol * relMult
numTol = 3; %# of trials to try with different tolerances
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% INPUTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Initial Conditions
xInit = 0.5*p.L.*cos(thInit);
xInit(2) = xInit(2) + 2*xInit(1);
yInit = 0.5*p.L.*sin(thInit);
yInit(2) = yInit(2) + 2*yInit(1);
ratesInit = zeros(1,6); %System is initially motionless
z0 = [thInit, 0, 0]; %State Vector [theta1, theta2, thetaDot1, thetaDot2]
z0DAE = [xInit, yInit, thInit, ratesInit]; % State Vector for DAEs
% [x1 x2 y1 y2 theta1 theta2 x1Dot x2Dot y1Dot y2Dot theta1Dot theta2Dot]
tSpan = [0 tFinal];

% Output Arrays
tMaster = [];
thMaster = [];
lineNames = {};
errorTh = [];

% ode45 Tolerances
% absTols, relTols: log-spaced array with tolerances for all trials
absTols = logspace(log(tolMin)/log(10),...
    log(tolMax)/log(10), numTol);
relTols = relMult * logspace(log(tolMin)/log(10),...
    log(tolMax)/log(10), numTol);

% Solve ODEs
for i=1:numTol
    isMaster = 0; %Assume this trial is not the master for error calculation
    
    % Solve ODE
    opts = odeset('RelTol', relTols(i), 'AbsTol', absTols(i));
        % AMB
    [tAMB, ZAMB] = ode45(@(t,Z) Pendulum_2_AMB_Num(t,Z,p), tSpan, z0, opts);
        % DAEs
    [tDAE, ZDAE] = ode45(@(t,Z) Pendulum_2_DAE_Num(t,Z,p), tSpan, z0DAE, opts);
        % Lagrange
    [tLag, ZLag] = ode45(@(t,Z) Pendulum_2_Lag_Num(t,Z,p), tSpan, z0, opts);

    % Assign master values for calculating errors to most precise AMB trial
    if(i == 1)
        isMaster = 1;
        tMaster = tAMB;
        thMaster = ZAMB(:,2);
    end
    
    % Interpolate theta vectors
    thAMB = ZAMB(:,2); thDAE = ZDAE(:,6); thLag = ZLag(:,2);
    % thetaDAEAMBTime is thDAE with the values interpolated to the values in
    % the tAMB time vector. This allows direct comparison to thAMB
    thetaAMBMasterTime = interp1(tAMB, thAMB, tMaster);
    thetaDAEMasterTime = interp1(tDAE, thDAE, tMaster);
    thetaLagMasterTime = interp1(tLag, thLag, tMaster);

    % Calculate errors in theta2
    errorAMB = abs(thMaster - thetaAMBMasterTime);
    errorDAE = abs(thMaster - thetaDAEMasterTime);
    errorLag = abs(thMaster - thetaLagMasterTime);
    
    if(~isMaster) %For lower-tolerance AMB trials
        errorTh = [errorTh, errorAMB];
        name = sprintf('AMB %.0d', absTols(i));
        lineNames(length(lineNames)+1) = {name};
    end
        
    errorTh = [errorTh, errorDAE, errorLag];
    name1 = sprintf('DAE %.0d', absTols(i));
    name2 = sprintf('LAG %.0d', absTols(i));
    newInd = length(lineNames)+1;
    lineNames(newInd:newInd+1) = {name1, name2};
end

% Plot Error Growth
plotX = tMaster;
plotY = errorTh;

lineStyles = {'k.-', 'k--', 'b', 'b.-', 'b--','r', 'r.-', 'r--',...
    'g', 'g.-', 'g--', 'c', 'c.-', 'c--'};
%If plotting >5 tolerances, add more items to the lineStyles cell.
errorFig = figure;
for i = 1:length(plotY(1,:))
    semilogy(plotX, plotY(:,i), lineStyles{i},...
        'DisplayName', lineNames{i});
    hold on;
end
title('Error in \theta_2 with Respect to Most Precise AMB Solution');
xlabel('$t\mathrm{[s]}$', 'Interpreter', 'latex');
ylabel('$Error\mathrm{[rad]}$', 'Interpreter', 'latex');
set(gca, 'FontSize', 16);
leg = legend('show'); leg.Interpreter = 'latex';
grid on;