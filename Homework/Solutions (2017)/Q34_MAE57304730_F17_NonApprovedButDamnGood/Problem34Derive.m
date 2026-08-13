function Problem34Derive()
clear all; close all;

%% Create the symbols necessary for 
%Essential variables:
  syms th thdot thddot phi real
  syms xg yg xgdot ygdot xgddot ygddot real
%Intermediate variables:
  syms lam1 lam2 n1 n2 iHat jHat kHat A B C rG rA rB rArelG rBrelG real 
  syms a1 a2 v1 v2 J1 J2 N1 N2 real
%Constant parameters:
  syms m d I zddray real

%% Establish our unit vectors for each frame
% Inertial unit vectors
iHat    = [1          0         0];   
jHat    = [0          1         0];
kHat    = [0          0         1];
% Rotating Frame for A
lam1 = [cos(th)   sin(th)  0];  
n1   = [-sin(th)  cos(th)  0]; 
A    = [lam1; n1; kHat];
% Rotation matrix for B
lam2 = [cos(phi)   sin(phi)  0];   
n2   = [-sin(phi)  cos(phi)  0];
B    = [lam2; n2; kHat];
% Put our rotation matrix in terms of inertial unit vectors
C    = A*B;
% Extract the unit vectors of interest and rewrite variables lam2 and n2
lam2 = C(1,:);
n2   = C(2,:);

%% Solve for the equations of motion in terms of Qx, Qy, Qth
%%%%% NOTE: in this code, to reduce some confusion, the orgin of the frame
%%%%% A refers to the origin of frame B in the diagram and the origin of
%%%%% the frame B refers to the origin of the frame gamma. The unit vectors
%%%%% are true for both the code and the diagram 
rG = xg*iHat + yg*jHat;
rArelG = -d*lam1;
rBrelG = d*lam1;
rA = rG + rArelG;
rB = rG + rBrelG;

% Input our general forces Qx and Qy
Qx = N1*iHat*n1'  + N2*iHat*n2';
Qy = N1*jHat*n1'  + N2*jHat*n2';
% Simplify these equations
Qx = simplify(Qx);
Qy = simplify(Qy);

% Solve for the Qtheta general force. For this equation, we must use the
% jacobian command to derive each position vector with respect to the
% interial rotation variable, theta. 
J1 = jacobian(rA,th);
J2 = jacobian(rB,th);
Qth= N1*n1*J1 + N2*n2*J2;
% Simplify the equation
Qth= simplify(Qth);

%% Solve for the constraints
%%% NOTE: we don't necessarily have to solve for the velocity equations
%%% here but I did just to check my progress and ensure that I will derive 
%%% my acceleration terms, the constraints, properly. These will also help 
%%% us to solve for the system's initial conditions.

% Solve for our each skate's velocity by dotting with normal unit vector
v1 = (xgdot*iHat + ygdot+jHat - d*thdot*n1)*n1';
v2 = (xgdot*iHat + ygdot*jHat + d*thdot*n1)*n2';
% Simplify the equations and check!
v1s = simplify(v1);
v2s = simplify(v2);

% Solve for our constraints!!!
a1 = (xgddot*iHat + ygddot*jHat - d*thddot*n1 + d*thdot^2*lam1)*n1'...
    + (xgdot*iHat + ygdot*jHat - d*thdot*n1)*-thdot*lam1';
a2 = (xgddot*iHat + ygddot*jHat + d*thddot*n1 - d*thdot^2*lam1)*n2'...
    + (xgdot*iHat + ygdot*jHat + d*thdot*n1)*-thdot*lam2';

% Simplify
a1s= simplify(a1);
a2s= simplify(a2);

% We will use the equationsToMatrix(eqns,vec) function to solve for our A
% and b matrices. First we must create a [eqns] vector and [vars] state vec.
eqns = [m*xgddot == Qx
        m*ygddot == Qy
        I*thddot == Qth
        a1s == 0
        a2s == 0];
var = [xgddot
       ygddot
       thddot
       N1
       N2];
% Solve for the A and b matrices
[A,b] = equationsToMatrix(eqns,var);

% MAGIC!!! We will put our second-order diff-eqns into a temporary array of
% size 5x1
zddray = A\b;

% Extract the the second order equations from the temporary array, zddray,
% and convert them into type char. This will allow us to assign the
% variables a value in our driving script
xgddot = char(zddray(1));
ygddot = char(zddray(2));
thddot = char(zddray(3));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Put derived equations  in a right-hand-side file ode45.

fid=fopen(   'Problem34rhs.m','w'                                     );
fprintf(fid, 'function zdot=Problem34rhs(t,z,flag,m,I,d,phi)\n'       );
fprintf(fid, 'xg     = z(1);                                       \n');
fprintf(fid, 'xgdot  = z(2);                                       \n');
fprintf(fid, 'yg     = z(3);                                       \n');
fprintf(fid, 'ygdot  = z(4);                                       \n');
fprintf(fid, 'th     = z(5);                                       \n');
fprintf(fid, 'thdot  = z(6);                                       \n');

fprintf(fid,['xgddot = ' xgddot ';                              \n\n']);
fprintf(fid,['ygddot = ' ygddot ';                              \n\n']);
fprintf(fid,['thddot = ' thddot ';                              \n\n']);
% Create the return vector zdot for our RHS function.
fprintf(fid, 'zdot = [xgdot xgddot ygdot ygddot thdot thddot]'';         \n');
fprintf(fid, 'end                                                  \n');
fclose(fid);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end