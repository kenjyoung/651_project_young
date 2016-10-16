function [closed, g, best] = Astar(i,map,goal,neighborhoodI,gCost,h, k)
    %TODO: finish this maybe if needed
    mapSize = size(map);
    g = containers.Map('KeyType', 'uint32', 'ValueType', 'uint32');
    p = containers.Map('KeyType', 'uint32', 'ValueType', 'uint32'); %parent
    d = containers.Map('KeyType', 'uint32', 'ValueType', 'uint32'); %depth
    g(i) = 0;
    p(i) = i;
    d(i) = 0;
    
    closed = [];
    
    open = [];
    open_value = [];
    
    open(end+1) = i;
    open_value(end+1) = h(i);
    
    expansions = 0;
    size(open)
    while expansions < k && size(open,1)~=0 && i ~= goal
        % Remove min f value from open list
        [~, open_index] = min(open_value);
        open_value(open_index) = [];
        i = open(open_index);
        
        open(open_index) = [];
        
        closed(end+1) = i;
        
        
        expansions = expansions + 1;
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
           if ~g.iskey(n) || g(n) > g(i) + gN(j)
              g(n) = g(i)+gN(j);
              p(n) = i;
              d(n) = d(i)+1;
              
              if(d(j)<k)
                  %Remove any existing copies of n from open list
                  existing = open==n;
                  open(existing) = [];
                  open_value(existing) = [];
                  
                  %Add n to open list with new f value
                  open(end+1) = n;
                  open_value(end+1) = g(n)+h(n);
              end
           end
        end
    end
    
    if(open.size()~=0)
        [best, best_index] = min(open_value);
        best_state = open(best_index);
    end
    path = [best_state];
    curr = best_state;
    prev = p(curr);
    while prev ~=curr
        path(end+1) = prev;
        curr = prev;
        prev = p(curr);
    end 
    path = fliplr(path);
end