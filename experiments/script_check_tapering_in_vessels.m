
% SCRIPT_CHECK_TAPERING_IN_VESSELS
% -------------------------------------------------------------------------
% This script reads the .vtk files and check if each segment has linear
% tapering.
% -------------------------------------------------------------------------

clc
clear
close all

% Configurate the script, the script should contain the pixel spacing and image size
config_generate_input_data_vtk;
% input folder
input_folder = fullfile(input_folder, database);
% output folder
output_folder = fullfile(output_folder, database);
% Crates HDidx, the struct containing the hemodynamic indexes in the 
% solution array.
config_hemo_var_idx

%% set up variables

%% retrieve arteries filenames
filenames = dir(fullfile(input_folder, '/input_data/vtk/*.vtk'));
filenames = {filenames.name};

%% process data
errors  = [];
lengths = [];
% for each .vtk file
for i = 1 : length(filenames)
    current_filename       = fullfile(input_folder, 'input_data','vtk', filenames{i});
    fprintf('Processing %s\n', current_filename);
    
    % Retrieve the polydata radius
    polydata      = vtkPolyDataReader(current_filename);
    for a = 1 : numel(polydata.PointDataArrays);
        if (strcmp(polydata.PointDataArrays{a}.Name, 'Radius'));
            iaR = a;
        end;
    end;
    RadiusArray     = polydata.PointDataArrays{iaR}.Array;

    % Loop over all the vessel segments
    for ci = 1 : size(polydata.Cells,1);
        CellI  = polydata.Cells{ci};
        if (numel(CellsI)<=2); % Avoid the bifurcation points.
            continue;
        end;
        points = polydata.Points(CellI(:)+1,:);
        radius = RadiusArray(CellI(:)+1);
        % The linear tapering function
        [ lin_tap, length ] = estimate_linear_tapering( points, radius );
        % Computes the relative error
        rel_error = sum(abs((lin_tap - radius) ./ lin_tap));
        % Adds the error and length to the arrays for future statistics
        errors(end+1)  = rel_error;
        lengths(end+1) = length;
    end;     
end

%% Length threshold for the statistics on the relative errors
threshold = 0;
stats_l = statistics( lengths );
e = errors(lengths>threshold);
stats_e = statistics( e );


