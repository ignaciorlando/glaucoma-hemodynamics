function [ polydata ] = vtkPolyDataReader( file )
%VTKPOLYDATAREADER Reads a vtk legacy ascii file (POLYDATA).
%
% Parameters:
% file:     The full path to the file that willl be read.
%
% Returns:
% polydata: An lineucture containing the polydata.
%
% Based on the code available at:
% https://www.mathworks.com/matlabcentral/fileexchange/29344-read-medical-data-3d?focused=5186817&tab=function
%

fid = fopen(file,'rb');
if(fid < 0);
    fprintf('Error::vtkPolyDataReader: Could not open file %s\n',file);
    return;
end;
CellDataArrays   = {};

line               = fgetl(fid);
info.Filename      = file;
info.Format        = line(3:5); % Must be VTK
info.Version       = line(end-2:end);
info.Header        = fgetl(fid);
info.DatasetFormat = lower(fgetl(fid));
line               = lower(fgetl(fid));
info.DatasetType   = line(9:end);
Line = {''};

while(true);
    if (strcmpi(Line{1},'points') || strcmpi(Line{1},'lines') || strcmpi(Line{1},'point_data') || strcmpi(Line{1},'cell_data'));
        
    else
        line = fgetl(fid);
        if (line==-1);
            break;
        end;
        Line = strsplit(line);
    end;

    
    switch(lower(Line{1}))
        case 'points'
            nPoints      = str2double(Line{2});
            info.NPoints = nPoints;
            Points       = nan(nPoints*3,1);
            j = 1;
            while(~strcmp(Line{1},'') && j<=nPoints*3);
                Line = strsplit(fgetl(fid));
                for i = 1 : numel(Line);
                    if (~strcmp(Line{i},''))
                        Points(j) = str2double(Line{i});
                        j = j +1;
                    end;
                end;
            end;
            Points = reshape(Points, [3,nPoints])';
		case 'lines'
            nCells  = str2double(Line{2});
            Cells   = cell(nCells,1);
            for i = 1 : nCells;
                Line = strsplit(fgetl(fid));
                Cell = nan(numel(Line)-2,1);
                for j = 2 : numel(Line)-1;
                    if (~strcmp(Line{j},''))
                        Cell(j-1) = str2double(Line{j});
                    end;
                end;
                Cells(i) = {Cell};
            end;
		case 'point_data'
            Line              = strsplit(fgetl(fid));
            nPointArrays      = str2double(Line{3});
            PointDataArrays   = cell(nPointArrays,1);
            for i = 1 : nPointArrays;
                Line               = strsplit(fgetl(fid));
                if (strcmp(Line{1},''));
                    Line             = strsplit(fgetl(fid));
                end;
                PArray.Name        = Line{1};
                PArray.Dimension   = str2double(Line{2});
                pointArray         = nan(nPoints * PArray.Dimension,1);
                j = 1;
                while(~strcmp(Line{1},'') && j <= nPoints* PArray.Dimension);
                    Line = strsplit(fgetl(fid));
                    for k = 1 : numel(Line);
                        if (~strcmp(Line{k},''))
                            pointArray(j) = str2double(Line{k});
                            j = j +1;
                        end;
                    end;
                end;
                PArray.Array       = reshape(pointArray, [PArray.Dimension,nPoints])';
                PointDataArrays(i) = { PArray };
            end;
        case 'cell_data'
            Line             = strsplit(fgetl(fid));            
            nCellArrays      = str2double(Line{3});
            CellDataArrays   = cell(nCellArrays,1);
            LineAux          = {''};
            for i = 1 : nCellArrays;
                if (strcmp(LineAux{1},''));
                    Line = strsplit(fgetl(fid));
                else
                    Line = LineAux;
                end;
                CArray.Name        = Line{1};
                CArray.Dimension   = str2double(Line{2});
                cellArray          = nan(nCells * CArray.Dimension,1);
                type               = Line{4}; 
                if (strcmp(type,'string'));
                    for k = 1 : nCells+1;
                        LineAux    = strsplit(fgetl(fid));
                    end;
                else
                    j = 1;
                    while(~strcmp(Line{1},'') && j<=nCells);
                        Line = strsplit(fgetl(fid));
                        for k = 1 : numel(Line);
                            if (~strcmp(Line{k},''));
                                cellArray(j) = str2double(Line{k});
                                j = j +1;
                            end;
                        end;
                    end;
                    LineAux = strsplit(fgetl(fid));
                    Line = LineAux;
                end;
                CArray.Array      = reshape(cellArray, [CArray.Dimension,nCells])';
                CellDataArrays(i) = { CArray };              
            end;
    end
end

polydata.Points          = Points;
polydata.Cells           = Cells;
polydata.Cells2          = {};
polydata.PointDataArrays = PointDataArrays;
polydata.CellDataArrays  = CellDataArrays;
fclose(fid);
end

