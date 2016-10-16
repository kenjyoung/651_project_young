function [subopt, sc, solved] = daDRTAA_eval(problem,maps,nProblems,cutoff,errorRate,da,depth)
%% Evaluates a gene on nProblems
% Vadim Bulitko
% March 3, 2016

%% Data structures
subopt = NaN(1,nProblems);
sc = NaN(1,nProblems);
solved = false(1,nProblems);


%% Go through the problems
parfor n = 1:nProblems
    % Prepare the problem
    p = problem(n);
    map = maps{p.mapInd}; %#ok<PFBNS>
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
    
    % Run the algorithm
    [solution, sc(n), solved(n)] =  ...
        daDRTAA(iStart,map,goal,neighborhoodI,gCost,h,errorRate,maxTravel,da,depth,false);
    
    subopt(n) = solution / hs;
end

end
