function [closed, open, p, g, unreachable] = Astar(i, map, goal, neighborhoodI, gCost, errorRate, h, k)
    

    unreachable = false;
    mapSize = size(map);
    iGoal = sub2ind(mapSize,goal.y,goal.x);
    g = containers.Map('KeyType', 'uint32', 'ValueType', 'double');
    p = containers.Map('KeyType', 'uint32', 'ValueType', 'double'); %parent
    d = containers.Map('KeyType', 'uint32', 'ValueType', 'double'); %depth
    g(i) = 0;
    p(i) = i;
    %d(i) = 0;
    
    closed = [];
    
    open = [];
    open_value = [];
    
    open(end+1) = i;
    open_value(end+1) = getH(i,h,errorRate);
    
    expansions = 0;
    while ((expansions < k) && ~isequal(size(open,2),0) && i ~= iGoal)
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
        hN = getH(iN,h,errorRate);
        
        % Update neighbors and open list
        for j=1:size(iN,2)
           n = iN(j);
           if ~any(n == closed) && (~isKey(g,n) || g(n) > g(i) + gN(j))
              g(n) = g(i)+gN(j);
              p(n) = i;
              %d(n) = d(i)+1;
              
              %Remove any existing copies of n from open list
              existing = open==n;
              open(existing) = [];
              open_value(existing) = [];

              %Add n to open list with new f value
              open(end+1) = n;
              open_value(end+1) = g(n)+hN(j);
           end
        end
    end
    
    if(isequal(size(open,2),0) && i ~= iGoal)
        unreachable = true;
        return
    end
    
%      path = [best_state];
%      curr = best_state;
%      prev = p(curr);
%      while prev ~=curr
%          path(end+1) = prev;
%          curr = prev;
%          prev = p(curr);
%      end 
%      path = fliplr(path);
end