function [subopt, sc, solved] = learningdaDRTAA_train(learner, problem,maps,nProblems,cutoff,errorRate, problem_number)
%% Evaluates a gene on nProblems
% Vadim Bulitko
% March 3, 2016

%% Data structures
subopt = NaN(1,nProblems);
sc = NaN(1,nProblems);
solved = false(1,nProblems);


%% Go through the problems
for n = problem_number:nProblems
    % Prepare the problem
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
    
    % Run the algorithm
    tt = tic();
    [solution, sc(n), solved(n)] =  ...
        learningdaDRTAA(learner,iStart,map,goal,neighborhoodI,gCost,h,errorRate,maxTravel,true);
    %save the trained network after each episode
    save(learner);
    problem_number = n;
    save('problem_number.save', problem_number)
    subopt(n) = solution / hs;
    fprintf('subopt %0.1f | solved %d | %s\n',...
        subopt(n),solved(n),sec2str(toc(tt)));
end

end
