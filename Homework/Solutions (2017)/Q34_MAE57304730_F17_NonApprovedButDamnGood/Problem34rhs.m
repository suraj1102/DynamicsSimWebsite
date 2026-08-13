function zdot=Problem34rhs(t,z,flag,m,I,d,phi)
xg     = z(1);                                       
xgdot  = z(2);                                       
yg     = z(3);                                       
ygdot  = z(4);                                       
th     = z(5);                                       
thdot  = z(6);                                       
xgddot = -(d^2*m*thdot*ygdot*sin(phi + th)^2 + I*thdot*ygdot*cos(phi + th)^2*sin(th)^2 + I*thdot*ygdot*sin(phi + th)^2*cos(th)^2 + d^2*m*thdot*xgdot*cos(phi + th)*sin(phi + th) + d^2*m*thdot*ygdot*cos(phi)^2*sin(th)^2 + d^2*m*thdot*xgdot*cos(phi)^2*cos(th)*sin(th) - 2*I*thdot*ygdot*cos(phi + th)*sin(phi + th)*cos(th)*sin(th) + d^2*m*thdot*xgdot*cos(phi + th)*cos(phi)*sin(th) + d^2*m*thdot*xgdot*sin(phi + th)*cos(phi)*cos(th) + 2*d^2*m*thdot*ygdot*sin(phi + th)*cos(phi)*sin(th))/(d^2*m*cos(phi + th)^2 + d^2*m*sin(phi + th)^2 + I*cos(phi + th)^2*sin(th)^2 + I*sin(phi + th)^2*cos(th)^2 + d^2*m*cos(phi)^2*sin(th)^2 + d^2*m*cos(phi)^2*cos(th)^2 + 2*d^2*m*sin(phi + th)*cos(phi)*sin(th) - 2*I*cos(phi + th)*sin(phi + th)*cos(th)*sin(th) + 2*d^2*m*cos(phi + th)*cos(phi)*cos(th));                              

ygddot = (d^2*m*thdot*xgdot*cos(phi + th)^2 + I*thdot*xgdot*cos(phi + th)^2*sin(th)^2 + I*thdot*xgdot*sin(phi + th)^2*cos(th)^2 + d^2*m*thdot*ygdot*cos(phi + th)*sin(phi + th) + d^2*m*thdot*xgdot*cos(phi)^2*cos(th)^2 + d^2*m*thdot*ygdot*cos(phi)^2*cos(th)*sin(th) - 2*I*thdot*xgdot*cos(phi + th)*sin(phi + th)*cos(th)*sin(th) + 2*d^2*m*thdot*xgdot*cos(phi + th)*cos(phi)*cos(th) + d^2*m*thdot*ygdot*cos(phi + th)*cos(phi)*sin(th) + d^2*m*thdot*ygdot*sin(phi + th)*cos(phi)*cos(th))/(d^2*m*cos(phi + th)^2 + d^2*m*sin(phi + th)^2 + I*cos(phi + th)^2*sin(th)^2 + I*sin(phi + th)^2*cos(th)^2 + d^2*m*cos(phi)^2*sin(th)^2 + d^2*m*cos(phi)^2*cos(th)^2 + 2*d^2*m*sin(phi + th)*cos(phi)*sin(th) - 2*I*cos(phi + th)*sin(phi + th)*cos(th)*sin(th) + 2*d^2*m*cos(phi + th)*cos(phi)*cos(th));                              

thddot = -(d*m*thdot*xgdot*sin(phi + th)^2*cos(th) + d*m*thdot*ygdot*cos(phi + th)^2*sin(th) - d*m*thdot*ygdot*cos(phi + th)*sin(phi + th)*cos(th) - d*m*thdot*xgdot*cos(phi + th)*sin(phi + th)*sin(th) - d*m*thdot*xgdot*cos(phi + th)*cos(phi)*sin(th)^2 - d*m*thdot*ygdot*sin(phi + th)*cos(phi)*cos(th)^2 + d*m*thdot*ygdot*cos(phi + th)*cos(phi)*cos(th)*sin(th) + d*m*thdot*xgdot*sin(phi + th)*cos(phi)*cos(th)*sin(th))/(d^2*m*cos(phi + th)^2 + d^2*m*sin(phi + th)^2 + I*cos(phi + th)^2*sin(th)^2 + I*sin(phi + th)^2*cos(th)^2 + d^2*m*cos(phi)^2*sin(th)^2 + d^2*m*cos(phi)^2*cos(th)^2 + 2*d^2*m*sin(phi + th)*cos(phi)*sin(th) - 2*I*cos(phi + th)*sin(phi + th)*cos(th)*sin(th) + 2*d^2*m*cos(phi + th)*cos(phi)*cos(th));                              

zdot = [xgdot xgddot ygdot ygddot thdot thddot]';         
end                                                  
