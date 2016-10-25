function [distTraveled, meanScrubbing, solved] = daDRTAA(i,map,goal,neighborhoodI,gCost,h,errorRate,cutOff,da,depth,commit,visualize)
    %% Returns the expected distance traveled to a goal state
    %% Universal LRTA*, incorporates elements from wLRTA*, wbLRTA*, LRTA*-E, daLRTA* and SLA*T
    % Vadim Bulitko
    % February 25, 2016
    
    %%TODO: idea: commit to several steps at a time, maybe there isn't much
    %%point totally rerunning A* from scratch if we only take one step
    %%first

    %% Preliminaries
    % Set initial parameters
    mapSize = size(map);
    iGoal = sub2ind(mapSize,goal.y,goal.x);
    %iPrevious = ones(1,0); % = []
    %coder.varsize('iPrevious',[1, Inf], [0, 1]);
    %iPreviousCost = ones(1,0);   % = []                   
    %coder.varsize('iPreviousCost',[1, Inf], [0, 1]);
    distTraveled = 0;
    h0 = h;
    nVisits = zeros(mapSize);
    totalLearning = 0;

    % As long as we haven't reached the goal and haven't run out of quota
    while i ~= iGoal && distTraveled < cutOff
        % Visualize
        % Mark the visit
        nVisits(i) = nVisits(i) + 1;
        if(visualize)
            cla
            displayMap(map, h-h0, [0 0 1], false);
            [current.y, current.x] = ind2sub(mapSize, i);
            dispStartGoal(current, goal);
            drawnow
        end

        [best, closed, open, p, g, unreachable] = Astar(i, map, goal, neighborhoodI, gCost, errorRate, h, depth);

        if(unreachable)
            nVisitsNZ = nVisits(nVisits > 0);
            meanScrubbing = mean(nVisitsNZ);
            solved = false;
            distTraveled = cutOff + min(gCost);
            return
        end
        
        best_value = inf;
        best_state = 0;
        if(any(closed == iGoal))
           best_state = iGoal;
           best_value = 0;
        else
            for j=1:size(open,2)
               s = open(j);
               delta = h(s) - h0(s);
               value = g(s) + h(s); + da*delta;
               if value < best_value
                  best_value = value;
                  best_state = s;
               end
            end
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
        
        path_index = min(size(path,2), commit+1);
        i = path(path_index);
        distTraveled = distTraveled + g(i);
        for j=1:size(closed,2)
           s = closed(j);
           hnew = max(best-g(s), h(s));
           updateMagnitude = abs(h(s) - hnew);
           hUpdate = updateMagnitude > 0.0001;
           totalLearning = totalLearning + updateMagnitude;
           h = setH(s, hnew, h, errorRate);
        end
    end

    %% Compute scrubbing
    nVisitsNZ = nVisits(nVisits > 0);
    meanScrubbing = mean(nVisitsNZ);
    solved = distTraveled <= cutOff;

end

