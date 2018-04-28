function [ sol, sol_condense ] = vtkSimulationResultImporter( vtkFile, imgSize, spacing,roots, HDidx )
%VTKSIMULATIONRESULTIMPORTER Imports a vtk file into a matlab matrix.
% Reads the vtk file containing the solution of a simulation and generates
% amatrix of (X,Y,N) where XX and Y are the image dimension and N are the
% number of variables imported from the simulation.
%
% Parameters:
% vtkFile: The ful path to the vtk file.
% imgSize: Array containing the x and y sizes of the resulting image. Note
%          that this sizes should be large enough to fit the input vtk
%          points coordinates. No size check is perform.
% spacing: The pixel spacing, used to convert point coordinates into image
%          indexes.
% roots:   Array of (N,3) containing the x,y and z coordinates for the N
%          roots of the arterial tree in the input vtk.
% HDidx:   The struct containing the hemodynamic indexes in the solution
%          array.
%
% Returns: 
% sol:   The solution of the simulation, it is a marix of dimensions 
% (imgSize(1),imgSize(2),HDidx.mask), contining at each skeleton pixel the 
% variables and a Mask with "nan" everywhere else. 
% The mask indicates 1 for root, 2 for terminal, 3 for bifurcation point 
% and a negative integer for each disctinct vessel segment (vtk cell).
%
% sol_condense: A cell array containing statistics over each arterial
% segment, bifurcation and terminal. In the case of terminal and
% bifurcation, the statistics (mean, std, etc) has no meaning, the value is
% put for completness. Statistics are computed in the same order as the
% variables in the third dimension of the sol array.
%

sol = nan([imgSize,HDidx.mask]);

polydata      = vtkPolyDataReader(vtkFile);
for a = 1 : numel(polydata.PointDataArrays);
    if (strcmp(polydata.PointDataArrays{a}.Name, 'HD_Flux'));
        iaQ = a;
    elseif (strcmp(polydata.PointDataArrays{a}.Name, 'HD_Pressure'));
        iaP = a;
    elseif (strcmp(polydata.PointDataArrays{a}.Name, 'Radius'));
        iaR = a;
    elseif (strcmp(polydata.PointDataArrays{a}.Name, 'HD_Resistance'));
        iaResistance = a;
    elseif (strcmp(polydata.PointDataArrays{a}.Name, 'HD_Reynolds'));
        iaRe = a;
    elseif (strcmp(polydata.PointDataArrays{a}.Name, 'HD_WSS'));
        iaWSS = a;
    end;
end;
FlowArray       = polydata.PointDataArrays{iaQ}.Array;
PressureArray   = polydata.PointDataArrays{iaP}.Array;
RadiusArray     = polydata.PointDataArrays{iaR}.Array;
ResistanceArray = polydata.PointDataArrays{iaResistance}.Array;
ReynoldsArray   = polydata.PointDataArrays{iaRe}.Array;
WSSArray        = polydata.PointDataArrays{iaWSS}.Array;
% First set all pressure and flows, and the mask is set to zero (segment)
% by default.
for p = 1 : size(polydata.Points,1);
    i = round(polydata.Points(p,1) / spacing(1));
    j = round(polydata.Points(p,2) / spacing(2));
    sol(i,j,HDidx.r)    = RadiusArray(p);
    sol(i,j,HDidx.q)    = FlowArray(p);
    sol(i,j,HDidx.p)    = PressureArray(p);
    sol(i,j,HDidx.v)    = FlowArray(p) / (pi * RadiusArray(p)^2);
    sol(i,j,HDidx.res)  = ResistanceArray(p);
    sol(i,j,HDidx.re)   = ReynoldsArray(p);
    sol(i,j,HDidx.wss)  = WSSArray(p);
    sol(i,j,HDidx.mask) = 0;
end;
% Now set all the roots mask to one
for r = 1 : size(roots, 1);
    i = round(roots(r,1) / spacing(1));
    j = round(roots(r,2) / spacing(2));
    sol(i,j,HDidx.mask) = 1;
end;
% Now set all the terminal and bifurcation mask to two and three, and
% identify the segments with an id number that is negative;
id_seg = 0;
for ci = 1 : size(polydata.Cells,1);
    CellI = polydata.Cells{ci};
    i = round(polydata.Points(CellI(end)+1,1) / spacing(1));
    j = round(polydata.Points(CellI(end)+1,2) / spacing(2));
    isTerminal = 1;
    for cj = 1 : size(polydata.Cells,1);
        CellJ = polydata.Cells{cj};
        if (CellI(end)==CellJ(1));
            isTerminal = 0;
            break;
        end;
    end;
    if (isTerminal==1);
        sol(i,j,HDidx.mask) = 2;
    end;
    % If the cell is a bifurcation, then it contains only two points, with
    % the same id
    if (numel(CellI)==2 && CellI(1)==CellI(2));
        sol(i,j,HDidx.mask) = 3;
    end;    
    
    % loop puting the segment id to all the pixels
    id_seg = id_seg - 1;
    for p = 1 : numel(CellI);
        i = round(polydata.Points(CellI(p)+1,1) / spacing(1));
        j = round(polydata.Points(CellI(p)+1,2) / spacing(2));
        if (sol(i,j,HDidx.mask) == 0);
            sol(i,j,HDidx.mask) = id_seg;
        end;
    end;
end;

%% Computes the condense solution
% In which the mean and standard deviations of each variable is computed 
% and stored in a cell array of statistics.
sol_condense = cell(0,HDidx.mask);
current_stat = 1;
for ci = 1 : size(polydata.Cells,1);
    CellI = polydata.Cells{ci};
    i = round(polydata.Points(CellI(end)+1,1) / spacing(1));
    j = round(polydata.Points(CellI(end)+1,2) / spacing(2));
    
    if (numel(CellI)==2 && CellI(1)==CellI(2)); %if (sol(i,j,HDidx.mask) == 3);
        % If the cell is a bifurcation
        vessel = nan(2,HDidx.mask);
        vessel(1,:) = sol(i,j,:);        
        vessel(2,:) = sol(i,j,:);
        for var = 1 : HDidx.mask;
            sol_condense{current_stat,var} = statistics(vessel(:,var));
        end;    
        current_stat = current_stat + 1;
        continue;
    elseif (sol(i,j,HDidx.mask) == 2);
        % If the last pixel of the cell is a terminal, then create a new
        % terminal statistic
        vessel = nan(2,HDidx.mask);
        vessel(1,:) = sol(i,j,:);        
        vessel(2,:) = sol(i,j,:);
        for var = 1 : HDidx.mask;
            sol_condense{current_stat,var} = statistics(vessel(:,var));
        end;    
        current_stat = current_stat + 1;
    end;
    % If the cell contains only two points, it is taken into consideration
    % by the terminal or bifurcations, it does not count.
    if (numel(CellI)==2); continue; end;
    vessel = nan(numel(CellI)-2,HDidx.mask);
    for p = 1 : numel(CellI)-2;
        % It starts in the second pixel and ends one before the last to
        % avoid the root/bifurcation/terminal overlapping
        i = round(polydata.Points(CellI(p+1)+1,1) / spacing(1));
        j = round(polydata.Points(CellI(p+1)+1,2) / spacing(2));
        vessel(p,:) = sol(i,j,:);
    end;
    for var = 1 : HDidx.mask;
        sol_condense{current_stat,var} = statistics(vessel(:,var));
    end;    
    current_stat = current_stat + 1;
    
end;

end
