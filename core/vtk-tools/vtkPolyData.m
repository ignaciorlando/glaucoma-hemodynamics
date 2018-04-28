function [ polydata, roots ] = vtkPolyData( R, G, spacing )
%VTKPOLYDATA Generates an structure that can be saved using vtkPolyDataWriter.
% The resulting polydata should only has bifurcating junctions, in the case
% that tri- or four- furcation are encounter, the algorithm will try to fix
% them.
% Also, no root could start at a  bifurcation point.
% R: The radius at each pixel of the skeleton.
% G: A graph representation of the skeletonization. Can be created
%    using the graph-estimation/initialize_graph_from_skeleton function.
% spacing: The pixel spacing (dx, dy).
% 


%% Generates the arterial segments from the graph ------------------------- 
% For each tree, starting from the root and performing a breath first
% traversal, construct the list of arterial segments and the list of 
% all the pixel ids.
vtkCells    = {};
allImageIds = [];
for iTree = 1 : length(G.roots);
    iRoot = G.roots(iTree);
    [vtkcells, allimageids] = breadth_first_traversal (G, iRoot);
    vtkCells    = {vtkCells{:}, vtkcells{:}};
    allImageIds = [allImageIds; allimageids];
    allImageIds = unique(allImageIds);
end

%% Generates the polydata -------------------------------------------------
[x, y] = ind2sub([G.w, G.l], allImageIds);
z      = zeros(size(x));
Points = [x * spacing(1), y * spacing(2), z];


R(R==0)               = 0.5;   % Ensures that no radius==0, the minimum arterial radius is half a pixel
RadiusArray.Name      = 'Radius';
RadiusArray.Dimension = 1;
RadiusArray.Array     = R(allImageIds) * ((spacing(1)+spacing(2))/2.);
PointDataArrays       = { RadiusArray };

% for each segment, a vtkCell will be constructed
Cells = cell(numel(vtkCells),1);
Cells2 = {};
for s = 1 : numel(vtkCells);
    segment = vtkCells{s};
    vtkCell = zeros(size(segment));
    for i = 1 : numel(segment);
        vtkCell(i) = find(allImageIds==segment(i));
    end
    Cells(s) = {vtkCell};
    
    for i = 1 : numel(segment)-1;
        cell2 = [ find(allImageIds==segment(i)), find(allImageIds==segment(i+1))];
        if (cell2(1) ~= cell2(2));
            Cells2(end+1) = { cell2 };
        end;
    end
end

% Check that all junction points are bifurcations, if a n- furcation is
% present, then fixit.
% Loop over all points, and check if there is more than three cells that
% share that point.
for p = 1 : size(Points,1);
    cellsStarting = [];
    cellsEnding   = [];
    for c = 1 : numel(Cells2);
        if (Cells2{c}(1) == p);
            cellsStarting(end+1) = c;
        elseif (Cells2{c}(2) == p);
            cellsEnding(end+1)   = c;
        end;
    end;
    if (numel(cellsEnding) > 1);
        fprintf('Error::vtkPolyData: There are junctions with more than 1 points ending on it!. Check image quality\n');
        return;    
    end;
    if (numel(cellsStarting) + numel(cellsEnding) == 4);
        % Modify the cell which second point is closest to the first point of the ending cell
        pointA = Points(Cells2{cellsEnding(1)}(1),:);
        pointB = Points(Cells2{cellsStarting(1)}(2),:);
        pointC = Points(Cells2{cellsStarting(2)}(2),:);
        pointD = Points(Cells2{cellsStarting(3)}(2),:);
        if (norm(pointA-pointB) <= norm(pointA-pointC) && norm(pointA-pointB) <= norm(pointA-pointD));
            Cells2(cellsStarting(1)) = {[Cells2{cellsEnding(1)}(1),Cells2{cellsStarting(1)}(2)]};
        elseif (norm(pointA-pointC) <= norm(pointA-pointB) && norm(pointA-pointC) <= norm(pointA-pointD));
            Cells2(cellsStarting(2)) = {[Cells2{cellsEnding(1)}(1),Cells2{cellsStarting(2)}(2)]};
        else
            Cells2(cellsStarting(3)) = {[Cells2{cellsEnding(1)}(1),Cells2{cellsStarting(3)}(2)]};
        end;
        fprintf('Error::vtkPolyData: Trifurcation detected. Fixed\n');
    elseif (numel(cellsStarting) + numel(cellsEnding) == 5);
        % Modify the cell which second point is closest to the first point of the ending cell
        pointA = Points(Cells2{cellsEnding(1)}(1),:);
        pointB = Points(Cells2{cellsStarting(1)}(2),:);
        pointC = Points(Cells2{cellsStarting(2)}(2),:);
        pointD = Points(Cells2{cellsStarting(3)}(2),:);
        pointE = Points(Cells2{cellsStarting(4)}(2),:);
        if (norm(pointA-pointB) <= norm(pointA-pointC) && norm(pointA-pointB) <= norm(pointA-pointD) && norm(pointA-pointB) <= norm(pointA-pointE));
            Cells2(cellsStarting(1)) = {[Cells2{cellsEnding(1)}(1),Cells2{cellsStarting(1)}(2)]};
        elseif (norm(pointA-pointC) <= norm(pointA-pointB) && norm(pointA-pointC) <= norm(pointA-pointD)&& norm(pointA-pointC) <= norm(pointA-pointE));
            Cells2(cellsStarting(2)) = {[Cells2{cellsEnding(1)}(1),Cells2{cellsStarting(2)}(2)]};
        elseif (norm(pointA-pointD) <= norm(pointA-pointB) && norm(pointA-pointD) <= norm(pointA-pointC)&& norm(pointA-pointD) <= norm(pointA-pointE));
            Cells2(cellsStarting(3)) = {[Cells2{cellsEnding(1)}(1),Cells2{cellsStarting(3)}(2)]};
        else
            Cells2(cellsStarting(4)) = {[Cells2{cellsEnding(1)}(1),Cells2{cellsStarting(4)}(2)]};
        end;
        % Modify the cell which second point is closes to the second point
        % of the otherstarting cells, and that was not modified in the
        % previous step.
        D = nan(4, 4);
        for i = 1 : 4;
            for j = i+1 : 4;
                pi = Points(Cells2{cellsStarting(i)}(2),:);
                pj = Points(Cells2{cellsStarting(j)}(2),:);
                D(i,j) = norm(pi-pj);
            end;
        end;
        [D,I] = min(D); % I contains the row for each column with minimum value.
        [~,j] = min(D); % I contains the row for each column with minimum value.
        i = I(j);
        if (Cells2{cellsStarting(i)}(1) ~= Cells2{cellsEnding(1)}(1));
            Cells2(cellsStarting(i)) = {[Cells2{cellsStarting(j)}(2),Cells2{cellsStarting(i)}(2)]};
        else
            Cells2(cellsStarting(j)) = {[Cells2{cellsStarting(i)}(2),Cells2{cellsStarting(j)}(2)]};
        end;
        fprintf('Error::vtkPolyData: Cuatrifurcation detected. Fixed\n');
    elseif (numel(cellsStarting) + numel(cellsEnding) > 5);
        fprintf('Error::vtkPolyData: There are junctions with more than 4 points in common!. Check image quality.\n');
        return;
    end;
end;

% Check that all bifurcation point are different from the roots, if a root
% point is found on a bifurcation, change one of the bifurcating cells to
% avoid such topology.
for r = 1 : numel(G.roots);
    p = find(allImageIds==G.node(G.roots(r)).idx(1));
    cellsStarting = [];
    for c = 1 : numel(Cells2);
        if (Cells2{c}(1) == p);
            cellsStarting(end+1) = c;
        end;
    end;
    if (numel(cellsStarting) == 2);
        % Modify the first cell by convention
        Cells2(cellsStarting(2)) = {[Cells2{cellsStarting(1)}(2),Cells2{cellsStarting(2)}(2)]};
        fprintf('Error::vtkPolyData: There are root points with more than 2 cells in common (%d, %d)!. Fixed\n',numel(Cells2),Cells2{cellsStarting(1)}(1));
    elseif (numel(cellsStarting) > 2);
        fprintf('Error::vtkPolyData: There are root points with more than 2 cells in common (%d, %d)!. Fix failed. Check image quality.\n',numel(Cells2),Cells2{cellsStarting(1)}(1));
        return;
    end;
end;



CellDataArrays = { };

polydata.Points          = Points;
%polydata.Cells           = Cells;
polydata.Cells2          = Cells2;
polydata.PointDataArrays = PointDataArrays;
polydata.CellDataArrays  = CellDataArrays;

%% Retrieve the index of the polydata points that are roots
roots = zeros(size(G.roots));
for i = 1 : numel(G.roots);
    roots(i) = find(allImageIds==G.node(G.roots(i)).idx(1));
end


end



function [vtkCells, allImageIds] = breadth_first_traversal (G, iRoot)
% BREADTH_FIRST_TRAVERSAL Implementation of the Breadth-first traversal algorithm
% over the Graph structure that generates a cell array representing the list
% of image indexes of the ordered pixels of each arterial segment 
% (graph link), which also contains the node pixel.
%
% G: The graph.
% iRoot: The id of the root node in the graph node list.
%
% returns: The list of arterial segments pixel ids and a list of all pixel
% ids in the returned segments that the not contains repetitions.
%

allImageIds = [];
vtkCells = {};
processedLinks = zeros(size(G.link));
processedNodes = zeros(size(G.node));

% The number of nodes in the graph
n   = numel(G.node); 
% search queue and search queue tail/head
sq  = zeros(1,n); 
sqt = 0; 
sqh = 0; 

% start bfs at root
sqt     = sqt + 1; % Advance 1 the tail pointer
sq(sqt) = iRoot;   % The index of the root node in the graph nodes list

% Loop until the search queue is empty
while sqt-sqh > 0;
    % Pop the first node off the head of the queue
    sqh   = sqh + 1;
    iNode = sq(sqh);
    % Loop over all the links of the array
    for l = 1 : numel(G.node(iNode).links)
        iLink = G.node(iNode).links(l);
        % if the link was not visited yet
        if (~processedLinks(iLink));
            linkPoints = G.link(iLink).point;
            % Generates the list of pixel indexes for the current arterial segment
            if (G.link(iLink).n2 > 0); % If the links is not a terminal segment
                % If the end-node was not processed yet, then added to the search queue list.
                if (G.link(iLink).n1 == iNode)
                    endNode = G.link(iLink).n2;
                else
                    endNode = G.link(iLink).n1;
                end
                if (~processedNodes(endNode));
                    sqt     = sqt + 1;
                    sq(sqt) = endNode;
                end
                segment      = zeros(numel(linkPoints)+2,1);
                segment(end) = G.node(endNode).idx(1);
            else
                segment = zeros(numel(linkPoints)+1,1);
            end;
            segment(1) = G.node(iNode).idx(1);
            % Checks the order of the linkPonits and fill the segment
            % accordingly
            [x,y]     = ind2sub([G.w, G.l], G.node(iNode).idx(1));
            possNode  = [x,y,0];
            [x,y]     = ind2sub([G.w, G.l], linkPoints(1));
            possFirst = [x,y,0];
            [x,y]     = ind2sub([G.w, G.l], linkPoints(end));
            possLast  = [x,y,0];
            
            if (norm(possNode-possFirst) < norm(possNode-possLast));
                for k = 1 : numel(linkPoints);
                    segment(k+1) = linkPoints(k);                
                end
            else
                for k = numel(linkPoints) : -1 : 1;
                    segment(numel(linkPoints)-k+1+1) = linkPoints(k);                
                end
            end
            vtkCells(end+1) = {segment};
            allImageIds = [allImageIds; segment];
            allImageIds = unique(allImageIds);
            % mark the current link as visited
            processedLinks(iLink) = 1;
        end
    end
    % mark the current node as visited
    processedNodes(iNode) = 1;
end

end
