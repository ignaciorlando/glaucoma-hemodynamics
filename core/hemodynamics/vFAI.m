function [ vfai ] = vFAI( P0, P11, P12, Q1, Q2, QI )
%VFAI Computes the virtual Functional Assessment Index (vFAI), see Papafaklis et al. (2014).
% Defined as the area under the curve relating pressure ratio (P1/P0) to 
% flow rate (Q). Which is estimated from the relation ∆P = fv Q + fs Q², 
% where the coefficient for pressure lost due to viscous and separation 
% effects are obtained from pressures resulting from CFD simulations at 
% two different fixed flow rates.
%
% Parameters:
% P0: The proximal pressure value for each data sample. The index assume
% that this value is the same for both simulations. In [mmHg].
% P11: The distal pressure value for each data sample for simulation 1.
%      In [mmHg].
% P12: The distal pressure value for each data sample for simulation 2.
%      In [mmHg].
% Q1:  Flow rate for each data sample for simulation 1. Smaller than Q2.
%      In [cm^3/s].
% Q2:  Flow rate for each data sample for simulation 2. Larger than Q1.
%      In [cm^3/s].
% QI:  The flow integration limits for all data samples, an array with two 
%      values. If empty, then the limits of integration at each data sample
%      will be the associated Q1 and Q2 values.
%      In [cm^3/s].
%
% Return:
% vfai: The vFAI value for each point in the input
%
%
% References: 
% @article{Papafaklis_vFAI-2014,
%	title       = {Fast virtual functional assessment of intermediate coronary lesions using routine angiographic data and blood flow simulation in humans: comparison with pressure wire – fractional flow reserve},
%	volume      = {10},
%	issn        = {1774-024X},
%	url         = {http://www.pcronline.com/eurointervention/76th_issue/100},
%	doi         = {10.4244/EIJY14M07_01},
%	pages       = {574--583},
%	number      = {5},
%	journaltitle = {{EuroIntervention}},
%	author      = {Papafaklis, Michail I. and Muramatsu, Takashi and Ishibashi, Yuki and Lakkas, Lampros S. and Nakatani, Shimpei and Bourantas, Christos V. and Ligthart, Jurgen and Onuma, Yoshinobu and Echavarria-Pinto, Mauro and Tsirka, Georgia and Kotsia, Anna and Nikas, Dimitrios N. and Mogabgab, Owen and van Geuns, Robert-Jan and Naka, Katerina K. and Fotiadis, Dimitrios I. and Brilakis, Emmanouil S. and Garcia-Garcia, Héctor M. and Escaned, Javier and Zijlstra, Felix and Michalis, Lampros K. and Serruys, Patrick W.},
%	date        = {2014-09} }
%

% Constant to convert from mmHg to [dyn s/cm^2]
mmHg2dynscm2 = 1333.22;
P0  = P0  * mmHg2dynscm2;
P11 = P11 * mmHg2dynscm2;
P12 = P12 * mmHg2dynscm2;

% Prepear the ,data
n = numel(P0);
vfai = nan(size(P0));
dP1 = P0 - P11;
dP2 = P0 - P12;

% Find the coefficients fs and fv for each data sample
% fv = fs Q1 - ∆P1/Q1
% fv = fs Q2 - ∆P2/Q2
% fs Q1 - ∆P1/Q1 = fs Q2 - ∆P2/Q2
% fs = (∆P2/Q2 - ∆P1/Q1) / (Q2-Q1)
fs =  (dP2./Q2 - dP1./Q1) ./ (Q2-Q1);
fv = fs.*Q1 - dP1./Q1;

% Finds the relationship between pressure ratios and flow
% ∆P = P0-P1 = fv Q + fs Q²
% P1/P0 = 1 - (fv/P0) Q - (fs/P0) Q²

% Integrate the pressure ratio polynomial for each data sample between the
% limits given by Q1 and Q2 or by a fixed integration range if applicable.
for i = 1 : n;
    % Create a vector to represent the polynomial
    prp = [-(fs(i)/P0(i)) -(fv(i)/P0(i)) 1];
    % Use polyint to integrate the polynomial using a constant of integration equal to 0.
    q = polyint(prp);
    % define the limits of integration
    limits = [Q1(i) Q2(i)];
    if (~isempty(QI));
        limits = QI;
    end;
    % Comptes the integration
    vfai(i) = diff(polyval(q,limits));
end;


end

