function plot_trajectory_properties_vs_t_elapsed(traj)

figure,
subplot(311)
box on, grid on, hold on,
for i = 1:length(traj)
        plot(traj(i).t(1)-traj(i).t(1),traj(i).xf(1),'r.','MarkerSize',4);
        plot(traj(i).t(1)-traj(i).t(1),traj(i).yf(1),'g.','MarkerSize',4);
        plot(traj(i).t(1)-traj(i).t(1),traj(i).zf(1),'b.','MarkerSize',4);

        l1=plot((traj(i).t-traj(i).t(1)),traj(i).xf,'r-','DisplayName',num2str(i));
        l2=plot((traj(i).t-traj(i).t(1)),traj(i).yf,'g--','DisplayName',num2str(i));
        l3=plot((traj(i).t-traj(i).t(1)),traj(i).zf,'b-.','DisplayName',num2str(i));
        
        plot(traj(i).t(end)-traj(i).t(1),traj(i).xf(end),'r.','MarkerSize',4);
        plot(traj(i).t(end)-traj(i).t(1),traj(i).yf(end),'g.','MarkerSize',4);
        plot(traj(i).t(end)-traj(i).t(1),traj(i).zf(end),'b.','MarkerSize',4);
end
hold off
xlabel('$t$ [1/100 sec]','Interpreter','latex');
ylabel('$x$ [cm]','Interpreter','latex');
legend([l1,l2,l3],{'\itx','\ity','\itz'})
%
subplot(312)
box on, grid on, hold on,
for i = 1:length(traj)
    if length(traj(i).xf) > 5
        plot(traj(i).t(1)-traj(i).t(1),traj(i).uf(1),'r.','MarkerSize',4);
        plot(traj(i).t(1)-traj(i).t(1),traj(i).vf(1),'g.','MarkerSize',4);
        plot(traj(i).t(1)-traj(i).t(1),traj(i).wf(1),'b.','MarkerSize',4);

        l1=plot((traj(i).t-traj(i).t(1)),traj(i).uf,'r-','DisplayName',num2str(i));
        l2=plot((traj(i).t-traj(i).t(1)),traj(i).vf,'g--','DisplayName',num2str(i));
        l3=plot((traj(i).t-traj(i).t(1)),traj(i).wf,'b-.','DisplayName',num2str(i));

        plot(traj(i).t(end)-traj(i).t(1),traj(i).uf(end),'r.','MarkerSize',4);
        plot(traj(i).t(end)-traj(i).t(1),traj(i).vf(end),'g.','MarkerSize',4);
        plot(traj(i).t(end)-traj(i).t(1),traj(i).wf(end),'b.','MarkerSize',4);
    end
end
hold off
xlabel('$t$ [1/100 sec]','Interpreter','latex');
ylabel('$u$ [cm/s]','Interpreter','latex');
legend([l1,l2,l3],{'\itu','\itv','\itw'})
%
subplot(313)
box on, grid on, hold on,
for i = 1:length(traj)
    if length(traj(i).xf) > 5
        plot(traj(i).t(1)-traj(i).t(1),traj(i).axf(1),'r.','MarkerSize',4);
        plot(traj(i).t(1)-traj(i).t(1),traj(i).ayf(1),'g.','MarkerSize',4);
        plot(traj(i).t(1)-traj(i).t(1),traj(i).azf(1),'b.','MarkerSize',4);

        l1=plot((traj(i).t-traj(i).t(1)),traj(i).axf,'r-','DisplayName',num2str(i));
        l2=plot((traj(i).t-traj(i).t(1)),traj(i).ayf,'g--','DisplayName',num2str(i));
        l3=plot((traj(i).t-traj(i).t(1)),traj(i).azf,'b-.','DisplayName',num2str(i));

        plot(traj(i).t(end)-traj(i).t(1),traj(i).axf(end),'r.','MarkerSize',4);
        plot(traj(i).t(end)-traj(i).t(1),traj(i).ayf(end),'g.','MarkerSize',4);
        plot(traj(i).t(end)-traj(i).t(1),traj(i).azf(end),'b.','MarkerSize',4);
    end
end
hold off
xlabel('$t$ [1/100 sec]','Interpreter','latex');
ylabel('$a$ [cm/s$^2$]','Interpreter','latex');
legend([l1,l2,l3],{'\ita_x','\ita_y','\ita_z'})
end