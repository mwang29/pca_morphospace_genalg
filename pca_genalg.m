clearvars
flag.processPCA = false; %flag to run pca over dataset. if false, load vars from .mat file

%% CONFIGS (INIT)
config.numTasks = 8; % number of tasks available in the data (including rest)
config.ChosenTasks = [1 2 5 6 8]; % 1: Rest, 5: Motor, 6: Relational, 8: WM
config.numChosenTasks = length(config.ChosenTasks); 
config.numSubjs = 50; % number of subjects to subset (max of 409 subjects)
config.numPCs = config.numChosenTasks * config.numSubjs * 2; %number of principal components

%% Task ordering of identifiability matrix 
config.Tasks.order = [];
for task = config.ChosenTasks
    temp_vec = [task:config.numChosenTasks:config.numPCs/2];
    config.Tasks.order = [config.Tasks.order, temp_vec];
end

%% PCA Processing for SCORES and COEFFS
if flag.processPCA
    load('FC_all_sw_vectorized_S1200.mat')
    midpoint=size(FC_all_sw_vec,2)/2;
    new_indices = config.ChosenTasks;
    % Select chosen tasks from FC vector
    fc_indices = [];
    for subj = 1:config.numSubjs
        fc_indices = [fc_indices new_indices];
        new_indices = new_indices + 8;
    end
    FC_data_test = FC_all_sw_vec(:,fc_indices);
    FC_data_retest = FC_all_sw_vec(:,midpoint+1+fc_indices);
    clear FC_all_sw_vec fc_indices new_indices;
    FC_data = [FC_data_test FC_data_retest];
    clear FC_data_test FC_data_retest;
    config.FCmeans = mean(FC_data);
    [COEFFS, SCORES, latent] = pca(FC_data);
    clear FC_data;
    config.r2 = latent/sum(latent);
    config.task_labels = repmat(repmat(config.ChosenTasks, [1, config.numSubjs]), [1, 2]);
    config.subject_labels = repmat(repelem(1:config.numSubjs, config.numChosenTasks), [1, 2]);
    save(sprintf('pca_data_N%dT%d.mat', config.numSubjs, config.numChosenTasks), 'COEFFS', 'SCORES', 'config');
else % simply load variables and data from .mat file
    load(sprintf('pca_data_N%dT%d.mat', config.numSubjs, config.numChosenTasks));
end

%% CONFIGS (CONTINUATION)
config.policy = 'r2'; %{random,r2}
config.random_threshold = 0.9; %only for 'random' policy
config.pop_size = 100; %number of solutions in the morphospace
config.numGen = 20; %number of generations of the genetic algorithm
config.optimizer = 'pareto';
config.crossover_prob = 0.7;
config.mutation_prob = 0.7;
config.k = 3; % number of individuals in tournament selection
flag.plotting = true; % optional plotting
fig = figure;
%% Genetic Algorithm
population = create_initial_population(config); % create initial population
best_value = 0; % best fitness value variable
pareto_history = nan(config.numGen, 1);
pareto_values = [];
pareto_population = [];
for generation = 1:config.numGen
    fprintf('Generation %d\n', generation);
    % fitness evaluation
    
    [new_values, indv, pop_value] = evaluate_fitness(SCORES, COEFFS, population, config);
    all_values = [pareto_values; new_values]; % first column is subj_i_diff, second is task_i_diff
    population = [pareto_population, population];
    num_components = sum(population); % number of components per individual
    % Keep best individual throughout run, only plot if best individual
    if pop_value > best_value
        best_value = pop_value;
        best_indv = indv;
    end

 
    % evolve population for next generation
    
    [population, new_pareto_membership] = evolve(population, all_values(:,1), all_values(:,2), config);
    pareto_size = nnz(new_pareto_membership);
    pareto_population = population(:, 1:pareto_size);
    population = population(:, pareto_size+1:end);
    pareto_values = all_values(new_pareto_membership, :);
    non_pareto_values = all_values(~new_pareto_membership, :);
    pareto_components = num_components(new_pareto_membership);
    non_pareto_components = num_components(~new_pareto_membership);
    pareto_history(generation) = pareto_size/config.pop_size;
    
    if flag.plotting
        if generation == 1
            %% Initialize video
            myVideo = VideoWriter('Images/pop100_gen20'); %open video file
            myVideo.FrameRate = 4;  %can adjust this, 5 - 10 works well for me
            open(myVideo)
            axis([-0.1 0.5 -0.1 0.5])
            title(sprintf('Subject Idiff vs. TaskIdiff: %s iteration: %d', config.policy, generation))
            xlabel('Subject Idiff'), ylabel('Task Idiff');
            grid on
        else %make past generation transparent
            s1.MarkerFaceAlpha = 0.1;
            s1.MarkerEdgeColor = 'None';
            s1.MarkerFaceColor = 'k';
            s2.MarkerFaceAlpha = 0.1;
            s2.MarkerEdgeColor = 'None';
            s2.MarkerFaceColor = 'r';
        end
        hold on
        s1 = scatter(non_pareto_values(:,1), non_pareto_values(:, 2), 10*non_pareto_components + 10,'MarkerFaceColor','k','MarkerEdgeColor','k');
        s1.MarkerFaceAlpha = 0.5;
        s2 = scatter(pareto_values(:, 1), pareto_values(:, 2), 10*pareto_components + 10, 'MarkerFaceColor','r','MarkerEdgeColor','k');
        title(sprintf('Subject Idiff vs. TaskIdiff: %s iteration: %d', config.policy, generation))
        drawnow;
        pause(0.01);
        frame = getframe(gcf); %get frame
        writeVideo(myVideo, frame);
    end  
end
