x = [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8];
% x = [0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4];

%rd 0.4-0.7
y1 = [0.275 0.584 0.702 0.807 0.856 0.823 0.757  0.266];
y2 = [4.52 4.62 4.67 4.62 4.60 4.65 4.67 4.51];

%scale 0.15 0.3
% y1 = [0.266 0.276 0.751 0.826 0.843 0.856 0.856 0.856];
% y2 = [5.82 5.69 4.85 4.6 4.41 3.96 3.55 3.03];

%update 0.3-0.6
% y1 = [0.266  0.475 0.867 0.856 0.872  0.745 0.398 0.267];
% y2 = [3.73  4.05 4.16 4.79 5.07 7.02  7.07 7.15];

[AX,H1,H2] = plotyy(x,y1,x,y2);

set(AX(1),'XColor','k','YColor','k');

set(AX(2),'XColor','k','YColor','k');

HH1=get(AX(1),'Ylabel');
set(HH1,'String','Distance precision at 20 pixels');
set(HH1,'color','k');

HH2=get(AX(2),'Ylabel');
set(HH2,'String','FPS');
set(HH2,'color','k');


set(H1,'LineStyle','-');
set(H1,'color','b');
set(H1,'Marker','s');
set(H1,'LineWidth',2);
set(H2,'LineStyle','-');
set(H2,'color','r');
set(H2,'Marker','v');
set(H2,'LineWidth',2);

legend([H1,H2],{'precision score';'fps'});
title('Re-detection accept Threshold Vs. Score and FPS','FontWeight','bold')
grid on
xlabel('T_r_d');