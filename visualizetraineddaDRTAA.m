%% Visualize uLRTA* on problems
% Oct 14, 2016
% Vadim Bulitko

if count(py.sys.path,'learner') == 0
     insert(py.sys.path,int32(0),'learner');
end

import py.learner.Learner;
learn = py.learner.Learner('learner.save');

%% Control parameters
errorRate = 0;
cutoff = 1000;

scenarioName = 'scenarios/8_80_test.mat';

fPos = [100 95 1280 720];
fig = figure('Position',fPos);

[~, sName, ~] = fileparts(scenarioName);

diaryFileName = sprintf('logs/visualizeULRTA_%s.txt',sName);
[~,~] = system(['rm ' diaryFileName]);
diary(diaryFileName);

fprintf('visualizeULRTA.m | ');
disp(datetime);

fprintf('Scenario %s\n',sName);
fprintf('error STD %0.1f\n',errorRate);
fprintf('cutoff %s\n\n',hrNumber(cutoff));

rng('shuffle');

tttTotal = tic;

diary off
diary on

%% Load the scenario
loadedScenario = load(scenarioName);
numMaps = length(loadedScenario.maps);
numProblems = length(loadedScenario.problem);
numProblemsPerMap = numProblems/numMaps;
problemI = randi(numProblems);
fprintf('Loaded %s\n\tmaps %d | problems %d, %0.1f per map\n',scenarioName,numMaps,numProblems,numProblemsPerMap);
fprintf('\nRunning problem %d\n',problemI);

%% Run the algorithm
tt = tic;

[subopt,~,solved] = traineddaDRTAAEvalVis(learn,loadedScenario.problem,loadedScenario.maps,problemI,cutoff,errorRate);

fprintf('\tsubopt %0.1f | solved %d | %s\n',subopt,solved,sec2str(toc(tt)));

%% Wrap up
fprintf('\nTotal time %s\n',sec2str(toc(tttTotal)));
diary off