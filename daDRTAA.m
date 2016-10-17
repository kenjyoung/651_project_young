function [distTraveled, meanScrubbing, solved] = daDRTAA(i,map,goal,neighborhoodI,gCost,h,errorRate,cutOff,da,depth,visualize)
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
            displayMap(map,h-h0,[0 0 1],false);
            [current.y, current.x] = ind2sub(mapSize,i);
            dispStartGoal(current,goal);
            drawnow
        end
        % Generate the neighborhood
        iN = i + neighborhoodI;
        availableN = ~map(iN);
        iN = iN(availableN);
        gN = gCost(availableN);
        hN = getH(iN,h,errorRate);
        hI = getH(i,h,errorRate);
        hN0 = getH(iN,h0,errorRate);
        fN = gN + hN;

        % Check if we actually have any moves
        if (isempty(fN))
            nVisitsNZ = nVisits(nVisits > 0);
            meanScrubbing = mean(nVisitsNZ);
            solved = false;
            distTraveled = cutOff + min(gCost);
            return
        end

        if (da)
            % add exploration term to f
            deltaN = abs(hN - hN0);
            fNMove = fN + da*deltaN;
        else
            fNMove = fN;
        end

        % Select the move as arg min f
        [~,minIndex] = min(fNMove);
        iNext = iN(minIndex);
        iNextDist = gN(minIndex);
        getH(i,h,errorRate);

        i = iNext;

        distTraveled = distTraveled + iNextDist;

        [closed, g, best, unreachable] = Astar(i, map, goal, neighborhoodI, gCost, errorRate, h, depth);

        if(unreachable)
            nVisitsNZ = nVisits(nVisits > 0);
            meanScrubbing = mean(nVisitsNZ);
            solved = false;
            distTraveled = cutOff + min(gCost);
            return
        end

        for j=1:size(closed)
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

