%{
Author:     Aaron Sandoval
Course:     MAE 5730 - Intermediate Dynamics and Vibrations
Created:    2017-10-19
Updated:    2017-10-19

Description:
This function accepts DAE solver outputs for an n-link pendulum.
The inputs xCG, yCG, th are mxn matrices composed of column vectors, where:
    m = number of time points
    n = number of links in pendulum
m and n must be equal for each matrix input.
It computes the Cartesian coordinate position vectors of the endpoints.
The coordinate system is oriented with +x in the direction of gravity.
Return:     List of endpoint (x,y) coordinates, including the shoulder.

Input format:   [xCG_1, xCG_2],     [yCG_1, yCG_2],     [theta_1, theta_2]
Output format:  [xShoulder, xElbow, xHand, yShoulder, yElbow, yHand]
%}

function [x, y] = Pendulum_PostProcess_DAE(xCG, yCG, th, p)

n = length(xCG(1,:)); %Number of links

% Unpack parameters
timePts = length(xCG(:,1)); %Number of time points
halfL = p.L/2; %Lengths from CG to end of link

% Compute coordinates
x = zeros(timePts,n+1); y = zeros(timePts,n+1);
x(:,2:end) = xCG + halfL.*cos(th);
y(:,2:end) = yCG + halfL.*sin(th);
end
