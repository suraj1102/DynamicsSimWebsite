%{
Author:     Aaron Sandoval
Course:     MAE 5730 - Intermediate Dynamics and Vibrations
Problem:    25: Double Pendulum

Description:
This script tests the RHS files created for a double pendulum.
The RHS files tested use AMB, DAEs, and Lagrange equations
It plots the paths of the end of the forearm for each solution method.
%}

clc; close all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% INPUTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Results selection
animate = 1; %      0: hide animations 1: show animations 
plotPaths = 1;%     0: hide paths      1: show path plots
plotErrors = 1;%    0: hide errors     1: error log plot   2: error linear plot

% Parameters
tFinal = 30; %Simulation time
L = 1;
m = 1;
p.g = 1; %Gravitational acceleration
p.m = [m m]; %Link masses
p.L = [L L]; %Full link lengths

% Initial Conditions
thInit = deg2rad([90 180]); %Measured from +x, the direction of gravity
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

% Time & Output Arrays
tSpan = [0, tFinal];

% Solve ODEs
% AMB
[tAMB, ZAMB] = ode45(@(t,Z) Pendulum_2_AMB_Num(t,Z,p), tSpan, z0);
% DAEs
[tDAE, ZDAE] = ode45(@(t,Z) Pendulum_2_DAE_Num(t,Z,p), tSpan, z0DAE);
% Lagrange
[tLag, ZLag] = ode45(@(t,Z) Pendulum_2_Lag_Num(t,Z,p), tSpan, z0);

% Post-process to find x(t), y(t) of the link endpoints
[xAMB, yAMB] = Pendulum_PostProcess(    ZAMB(:,1:2),p);
[xDAE, yDAE] = Pendulum_PostProcess_DAE(ZDAE(:,1:2),ZDAE(:,3:4),ZDAE(:,5:6),p);
[xLag, yLag] = Pendulum_PostProcess(    ZLag(:,1:2),p);

% Assign Path Plotting Variables
sizes = [length(tAMB), length(tDAE), length(tLag)];
maxLen = max(sizes);
plotX = zeros(maxLen,3);
plotY = zeros(maxLen,3);
plotX(1:sizes(1),1) = yAMB(:,3);
plotX(1:sizes(2),2) = yDAE(:,3);
plotX(1:sizes(3),3) = yLag(:,3);
plotY(1:sizes(1),1) = -xAMB(:,3);
plotY(1:sizes(2),2) = -xDAE(:,3);
plotY(1:sizes(3),3) = -xLag(:,3);

% Plot Forearm End Paths
if (plotPaths)
    lineStyles = {'k', 'k.-', 'k--'};
    lineNames = {'AMB', 'DAE', 'Lagrange'};
    pathFig = figure;
    for i = [1,2,3]
        plot(plotX(1:sizes(i),i), plotY(1:sizes(i),i), lineStyles{i},...
            'DisplayName', lineNames{i});
        hold on;
    end
    titleStr = sprintf('Path of Hand Over %i Seconds', tFinal);
    title(titleStr);
    xlabel('$x \mathrm{[m]}$', 'Interpreter', 'latex');
    ylabel('$y \mathrm{[m]}$', 'Interpreter', 'latex');
    set(gca, 'FontSize', 16);
    leg = legend('show'); leg.Interpreter = 'latex';
    grid on; axis equal;
end


% Interpolate theta vectors
thAMB = ZAMB(:,2); thDAE = ZDAE(:,6); thLag = ZLag(:,2);
% thetaDAEAMBTime is thDAE with the values interpolated to the values in
% the tAMB time vector. This allows direct comparison to thAMB
thetaDAEAMBTime = interp1(tDAE, thDAE, tAMB);
thetaLagAMBTime = interp1(tLag, thLag, tAMB);

% Assign Path Plotting Variables
errorDAE = abs(thAMB - thetaDAEAMBTime);
errorLag = abs(thAMB - thetaLagAMBTime);
plotX = tAMB;
plotY = [errorDAE, errorLag];

if (plotErrors)
% Plot Error Growth
    lineStyles = {'k', 'k.-', 'k--'};
    lineNames = {'DAE vs Minimal AMB', 'Lagrange vs Minimal AMB'};
    errorFig = figure;
    for i = 1:2
        if(plotErrors == 1)
            semilogy(plotX, plotY(:,i), lineStyles{i},...
                'DisplayName', lineNames{i});
        else
            plot(plotX, plotY(:,i), lineStyles{i},...
                'DisplayName', lineNames{i});        
        end
        hold on;
    end
    title('Error in \theta_2 Over Time');
    xlabel('$t\mathrm{[s]}$', 'Interpreter', 'latex');
    ylabel('$Error\mathrm{[rad]}$', 'Interpreter', 'latex');
    set(gca, 'FontSize', 16);
    leg = legend('show'); leg.Interpreter = 'latex';
    grid on;
end

if(animate)
    % Animation AMB
    tAnim = 10;
    animX = yAMB;
    animY = -xAMB;
    Animate_Links(tAMB, animX, animY, tAnim);

    % Animation DAE
    animX = yDAE;
    animY = -xDAE;
    Animate_Links(tDAE, animX, animY, tAnim);

    % Animation AMB
    animX = yLag;
    animY = -xLag;
    Animate_Links(tLag, animX, animY, tAnim);
end