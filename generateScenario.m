%% Generate N random problems per map, maps are taken from an existing scenario file
% Vadim Bulitko
% Aug 6, 2016

close all
clear
clc
diary off
format short g

%% Preliminaries & control parameters
numProblemsPerMap = 3;
maxMaps = 342;

minProblemCost = 1;
maxProblemCost = 9000;

scenarioName = 'scenarios/MovingAI_342_493298.mat';

fPos = [100 95 1280 720];
fig = figure('Position',fPos);

rng('shuffle');


%% Load scenario
load(scenarioName);

numProblems = length(problem);
numMaps = length(maps);

% Consider only up to maxMaps (randomly selected from all maps)
numMaps = min(numMaps,maxMaps);
%mapIndecies = randperm(length(maps));
%mapIndecies = mapIndecies(1:numMaps);
mapIndecies = 1:numMaps;

fprintf('Scenario %s\n\t%d problems | %d random maps selected\n\n',scenarioName,numProblems,numMaps);

problemOld = problem;
clear 'problem'

ttt = tic;

[~,~,~] = mkdir(sprintf('plots/%dproblemsPerMap',numProblemsPerMap));

%% Go through the maps and generate N problems for each
problemOffSet = 0;
for mi = 1:numMaps
    % Get the map data
    mapI = mapIndecies(mi);
    firstProblemI = find([problemOld.mapInd] == mapI,1,'first');
    map = maps{mapI};
    mapName = problemOld(firstProblemI).mapName;
    fprintf('Map %d | %s\n',mapI,mapName);
    
    startStates = zeros(size(map));
    goalStates = zeros(size(map));
    
    % Create the necessary number of problems per map
    for i = 1:numProblemsPerMap
        
        % Generate a (solvable) random problem
        foundAProblem = false;
        start = [];
        goal = [];
        optimalTravelCost = NaN;
        while (~foundAProblem)
            
            [start, goal] = generateRandomProblem(map,minProblemCost,maxProblemCost,false);
            
            % Our Dijkstra is faster than A* below :(
            hStarMEX = dijkstraMEX(map,goal);
            optimalTravelCost = hStarMEX(start.y,start.x);
            
            %[optimalTravelCost,asD,pathFound] = aStarDistance(map,start.x,start.y,goal);
            
            if (optimalTravelCost >= minProblemCost && optimalTravelCost <= maxProblemCost)
                foundAProblem = true;
            end
        end
        
        % Record
        problem(i+problemOffSet).mapInd = mi; %#ok<*SAGROW>
        problem(i+problemOffSet).mapName = mapName;
        problem(i+problemOffSet).start = start; 
        problem(i+problemOffSet).goal = goal;
        problem(i+problemOffSet).optimalTravelCost = optimalTravelCost;
        problem(i+problemOffSet).aStarDifficulty = NaN;
        
        startStates(start.y, start.x) = startStates(start.y, start.x) + 1;
        goalStates(goal.y, goal.x) = goalStates(goal.y, goal.x) + 1;
        
        fprintf('\t%d | (%d,%d) - (%d,%d) | h* %0.1f\n',i+problemOffSet,problem(i+problemOffSet).start.x,...
            problem(i+problemOffSet).start.y,...
            problem(i+problemOffSet).goal.x,problem(i+problemOffSet).goal.y,problem(i+problemOffSet).optimalTravelCost);
    end
    problemOffSet = length(problem);
    
    %% Plot start and goal states
    clf 
    
    subplot(1,2,1);
    displayMap(map,startStates,[0 1 0],false);
    title(sprintf('%d/%d | MovingAI index %d | %d problems',mi,numMaps,mapI,numProblemsPerMap));

    subplot(1,2,2);
    displayMap(map,goalStates,[1 0 0],false);
    title(sprintf('%s',removeUnderscore(mapName)));

    [~, mapNameTrimmed, ~] = fileparts(mapName);
    exportFigure(fig,sprintf('plots/%dproblemsPerMap/generateScenario2_%d_%s',numProblemsPerMap,mapI,mapNameTrimmed),'png');
end

%% Plot h* hist
clf
newSL = [problem.optimalTravelCost];
hist(newSL,100);
box on
grid on
xlabel('h*');
ylabel('Num problems');
title(sec2str(toc(ttt)));
exportFigure(fig,sprintf('plots/generateScenario2'),'pdf',[8 5]);


%% Save the scenario
maps = maps(mapIndecies);
save(sprintf('scenarios/uniMap_%d_%d.mat',numMaps,numProblemsPerMap*numMaps),'problem','maps');

fprintf('\nTotal time %s\n',sec2str(toc(ttt)));
