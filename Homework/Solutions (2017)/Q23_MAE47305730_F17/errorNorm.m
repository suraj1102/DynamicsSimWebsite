%% This function denotes the cost function which needs to be minimized 
% This corresponds to 'f(po,T)' of equation - 13 in the text.

function res = errorNorm(x)

inits = x(1:12);
tf = x(13);
% Setting Tolerances for ODE45
opts.RelTol = 1e-6;
opts.AbsTol = 1e-6;

% Numeriacal solution
[time, yArray] = ode45(@RHSfun,[0,tf],inits,opts);

% Extracting the positions of the masses
xEnd = yArray(end,:);

% Returning the norm of the error which should be '0' for perfectly periodic orbit
res = norm(inits-xEnd); 
