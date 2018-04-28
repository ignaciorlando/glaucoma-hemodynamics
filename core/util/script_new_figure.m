
% SCRIPT_NEW_FIGURE
% -------------------------------------------------------------------------
% This script creates a new figure with a pre-set layout and configuration
% parameters.
% -------------------------------------------------------------------------

figSize = 1.2*[.1 .1 .225 .3];

figure('units','normalized','position',figSize);
set(gcf,'DefaultLineLineWidth',1, 'DefaultAxesFontSize',20,...
    'DefaultTextFontSize',20,...
    'DefaultTextInterpreter','latex',...
    'DefaultLineMarkerSize', 5,...
    'DefaultLineMarker', 'o')
hold on; 
box on; 
grid on;