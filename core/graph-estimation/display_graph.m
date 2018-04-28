
function h = display_graph(G, I)

    % show the image, if given...
    if nargin<2
        h = figure('units','normalized','outerposition',[0 0 1 1]);
    else
        if (size(I,3)>1)
            h = figure('units','normalized','outerposition',[0 0 1 1]); imshow(I(:,:,2));
        else
            h = figure('units','normalized','outerposition',[0 0 1 1]); imshow(I);
        end
    end
    set(gca,'YDir','reverse');
    hold on;
    
    
    % array to indicate links already drawn
    drawnLinks = zeros(size(G.link));
    
    % for each node
    for i=1:length(G.node)
        
        % get the central point
        x1 = G.node(i).comx;
        y1 = G.node(i).comy;        
        
        % for each link of the given node
        for j=1:length(G.node(i).links)
            
            % if the link was not drawn yet...
            if (~drawnLinks(G.node(i).links(j)))
            
                % terminals are blue, links are red
                if(G.node(i).conn(j)<1)
                    col='r';
                else
                    col='r';
                end

                % draw edges as lines using pixel positions
                for k=1:length(G.link(G.node(i).links(j)).point)-1            
                    [x3,y3]=ind2sub([G.w,G.l],G.link(G.node(i).links(j)).point(k));
                    [x2,y2]=ind2sub([G.w,G.l],G.link(G.node(i).links(j)).point(k+1));
                    line([y3 y2],[x3 x2],'Color',col,'LineWidth',2);
                end;
                
                % mark the link as drawn
                drawnLinks(G.node(i).links(j)) = 1;
                
            end
            
        end;

        % flag to indicate that the node has to be draw as a yellow node
        draw_node = 1;

        % if there is a root node
        if (isfield(G,'roots'))
            if ismember(i,G.roots)
                % draw root node in green
                plot(y1,x1,'o','MarkerSize',8,...
                    'MarkerFaceColor','k',...
                    'Color','y');
                draw_node = 0;
            end
        end

        if (draw_node==1)
            if (isfield(G,'terminalNodes')) && (ismember(i, G.terminalNodes))
                plot(y1,x1,'o','MarkerSize',8,...
                'MarkerFaceColor','r',...
                'Color','k');
            else
                plot(y1,x1,'o','MarkerSize',8,...
                'MarkerFaceColor','r',...
                'Color','k');
            end
        end

    end;
    
    axis image;axis off;
    set(gcf,'Color','white');
    drawnow;

end