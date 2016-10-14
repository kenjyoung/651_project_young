function [path, best] = BFS(i, map, neighborhoodI, gCost, h, k)
    %TODO: finish this maybe if needed
    mapSize = size(map);
    g = inf(mapsize);
    p = containers.Map; %parent
    d = containers.Map; %depth
    g(i) = 0;
    p(i) = i;
    d(i) = 0;
    
    open = [];
    open(end+1) = i;
    
    while open.size()~=0
        % Pop element from open
        i = open(end);
        open(end) = [];
        if d(i)>k
           continue 
        end
        
        % Generate the neighborhood
        iN = i + neighborhoodI;
        availableN = ~map(iN);
        iN = iN(availableN);
        gN = gCost(availableN);
        hN = getH(iN,h);
        fN = gN + hN;
        
        % Update neighbors and open list
        for j=1:size(iN)
            n = iN(j);
            if ~p.iskey(n) || g(i)+gN(j) < g(n)
               p(n) = i;
               d(n) = d(i) + 1;
               open{end+1} = n;
               g(n) = g(i) + gN(j);
            end
        end
    end
end