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

% Include backtracking
%geneMin = [1, 1, 0, 0, 0, 1, 0, 0];
%geneMax = [10, 10, 1, 1, 1, 4, 1, 100000];

% Excludes backtracking
geneMin = [1, 1, 0, 0, 0, 1, 0, 0];
geneMax = [10, 10, 1, 1, 0, 4, 1, 0];

%w = gene(1);
%wc = gene(2);
%da = gene(3);
%markExpendable = gene(4);
%backtrack = gene(5);
%learningOperator = gene(6);
%beamWidth = gene(7);
%learningQuota = gene(8);

gene = [1 1 0 0 0 1 0 0];       % Korf's LRTA*

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
fprintf('\nRunning %s on problem %d\n',gene2str(gene),problemI);

%% Run the algorithm
tt = tic;

[subopt,~,solved] = geneEvalVis(gene,loadedScenario.problem,loadedScenario.maps,problemI,cutoff,errorRate);

fprintf('\tsubopt %0.1f | solved %d | %s\n',subopt,solved,sec2str(toc(tt)));

%% Wrap up
fprintf('\nTotal time %s\n',sec2str(toc(tttTotal)));
diary off

