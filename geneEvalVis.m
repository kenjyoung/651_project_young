function [subopt, sc, solved] = geneEvalVis(gene,problem,maps,n,cutoff,errorRate)
%% Evaluates a gene on a given problem and displays it
% Vadim Bulitko
% Oct 14, 2016

%% Prepare the problem
p = problem(n);
map = maps{p.mapInd};
goal = p.goal;
mapHeight = size(map,1);
s2 = sqrt(2);
neighborhoodI = [-mapHeight-1 -1 mapHeight-1 mapHeight mapHeight+1 1 -mapHeight+1 -mapHeight];
gCost = [s2 1 s2 1 s2 1 s2 1];
hs = p.optimalTravelCost;
maxTravel = hs*cutoff;
if (~isfield(p,'h0'))
    h = computeH0_mex(map,goal);
else
    h = p.h0;
end
iStart = sub2ind(size(map),p.start.y,p.start.x);

%% Run the algorithm
[solution, sc, solved] =  uLRTAvis(iStart,map,goal,neighborhoodI,gCost,h,errorRate,maxTravel,gene);

subopt = solution / hs;

end
