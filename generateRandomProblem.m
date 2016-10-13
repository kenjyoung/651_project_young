function [start,goal] = generateRandomProblem(map,minH,maxH,hcCheck,regionMap)
% generateRandomProblem
% generates a random problem (i.e., start.x, start.y, goal.x, goal.y)
% given a map. Both locations are guaranteed to be in the open and be distinct
% If hcCheck is true then it makes sure that the start and goal are not HC-reachable

%% Default arguments
if (nargin < 2)
    minH = 0;
end

if (nargin < 3)
    maxH = Inf;
end

if (nargin < 4)
    hcCheck = false;
end

if (nargin < 5)
    regionMap = [];
end

%% Preliminaries
[height, width] = size(map);
mapSize = [height width];
s2 = sqrt(2);
frontier = [-height-1 -1 height-1 height height+1 1 -height+1 -height];
g = [s2 1 s2 1 s2 1 s2 1];

numHCchecks = 0;
numHCrejects = 0;

%% Loop until we find a good problem
while (true)
    
    % Find the start not in a wall
    while (true)
        start.x = randi(width);
        start.y = randi(height);
        if (~map(start.y,start.x))
            break;
        end
    end
    
    % Find the goal not in a wall
    while (true)
        goal.x = randi(width);
        goal.y = randi(height);
        if (~map(goal.y,goal.x))
            break;
        end
    end

    % Check if they belong to the same connected component
    if (~isempty(regionMap) && (regionMap(start.x, start.y) ~= regionMap(goal.x, goal.y)))
        continue
    end
    
    % Check for heuristic distance
    dH = distance(start.x,start.y,goal.x,goal.y);
    if (dH < minH || dH > maxH)
        % Out of range, look for another problem
        continue;
    end
    
    % Check if there is HC-reachability
    if (hcCheck)
        startI = sub2ind(mapSize,start.y,start.x);
        goalI = sub2ind(mapSize,goal.y,goal.x);
        [hcReachable, ~, ~] = mexReachable(map,startI,goalI,int32(frontier),g,Inf,true);
        numHCchecks = numHCchecks + 1;
        if (hcReachable)
            % The goal is HC-reachable from the start, search for another problem
            numHCrejects = numHCrejects + 1;
            continue
        end
    end
    
    % All conditions have passed, we have a good problem, break the loop
    break
    
end

%fprintf('generateRandomProblem %d %d : %0.2f%%\n', numHCchecks, numHCrejects, 100*numHCrejects / numHCchecks);

end