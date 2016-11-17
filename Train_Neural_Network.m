function [] = Train_Neural_Network(load_existing, name, cont)
    %% Trained learner
    if count(py.sys.path,'learner') == 0
         insert(py.sys.path,int32(0),'learner');
    end

    import py.learner.Learner;
    if(load_existing)
       learn = py.learner.Learner(name);
    else
       learn = py.learner.Learner(); 
    end
    ma
    if(cont)
       load('problem_number.save', problem_number);
    else
       problem_number = 1;
    end

    %% Control parameters
    errorRate = 0;
    cutoff = 1000;

    % Include backtracking
    %geneMin = [1, 1, 0, 0, 0, 1, 0, 0];
    %geneMax = [10, 10, 1, 1, 1, 4, 1, 100000];

    %w = gene(1);
    %wc = gene(2);
    %da = gene(3);
    %markExpendable = gene(4);
    %backtrack = gene(5);
    %learningOperator = gene(6);
    %beamWidth = gene(7);
    %learningQuota = gene(8);

    %scenarioName = 'scenarios/uniMap_3_9.mat';
    %scenarioName = 'scenarios/uniMap_342_1710.mat';
    %scenarioName = 'scenarios/uniMap_8_16.mat';
    scenarioName = 'scenarios/uniMap_50_500.mat';
    %scenarioName = 'scenarios/uniMap_8_80.mat';
    %scenarioName = 'scenarios/uniMap_200_10000.mat';
    %scenarioName = 'scenarios/uniMap_100_5000.mat';
    %scenarioName = 'scenarios/uniMap_100_20000.mat';
    %scenarioName = 'scenarios/uniMap_342_34200.mat';
    %scenarioName = 'scenarios/uniMap_342_17100.mat';

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

    tt = tic;
    [subopt, ~, solved] = learningdaDRTAA_train(learn,loadedScenario.problem,loadedScenario.maps,numProblems,cutoff,errorRate,problem_number);
    fprintf('subopt %0.1f | solved %0.1f%% | %s\n',...
            mean(subopt),100*nnz(solved)/numProblems,sec2str(toc(tt)));

    fprintf('')
end


