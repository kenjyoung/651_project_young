function hp = dijkstraMEX(map, goal)
%% A wrapper for mexDijsktra

    hp = double(mexDijkstra( int32(map), goal.x, goal.y )) / 100000.0;
end

