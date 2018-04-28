function [ fitf, type ] = fit_point_data( data, func )
%FIT_POINT_DATA Fits the data points with a function.
% Given a set of data, find an approximated function y = f(x) that fits the
% data with less error. The type of function is defind in the func 
% parameter.
%   
% Parameters:
% data: The input data, a matrix of (n,2) where the first column is the x
% values and the second column contains the y values.
% func: String specifying the type of function to used in the
% approximation. It can be one of the following:
% - 'pol1' Polynomial of order 1 (linear).
% - 'pol2' Polynomial of order 2 (quadric).
% - 'pol3' Polynomial of order 3 (qubic).
% - 'exp'  Exponential
% - 'best' Try all the others and compares the mean square error and use the
% on with the lower error.
% 
% Retunrs:
% fitf: Array of coefficients of the approximated function.
% type: The type of approximation function used, is a copy of the func
% argument except when func=best, in which case the best approximation code
% is returned.
% 

func_lib = {'pol1','pol2','pol3','exp','best'};
idx_func = find( strcmp([func_lib], func));
if (isempty(idx_func)) 
    warning(strcat('Invalid func type(',func,', default (best) is used!'))
    func = 'best';
end;

x    = data(:,1);
y    = data(:,2);
type = func;

if (idx_func==1 || idx_func==5);
    f_pol1 = polyfit(x,y,1);
    fitf = f_pol1;
end;
if (idx_func==2 || idx_func==5);
    f_pol2 = polyfit(x,y,2);
    fitf = f_pol2;
end;
if (idx_func==3 || idx_func==5);
    f_pol3 = polyfit(x,y,3);
    fitf = f_pol3;
end;
if (idx_func==4 || idx_func==5);
    log_y = log(y);
    f_exp = polyfit(x,log_y,1);
    fitf  = f_exp;
end;

if (idx_func==5);
    v_pol1    = polyval(f_pol1,x);
    v_pol2    = polyval(f_pol2,x);
    v_pol3    = polyval(f_pol3,x);
    errors    = nan(4,1);
    errors(1) = (y-v_pol1)^2.;
    errors(2) = (y-v_pol2)^2.;
    errors(3) = (y-v_pol3)^2.;
    
    v_exp     = polyval(f_exp,log_x);
    errors(4) = (y-exp(v_exp))^2.;
    
    [~,i] = min(errors);
    type = func_lib(i);
end;

end

