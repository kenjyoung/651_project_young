function h = computeH0(map,goal)
%% Computes the initial h
% Vadim Bulitko
% Feb 21, 2016

updateIndex = find(~map)';
numCells = length(updateIndex);

hAux = NaN(1,numCells);
for j = 1:numCells
    i = updateIndex(j);
    [yi, xi] = ind2sub(size(map),i);
    hAux(j) = distance(xi,yi,goal.x,goal.y);
end

h = Inf(size(map));
h(updateIndex) = hAux;

end
