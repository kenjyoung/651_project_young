function [distTraveled, meanScrubbing, solved] = learningdaDRTAA(learner,i,map,goal,neighborhoodI,gCost,h,errorRate,cutOff,visualize)
    %% Returns the expected distance traveled to a goal state
    % Vadim Bulitko
    % February 25, 2016
    
%     if count(py.sys.path,'learner') == 0
%         insert(py.sys.path,int32(0),'learner');
%     end
% 
%     import py.learner.Learner;

    %% Preliminaries
    % Set initial parameters
    mapSize = size(map);
    iGoal = sub2ind(mapSize,goal.y,goal.x);
    da_max = 10;
    depth_max = 50;
    speed = 10; %distance units per second, balances suboptimality with GAT
    timeout = 1800; %don't allow one episode to last more than 30 min
    t_round = tic;
    distTraveled = 0;
    h0 = h;
    nVisits = zeros(mapSize);
    totalLearning = 0;

    [startx, starty] = ind2sub(mapSize, i);
    start = struct('x', startx, 'y', starty);
    new_state = build_state(map, start, goal, h, h0);
    % As long as we haven't reached the goal and haven't run out of quota
    while i ~= iGoal && distTraveled < cutOff && toc(t_round) < timeout
        t_step = tic;
        state = new_state;
        action = cell2mat(cell(select_action(learner, state)));
        
        da = action(1)*da_max;
        depth = ceil(action(2)*depth_max);
        if(da<=0)
           da=0; 
        end
        commit = ceil(action(3)*depth); %keep commit strictly less than depth
        
        
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
               value = g(s) + h(s) + da*delta;
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
        reward = -(toc(t_step)+g(i)/speed);
        if(i ~= iGoal)
            terminal = 0;
        else
            terminal = 1;
        end
        [startx, starty] = ind2sub(mapSize, i);
        start = struct('x', startx, 'y', starty);
        new_state = build_state(map, start, goal, h, h0);
        
        %update replay memory and preform a learning step
        update_memory(learner, state, action, reward, new_state, terminal);
        learn(learner, 16);
    end

    %% Compute scrubbing
    nVisitsNZ = nVisits(nVisits > 0);
    meanScrubbing = mean(nVisitsNZ);
    solved = distTraveled <= cutOff && toc(t_round) < timeout;

end

