%% Generate suboptimality databases
% Aug 6, 2016
% Vadim Bulitko

close all
clear
clc
diary off
format short g

%% Control parameters
errorRate = 0;
cutoff = 1000;

numAlgorithms = 10;

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

%scenarioName = 'scenarios/uniMap_342_1710.mat';
%scenarioName = 'scenarios/uniMap_8_16.mat';
%scenarioName = 'scenarios/uniMap_50_500.mat';
scenarioName = 'scenarios/uniMap_8_80.mat';
%scenarioName = 'scenarios/uniMap_200_10000.mat';
%scenarioName = 'scenarios/uniMap_100_5000.mat';
%scenarioName = 'scenarios/uniMap_100_20000.mat';
%scenarioName = 'scenarios/uniMap_342_34200.mat';
%scenarioName = 'scenarios/uniMap_342_17100.mat';

fPos = [100 95 1280 720];
fig = figure('Position',fPos);

[~, sName, ~] = fileparts(scenarioName);

diaryFileName = sprintf('logs/generateSuboptDBperMap_%s.txt',sName);
[~,~] = system(['rm ' diaryFileName]);
diary(diaryFileName);

fprintf('generateSuboptDBperMap.m | ');
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
problemI = 1:numProblems;
fprintf('Loaded %s\n\tmaps %d | problems %d, %0.1f per map\n',scenarioName,numMaps,numProblems,numProblemsPerMap);

fprintf('\nRunning %s random algorithms on the %s problems, %s maps\n',...
    hrNumber(numAlgorithms),hrNumber(numProblems),hrNumber(numMaps));

subopt = NaN(numAlgorithms,numProblems);
gene = NaN(numAlgorithms,length(geneMax));

%% Generate and evaluate random individuals
for aI = 1:numAlgorithms
    % Generate the algorithm
    for j = 1:length(geneMax)
        gene(aI,j) = randr([geneMin(j),geneMax(j)]);
    end
    fprintf('%d | %s | ',aI,gene2str(gene(aI,:)));
    
    % Evaluate
    tt = tic;
    [subopt(aI,:),~,solved] = geneEval(gene(aI,:),loadedScenario.problem,loadedScenario.maps,numProblems,cutoff,errorRate);
    
    fprintf('subopt %0.1f | solved %0.1f%% | %s\n',...
        mean(subopt(aI,:)),100*nnz(solved)/numProblems,sec2str(toc(tt)));
end

%% Save the results (problem-level)
perfDataFile = sprintf('dbs/suboptProblem_%d_%s_%d_%d.mat',cutoff,sName,numAlgorithms,numProblems);
save(perfDataFile,'gene','subopt','scenarioName','problemI','cutoff','errorRate');

%% Average over maps
suboptMap = NaN(numAlgorithms,numMaps);
for mapI = 1:numMaps
    problemIrange = (mapI-1)*numProblemsPerMap+1:mapI*numProblemsPerMap;
    suboptMap(:,mapI) = mean(subopt(:,problemIrange),2);
end

%% Save the results (map-level)
perfDataFile = sprintf('dbs/suboptMap_%d_%s_%d_%d.mat',cutoff,sName,numAlgorithms,numMaps);
save(perfDataFile,'gene','suboptMap','scenarioName','cutoff','errorRate');

%% Plot
subplot(1,2,1);
pcolor2([],[],subopt,0);
xlabel('Problems');
ylabel('Algorithms');
title('Suboptimality per problem');

subplot(1,2,2);
pcolor2([],[],suboptMap,0);
xlabel('Maps');
ylabel('Algorithms');
title('Suboptimality per map');

exportFigure(fig,sprintf('plots/generateSuboptDBperMap_%s',sName),'png');

%% Wrap up
fprintf('\nTotal time %s\n',sec2str(toc(tttTotal)));
diary off

