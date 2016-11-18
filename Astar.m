function [best, closed, open_list, p, g, unreachable] = Astar(i, map, goal, neighborhoodI, gCost, errorRate, h, k)
    addpath('priority_queue')

    unreachable = false;
    mapSize = size(map);
    max_index = mapSize(1)*mapSize(2);
    iGoal = sub2ind(mapSize,goal.y,goal.x);
    g = containers.Map('KeyType', 'uint32', 'ValueType', 'double');
    p = containers.Map('KeyType', 'uint32', 'ValueType', 'double'); %parent
    d = containers.Map('KeyType', 'uint32', 'ValueType', 'double'); %depth
    g(i) = 0;
    p(i) = i;
    %d(i) = 0;
    
    closed = [];
    
    open = pq_create(max_index);
    
    pq_push(open,i,getH(i,h,errorRate));
    
    expansions = 0;
    while ((expansions < k) && ~isequal(size(open,2),0) && i ~= iGoal)
        % Remove min f value from open list
        i = pq_pop(open);
        if any(i == closed)
           continue 
        end
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

              %Add n to open list with new f value
              pq_push(open,n,g(n)+hN(j));
           end
        end
    end

    if(isequal(size(open,2),0) && i ~= iGoal)
        unreachable = true;
        return
    end

    [i, best] = pq_pop(open);
    num_elements = pq_size(open);
    open_list = [i];
    for j=1:num_elements
        open_list(end+1) = pq_pop(open);
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