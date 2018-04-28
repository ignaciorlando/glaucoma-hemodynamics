
% CONFIG_HEMO_VAR_IDX
% -------------------------------------------------------------------------
% This script sets the indexes of the hemodynamic variables for the arrays 
% containing the solutions.
% -------------------------------------------------------------------------

% HDidx:   The struct containing the hemodynamic indexes in the solution
%          array.
HDidx.r    = 1; % Radius
HDidx.q    = 2; % Flow
HDidx.p    = 3; % Pressure
HDidx.v    = 4; % Velosity
HDidx.res  = 5; % Resistance
HDidx.re   = 6; % Reynolds
HDidx.wss  = 7; % Wall Shear Stress
HDidx.mask = 8; % Mask
