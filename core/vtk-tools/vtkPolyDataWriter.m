function [  ] = vtkPolyDataWriter( polydata, file )
%VTKPOLYDATAWRITER Writes the polydata input to an vtk legacy ascii file.
% polydata: An structure containing a matrix of n times 3, which defines
%           the points spatial coordinates (x,y,z); and a cell array
%           containing the lists of points id (atarting at 1) that form
%           each vtk cell. Alternative, if the polydata contains any
%           non-empty pointdata and celldata cell structures in the form
%           array name, dimension, values, they are saved.
% file:     The full path to the file that willl be created/overwitten with
%           the polydata
%

%  filename in VTK format.
np = size(polydata.Points, 1);
nc = numel(polydata.Cells2);
fid = fopen(file, 'wt');
fprintf(fid, '# vtk DataFile Version 4.0\n');
fprintf(fid, 'Generated using MATLAB function vtkPolyDataWriter\n');
fprintf(fid, 'ASCII\n');
fprintf(fid, 'DATASET POLYDATA\n');
fprintf(fid, 'POINTS    %d   float\n', np);
fprintf(fid, '%1.10E %1.10E %1.10E \n', polydata.Points');
fprintf(fid, '\n');
fprintf(fid, 'LINES %d %d\n', nc, nc*3);

for c = 1 : nc;
    cell2 = polydata.Cells2{c};
    npc  = numel(cell2);
    fprintf(fid, '%d ', npc);
    for p = 1 : npc;
        % When saving the point id, the substraction ensures that ids
        % starts at 0 as stated in the vtk format.
        fprintf(fid, '%d ', cell2(p) - 1);
    end
    fprintf(fid, '\n');
end
fprintf(fid, '\n');
npda = numel(polydata.PointDataArrays);
if (1 <= npda);
    fprintf(fid, 'POINT_DATA   %d\n', np);
    fprintf(fid, 'FIELD FieldData %d\n', npda);
    for a = 1 : npda;
        DA = polydata.PointDataArrays{a};
        fprintf(fid, '%s %d %d double\n', DA.Name, DA.Dimension, np);
        fprintf(fid, '%1.10E \n', DA.Array);
    end
end
fprintf(fid, '\n');
ncda = numel(polydata.CellDataArrays);
if (1 <= ncda);
    fprintf(fid, 'CELL_DATA   %d\n', nc);
    fprintf(fid, 'FIELD FieldData %d\n', ncda);
    for a = 1 : ncda;
        DA = polydata.PointDataArrays{a};
        fprintf(fid, '%s %d %d double\n', DA.Name, DA.Dimension, nc);
        fprintf(fid, '%1.10E ', DA.Array);
    end
end

fclose(fid);
end

