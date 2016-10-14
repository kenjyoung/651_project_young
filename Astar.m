function [] = Astar(i,map,goal,neighborhoodI,gCost,h, k)
    mapSize = size(map);
    g = Inf(mapSize);
    open = java.util.PriorityQueue;
    open.add({i,h(i)})
    expansions = 0;
    while expansions < k && ~(open.size()==0)
    end
end