%{
Author:     Aaron Sandoval
Course:     MAE 5730 - Intermediate Dynamics and Vibrations
Created: 2017-10-19
Updated: 2017-10-20

Description:
This function animates the motion of an arbitrary numbe of links.
It accepts a series of 
%}

function  Animate_Links(t, x, y, tAnim)

% Setup variables
numP = length(x(1,:));
numL = numP-1;
xyMax = 1.1*max(max(max(abs(x), max(abs(y))))); %Yes, all those are necessary
xMax = max(max(x));
xMin = min(min(x));
yMax = max(max(y));
yMin = min(min(y));
eps = .01*xyMax;

% Define shape geometry centered on origin
% shape= [
%     eps     eps     -eps    -eps    +eps
%     -eps    +eps    +eps    -eps    -eps
%        ];

% plotX = shape(1,:);
% plotY = shape(2,:);

figure;
colors = {'r', 'g', 'b', 'k', 'o'};
for i = 1:numL
    plt(i) = plot(x(1,i:i+1),y(1,i:i+1), 'LineWidth', 5,...
        'Color', colors{i});
    hold on;
end
plotRange = [xMax-xMin, yMax-yMin];
margin = .05*plotRange+2*eps;
axis('equal');
axis([xMin-margin(1) xMax+margin(1) yMin-margin(2) yMax+margin(2)]);
set(gca, 'FontSize', 16);
% grid on;

tNorm = t*(tAnim/t(length(t)));
tic;
shg
cur = toc;
while cur<tAnim
    for i=1:numP
        xNew(i) = interp1(tNorm, x(:,i), cur);
        yNew(i) = interp1(tNorm, y(:,i), cur);
%         zNew = [x+xNew; y+yNew];
        if(i>1)
            plt(i-1).XData = xNew(i-1:i);
            plt(i-1).YData = yNew(i-1:i);
        end
    end
    drawnow;
    cur = toc;
end
end

