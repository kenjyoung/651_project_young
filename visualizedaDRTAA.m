%% Visualize uLRTA* on problems
% Oct 14, 2016
% Vadim Bulitko

close all
clear
clc
diary off
format short g

%% Control parameters
errorRate = 0;
cutoff = 1000;

da = 10;
commit = 5;
depth = 20;

scenarioName = 'scenarios/yngvi_5.mat';

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

[subopt,~,solved] = daDRTAAEvalVis(loadedScenario.problem,loadedScenario.maps,problemI,cutoff,errorRate,da,depth,commit);

fprintf('\tsubopt %0.1f | solved %d | %s\n',subopt,solved,sec2str(toc(tt)));

%% Wrap up
fprintf('\nTotal time %s\n',sec2str(toc(tttTotal)));
diary off