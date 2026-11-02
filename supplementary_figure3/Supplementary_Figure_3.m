function Supplementary_Figure_3()

close all;
clc;


%% =====================================================================
% Settings
% ======================================================================

% Representative current used for both firing-pattern panels
Iapp_trace = 40;     % uA/cm^2

% Colors used throughout the figure
navy   = [0.00 0.13 0.28];
orange = [0.86 0.45 0.06];

% Figure-wide font
fontName = 'Arial';
fontSize = 9;


%% =====================================================================
% Load precomputed data
% ======================================================================

HH_rheo = ...
    load('classicalHH_rheobase_data.mat');

MOD_rheo = ...
    load('modified_rheobase_data.mat');

HH_fI = ...
    load('classicalHH_fI_data.mat');

MOD_fI = ...
    load('modified_fI_data.mat');


%% =====================================================================
% Create figure
% ======================================================================

fig = figure( ...
    'Units','inches', ...
    'Position',[0.5 0.5 8.6 13.5], ...
    'Color','w');


%% =====================================================================
% Panels containing the two model blocks
% ======================================================================

% ----------------------------------------------------------------------
% Top block: Original HH
% ----------------------------------------------------------------------

panelTop = uipanel( ...
    'Parent', fig, ...
    'Units', 'normalized', ...
    'Position', [0.07 0.5 0.92 0.495], ...
    'BorderType', 'none', ...
    'BackgroundColor', 'w');


% ----------------------------------------------------------------------
% Bottom block: Modified Hill-HH
% ----------------------------------------------------------------------

panelBottom = uipanel( ...
    'Parent', fig, ...
    'Units', 'normalized', ...
    'Position', [0.07 0.0 0.92 0.495], ...
    'BorderType', 'none', ...
    'BackgroundColor', 'w');


%% =====================================================================
% Tiled layouts inside each panel
% ======================================================================

tlTop = tiledlayout( ...
    panelTop, ...
    2, 2, ...
    'TileSpacing','compact', ...
    'Padding','compact');


tlBottom = tiledlayout( ...
    panelBottom, ...
    2, 2, ...
    'TileSpacing','compact', ...
    'Padding','compact');


%% =====================================================================
% A. Original HH gating
% ======================================================================

axA = nexttile(tlTop, 1);

plot_classicalHH_gating(axA);

formatPanel(axA, fontName, fontSize);

addPanelLetter(axA, 'a');


%% =====================================================================
% B. Original HH rheobase ratios
% ======================================================================

axB = nexttile(tlTop, 2);

plotRheobasePanel( ...
    axB, ...
    HH_rheo, ...
    navy, ...
    orange);

formatPanel(axB, fontName, fontSize-0.5);

addPanelLetter(axB, 'b');


%% =====================================================================
% C. Original HH representative firing pattern
% ======================================================================

axC = nexttile(tlTop, 3);

plot_classicalHH_trace( ...
    axC, ...
    Iapp_trace);

formatPanel(axC, fontName, fontSize);

addPanelLetter(axC, 'c');


%% =====================================================================
% D. Original HH f-I curve
% ======================================================================

axD = nexttile(tlTop, 4);

plotFIPanel( ...
    axD, ...
    HH_fI, ...
    navy, ...
    orange);

formatPanel(axD, fontName, fontSize);

addPanelLetter(axD, 'd');


%% =====================================================================
% E. Modified Hill-HH gating
% ======================================================================

axE = nexttile(tlBottom, 1);

plot_modified_gating(axE);

formatPanel(axE, fontName, fontSize);

addPanelLetter(axE, 'e');


%% =====================================================================
% F. Modified Hill-HH rheobase ratios
% ======================================================================

axF = nexttile(tlBottom, 2);

plotRheobasePanel( ...
    axF, ...
    MOD_rheo, ...
    navy, ...
    orange);

formatPanel(axF, fontName, fontSize-0.5);

addPanelLetter(axF, 'f');


%% =====================================================================
% G. Modified Hill-HH representative firing pattern
% ======================================================================

axG = nexttile(tlBottom, 3);

plot_modified_trace( ...
    axG, ...
    Iapp_trace);

formatPanel(axG, fontName, fontSize);

addPanelLetter(axG, 'g');


%% =====================================================================
% H. Modified Hill-HH f-I curve
% ======================================================================

axH = nexttile(tlBottom, 4);

plotFIPanel( ...
    axH, ...
    MOD_fI, ...
    navy, ...
    orange);

formatPanel(axH, fontName, fontSize);

addPanelLetter(axH, 'h');


%% =====================================================================
% Make corresponding panels directly comparable
% ======================================================================

% ----------------------------------------------------------------------
% Gating panels
% ----------------------------------------------------------------------

xlim(axA, [-130 40]);
xlim(axE, [-130 40]);

ylim(axA, [0 1.02]);
ylim(axE, [0 1.02]);


% ----------------------------------------------------------------------
% Firing-pattern panels
%
% Same axes are useful for direct visual comparison.
% ----------------------------------------------------------------------

linkaxes([axC axG], 'xy');
% ---------------- Stimulation bars (as in S1) ----------------
yl = ylim(axC);
ylim(axC, [yl(1) yl(2)+30]);      % linked, so applies to axG too
y_bar = yl(2) + 8;

for ax = [axC axG]
    hold(ax,'on');
    plot(ax, [50 150], [y_bar y_bar], 'k', 'LineWidth', 1.4, ...
        'HandleVisibility','off');
    text(ax, 100, y_bar + 3, sprintf('I_{app} = %d \\muA/cm^2', Iapp_trace), ...
        'HorizontalAlignment','center', 'VerticalAlignment','bottom', ...
        'FontName',fontName, 'FontSize',fontSize);
    hold(ax,'off');
end


% ----------------------------------------------------------------------
% f-I panels
%
% Use common limits based on both datasets.
% ----------------------------------------------------------------------

maxCurrent = max([ ...
    HH_fI.Iapp_uA_cm2(:); ...
    MOD_fI.Iapp_uA_cm2(:)]);

maxFreq = max([ ...
    HH_fI.freq_WT_Hz(:); ...
    HH_fI.freq_A863P_Hz(:); ...
    MOD_fI.freq_WT_Hz(:); ...
    MOD_fI.freq_A863P_Hz(:)]);

xlim(axD, [0 maxCurrent]);
xlim(axH, [0 maxCurrent]);

ylim(axD, [0 1.08*maxFreq]);
ylim(axH, [0 1.08*maxFreq]);


%% =====================================================================
% Force MATLAB to finish calculating tiled-layout positions
% ======================================================================

drawnow;


%% =====================================================================
% Detach axes from UI panels before export
%
% The uipanels are useful for constructing the desired layout, but
% exportgraphics may omit UI-container content.
%
% Therefore:
%
%   1. Capture the exact absolute pixel position of every axes.
%   2. Reparent each axes directly to the figure.
%   3. Restore the exact captured position.
%   4. Delete the UI panels.
%
% No plotting positions are intentionally changed.
% ======================================================================

allAxes = [ ...
    axA, axB, ...
    axC, axD, ...
    axE, axF, ...
    axG, axH];


% ----------------------------------------------------------------------
% Capture absolute positions BEFORE changing any parent
% ----------------------------------------------------------------------

axPixelPos = zeros(8,4);

for k = 1:8

    axPixelPos(k,:) = ...
        getpixelposition(allAxes(k), true);

end


% ----------------------------------------------------------------------
% Reparent directly to the figure
% ----------------------------------------------------------------------

for k = 1:8

    set(allAxes(k), ...
        'Parent', fig, ...
        'Units', 'pixels', ...
        'Position', axPixelPos(k,:));

end


% ----------------------------------------------------------------------
% Remove UI containers after axes have been detached
% ----------------------------------------------------------------------

delete(panelTop);
delete(panelBottom);

drawnow;
%% =====================================================================
% Recreate legends after detaching axes from UI panels
% ======================================================================

% -------------------- A: Classical gating -----------------------------

lgdA=legend(axA, ...
    {'h_\infty, WT', ...
     'h_\infty, AP', ...
     'm_\infty, WT', ...
     'm_\infty, AP'}, ...
    'Location', 'east', ...
    'Box', 'off');
lgdA.Units = 'normalized';
lgdA.Position(1) = lgdA.Position(1) + 0.019;


% -------------------- C: Classical firing pattern ---------------------

lgdC=legend(axC, ...
    {'WT', 'AP'}, ...
    'Location', 'northeast', ...
    'Box', 'off');
lgdC.Units = 'normalized';
lgdC.Position(1) = lgdC.Position(1) + 0.01;



% -------------------- D: Classical f-I -------------------------------

legend(axD, ...
    {'WT', 'AP'}, ...
    'Location', 'northwest', ...
    'Box', 'off');


% -------------------- E: Modified gating ------------------------------

lgdE=legend(axE, ...
    {'h_\infty, WT', ...
     'h_\infty, AP', ...
     'm_\infty, WT', ...
     'm_\infty, AP'}, ...
    'Location', 'east', ...
    'Box', 'off');
lgdE.Units = 'normalized';
lgdE.Position(1) = lgdE.Position(1) + 0.019;


% -------------------- G: Modified firing pattern ----------------------

lgdG=legend(axG, ...
    {'WT', 'AP'}, ...
    'Location', 'northeast', ...
    'Box', 'off');
lgdG.Units = 'normalized';
lgdG.Position(1) = lgdG.Position(1) + 0.01;


% -------------------- H: Modified f-I --------------------------------

legend(axH, ...
    {'WT', 'AP'}, ...
    'Location', 'northwest', ...
    'Box', 'off');

drawnow;


%% =====================================================================
% Separator between Original HH and Modified Hill-HH
% ======================================================================

annotation(fig, ...
    'line', ...
    [0.08 0.9], ...
    [0.5 0.5], ...
    'Color', [0.65 0.65 0.65], ...
    'LineWidth', 1);


%% =====================================================================
% Vertical model labels
% ======================================================================

annotation(fig, ...
    'textbox', ...
    [0.24 0.65 0.2 0.40], ...
    'String', 'Original HH model', ...
    'Rotation', 90, ...
    'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'middle', ...
    'FontName', fontName, ...
    'FontSize', 12, ...
    'FontWeight', 'bold', ...
    'EdgeColor', 'none');


annotation(fig, ...
    'textbox', ...
    [0.24 0.2 0.2 0.40], ...
    'String', 'Modified HH model', ...
    'Rotation', 90, ...
    'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'middle', ...
    'FontName', fontName, ...
    'FontSize', 12, ...
    'FontWeight', 'bold', ...
    'EdgeColor', 'none');


%% =====================================================================
% Export
% ======================================================================

drawnow;


% ----------------------------------------------------------------------
% PDF: vector output
% ----------------------------------------------------------------------

W = fig.Position(3); H = fig.Position(4);   % assumes fig Units are inches
set(fig,'PaperUnits','inches','PaperSize',[8.6 13.5],'PaperPosition',[0 0 8.6 13.5]);
print(fig,'Supplementary_Figure3.pdf','-dpdf','-vector');
exportgraphics(fig,'Supplementary_Figure3.png','Resolution',600);




end


%% =====================================================================
%% Rheobase panel
% ======================================================================

function plotRheobasePanel(ax, data, navy, orange)

hold(ax, 'on');

% Expected order:
%
%   1 = Activation only
%   2 = Inactivation only
%   3 = Combined

ratios = ...
    data.rheobase_ratio(:);

x = 1:numel(ratios);


% ----------------------------------------------------------------------
% Bars
% ----------------------------------------------------------------------

b = bar( ...
    ax, ...
    x, ...
    ratios, ...
    0.55, ...
    'FaceColor', 'flat', ...
    'EdgeColor', 'none');


% Use mutation color because all three bars represent A863P perturbations

for k = 1:numel(ratios)

    b.CData(k,:) = orange;

end


% ----------------------------------------------------------------------
% WT reference
% ----------------------------------------------------------------------

% yline( ...
%     ax, ...
%     1, ...
%     '--', ...
%     'Color', navy, ...
%     'LineWidth', 1.2);


% ----------------------------------------------------------------------
% Labels
% ----------------------------------------------------------------------

set(ax, ...
    'XTick', x, ...
    'XTickLabel', { ...
        'Activation', ...
        'Inactivation', ...
        'Combined'});


 ylabel(ax, ...
    'AP/WT Rheobase Ratio  ');



xlim(ax, ...
    [0.4 numel(ratios)+0.6]);


% ----------------------------------------------------------------------
% Numerical value above each bar
% ----------------------------------------------------------------------

for k = 1:numel(ratios)

    text( ...
        ax, ...
        x(k), ...
        ratios(k) + 0.025, ...
        sprintf('%.3f', ratios(k)), ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'bottom', ...
        'FontSize', 8);

end


maxY = ...
    max([1; ratios]);


ylim(ax, ...
    [0 maxY*1.18]);


grid(ax, 'on');

hold(ax, 'off');

end


%% =====================================================================
%% f-I panel
% ======================================================================

function plotFIPanel(ax, data, navy, orange)

hold(ax, 'on');


% ----------------------------------------------------------------------
% WT
% ----------------------------------------------------------------------

plot( ...
    ax, ...
    data.Iapp_uA_cm2, ...
    data.freq_WT_Hz, ...
    '-o', ...
    'Color', navy, ...
    'MarkerFaceColor', navy, ...
    'MarkerSize', 3.5, ...
    'LineWidth', 1.4, ...
    'DisplayName', 'WT');


% ----------------------------------------------------------------------
% AP
% ----------------------------------------------------------------------

plot( ...
    ax, ...
    data.Iapp_uA_cm2, ...
    data.freq_A863P_Hz, ...
    '-o', ...
    'Color', orange, ...
    'MarkerFaceColor', orange, ...
    'MarkerSize', 3.5, ...
    'LineWidth', 1.4, ...
    'DisplayName', 'AP');


xlabel(ax, ...
    'I_{app} (\muA/cm^2)');


ylabel(ax, ...
    'Firing frequency (Hz)');


legend( ...
    ax, ...
    'Location', 'northwest', ...
    'Box', 'off');


grid(ax, 'on');

hold(ax, 'off');

end


%% =====================================================================
%% Common axes formatting
% ======================================================================

function formatPanel(ax, fontName, fontSize)

set(ax, ...
    'FontName', fontName, ...
    'FontSize', fontSize, ...
    'LineWidth', 0.9, ...
    'Box', 'off', ...
    'TickDir', 'out', ...
    'XGrid', 'on', ...
    'YGrid', 'on', ...
    'GridLineStyle', '-', ...
    'GridAlpha', 0.08);

end


%% =====================================================================
%% Panel letters
% ======================================================================

function addPanelLetter(ax, letter)

% Default position for A, B, C, E, F, G
x = -0.133;
y = 0.98;


% Move D and H farther to the left
if strcmp(letter, 'd') || strcmp(letter, 'h')

    x = -0.138;

end

% Move B and F farther to the left
if strcmp(letter, 'b') || strcmp(letter, 'f')

    x = -0.115;

end


text( ...
    ax, ...
    x, ...
    y, ...
    letter, ...
    'Units', 'normalized', ...
    'FontWeight', 'bold', ...
    'FontSize', 14, ...
    'HorizontalAlignment', 'left', ...
    'VerticalAlignment', 'bottom', ...
    'Clipping', 'off');

end