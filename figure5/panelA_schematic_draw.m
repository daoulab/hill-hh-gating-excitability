function panelA_schematic_draw(ax)
%% panelA_schematic_draw  Panel A: from measured gating changes to a prediction.


standalone = (nargin < 1) || isempty(ax);
if standalone
    fig = figure('Color','w','Units','pixels','Position',[60 60 760 700]);
    ax  = axes('Parent',fig,'Position',[0.02 0.02 0.96 0.96]);
end

hold(ax,'on'); axis(ax,'off');
set(ax,'XLim',[0 100],'YLim',[2 100]);
if standalone
    set(ax,'DataAspectRatio',[1 1 1]);
else
    axis(ax,'normal');
end

%% ---------------- palette ----------------
blueE = [0.00 0.13 0.28];   blueF = [0.90 0.94 0.98];   blueT = [0.00 0.13 0.28];
orgE  = [0.89 0.39 0.08];   orgF  = [0.99 0.93 0.86];   orgT  = [0.85 0.31 0.03];
grayE = [0.30 0.30 0.30];   grayF = [0.95 0.95 0.96];   grayT = [0.12 0.12 0.12];
bodyT = [0.10 0.10 0.10];

FS  = 10;      % body text
FSB = 11.5;    % box headings
FSH = 13;      % branch names

%% ---------------- top: what the study measured ----------------
box(ax,18,86,64,13,grayF,grayE,1.4);
ctr(ax,50,95.6,'Measured gating changes',FSB,grayT,'bold');
ctr(ax,50,90.0,'Steady-state midpoints and slopes',FS,bodyT,'normal');

% split: down, across, then into each branch
line(ax,[50 50],[86 81],'Color',grayE,'LineWidth',1.4);
line(ax,[50 25],[81 81],'Color',blueE,'LineWidth',1.6);
line(ax,[50 75],[81 81],'Color',orgE ,'LineWidth',1.6);
arrowDown(ax,25,81,77.4,blueE,1.6);
arrowDown(ax,75,81,77.4,orgE ,1.6);

%% ---------------- the two formulations ----------------
box(ax,2,46,46,31,blueF,blueE,1.6);
ctr(ax,25,72.6,'Hill-HH',FSH,blueT,'bold');
ctr(ax,25,65.8,'Calculate activation parameters',FS,bodyT,'normal');
ctr(ax,25,62.0,'directly from measured',FS,bodyT,'normal');
ctr(ax,25,58.2,'midpoint and slope',FS,bodyT,'normal');
ctr(ax,25,51.4,'With the Hill shift specified',FS,blueT,'bold');

box(ax,52,46,46,31,orgF,orgE,1.6);
ctr(ax,75,72.6,'Classical HH',FSH,orgT,'bold');
ctr(ax,75,64.4,'Shift or fit rate functions',FS,bodyT,'normal');
ctr(ax,75,60.6,'to reproduce measured',FS,bodyT,'normal');
ctr(ax,75,56.8,'gating curves',FS,bodyT,'normal');

% merge: both branches down to a shared line, then one arrow
line(ax,[25 25],[46 40.5],'Color',grayE,'LineWidth',1.4);
line(ax,[75 75],[46 40.5],'Color',grayE,'LineWidth',1.4);
line(ax,[25 75],[40.5 40.5],'Color',grayE,'LineWidth',1.4);
arrowDown(ax,50,40.5,36.4,grayE,1.4);

%% ---------------- what both formulations still need ----------------
box(ax,10,23,80,13,grayF,grayE,1.4);
ctr(ax,50,32.6,'Both models',FSB,grayT,'bold');
ctr(ax,50,27.0,'Specify inactivation and kinetic assumptions',FS,bodyT,'normal');

arrowDown(ax,50,23,18.4,grayE,1.4);

%% ---------------- the prediction ----------------
box(ax,10,5,80,13,grayF,grayE,1.4);
ctr(ax,50,14.6,'Predict threshold and firing',FSB,grayT,'bold');
ctr(ax,50,9.0,'Under the chosen assumptions',FS,bodyT,'normal');

%% ---------------- export when run on its own ----------------
if standalone
    exportgraphics(fig,'PanelA_schematic.pdf','ContentType','vector');
    exportgraphics(fig,'PanelA_schematic.eps','ContentType','vector');
    exportgraphics(fig,'PanelA_schematic.png','Resolution',600);
    fprintf('saved PanelA_schematic.pdf / .eps / .png\n');
end
end

%% ===================== drawing helpers =====================
function box(ax,x,y,w,h,face,edge,lw)
% rounded rectangle; Curvature is relative, so scale it with the box size
    c = min(0.28, 3.2/max(w,h));
    rectangle(ax,'Position',[x y w h],'Curvature',[c c*w/h], ...
              'FaceColor',face,'EdgeColor',edge,'LineWidth',lw);
end

function ctr(ax,x,y,s,fs,col,weight)
% centred single line of text
    text(ax,x,y,s,'HorizontalAlignment','center','VerticalAlignment','middle', ...
         'FontSize',fs,'Color',col,'FontWeight',weight,'Interpreter','tex');
end

function bul(ax,x,y,s,fs,col)                                      %#ok<DEFNU>
% bulleted, left-aligned line (kept for reuse; not used in this layout)
    plot(ax,x-2.6,y,'o','MarkerSize',2.6,'MarkerFaceColor',col,'MarkerEdgeColor',col);
    text(ax,x,y,s,'HorizontalAlignment','left','VerticalAlignment','middle', ...
         'FontSize',fs,'Color',col,'Interpreter','tex');
end

function arrowDown(ax,x,yFrom,yTo,col,lw)
% vertical arrow with a filled head at yTo
    L = 2.6; W = 1.5;
    line(ax,[x x],[yFrom yTo+L*0.8],'Color',col,'LineWidth',lw);
    patch(ax,'XData',[x x-W x+W],'YData',[yTo yTo+L yTo+L], ...
          'FaceColor',col,'EdgeColor',col);
end