%{
Name:       Aaron Sandoval
Course:     MAE 5730 - Intermediate Dynamics and Vibrations
Created: 2017-10-09
Updated: 2017-10-20

Description:
This function accepts a time and theta vector for an n-linked pendulum.
It computes the Cartesian coordinate position vectors of the pivots
It returns the list of coordinates, plus the first pivot at 0,0.

Output format:  [xBase, xTip, yBase, yTip]
%}

function [x, y] = Pendulum_PostProcess(th, p)

timePts = length(th(:,1)); % Number of time points
n = length(th(1,:)); % Number of links
L = p.L;

% Compute coordinates
x = zeros(timePts,n+1); y = zeros(timePts,n+1);
x(:,2) = L(1)*cos(th(:,1)); %First endpoint (elbow) x coordinates
y(:,2) = L(1)*sin(th(:,1)); %First endpoint (elbow) y coordinates
for i = 2:n
%     Next endpoint calculation starts from previous endpoint
    x(:,i+1) = x(:,i) + L(i)*cos(th(:,i));
    y(:,i+1) = y(:,i) + L(i)*sin(th(:,i));
end

end
