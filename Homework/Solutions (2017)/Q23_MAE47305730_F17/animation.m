%% This function animates the trajectory of the three masses in periodic orbits
% Input is the trajectory of the masses and the time interval for the
% simulation

function animation(traj,delT)

% 'traj' stores the trajectory of the masses
% 'delT' is the time step for simulation

fig = figure;
figure(fig)
n = size(traj.X1,1);

h1Old = plot(traj.X1(1),traj.Y1(2),'ob','LineWidth',1.5);
hold on
h2Old = plot(traj.X2(1),traj.Y2(2),'or','LineWidth',1.5);
h3Old = plot(traj.X3(1),traj.Y3(2),'og','LineWidth',1.5);
legend({'Particle 1', 'Particle 2', 'Particle 3'},'Interpreter','latex','FontSize',11);
% pause(delT);
ylim([-2 2]);
xlim([-2 2]);
xlabel('$x$','Interpreter','latex','FontSize',14);
ylabel('$y$','Interpreter','latex','FontSize',14);
title('Animation for Periodic Orbits obtained for 3-Masses under Inverse Squared Gravity','Interpreter','latex','FontSize',14)


for i=2:n
    delete(h1Old);
    delete(h2Old);
    delete(h3Old);
    plot(traj.X1(i-1:i),traj.Y1(i-1:i),'--b','LineWidth',2);
    plot(traj.X2(i-1:i),traj.Y2(i-1:i),'--r','LineWidth',2);
    plot(traj.X3(i-1:i),traj.Y3(i-1:i),'--g','LineWidth',2);
    
    h1Old = plot(traj.X1(i),traj.Y1(i),'ob','LineWidth',1.5,'MarkerSize',8);
    h2Old = plot(traj.X2(i),traj.Y2(i),'or','LineWidth',1.5,'MarkerSize',8);
    h3Old = plot(traj.X3(i),traj.Y3(i),'og','LineWidth',1.5,'MarkerSize',8);
    pause(delT);
end

