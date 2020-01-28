function [new_values, best_indv, value] = evaluate_fitness(SCORES, COEFFS, population, config)

%% Initialization of fitness vectors
subj_i_diff = nan(size(population,2),1);
task_i_diff = nan(size(population,2),1);

for i = 1:size(population,2) %for each solution
    %% PCA reconstruct with each solution and compute ident mat
    recon_matrix = SCORES(:,population(:,i))*COEFFS(:,population(:,i))';
    recon_matrix = bsxfun(@plus,recon_matrix,config.FCmeans); 
    test = recon_matrix(:, 1:(config.numPCs/2));
    retest = recon_matrix(:, (config.numPCs/2)+1:end);
    clear recon_matrix;
    ident_mat = corr(test,retest);
    clear test retest;

    %% Subject identifiability

    fun = @(block_struct) mean(block_struct.data(:)); % block operator function
    subject_means = blockproc(ident_mat, [config.numChosenTasks, config.numChosenTasks], fun);
    if (size(subject_means,1)~=config.numSubjs) | (size(subject_means,2)~=config.numSubjs)
        error('missmatch between config.numSubjs and size of the blockprocessed subject_means')
    end
    
    %calculation of idiff
    subj_i_self = mean(diag(subject_means));
    subj_i_others = mean(subject_means(~eye(config.numSubjs, config.numSubjs)));
    subj_i_diff(i) = subj_i_self - subj_i_others;


    %% Task identifiability
    task_mat = ident_mat(config.Tasks.order, config.Tasks.order);
    task_means = blockproc(task_mat, [config.numSubjs, config.numSubjs], fun);
    if (size(task_means,1)~=config.numChosenTasks) | (size(task_means,2)~=config.numChosenTasks)
        error('missmatch between config.numChosenTasks and size of the blockprocessed task_means')
    end
    %calculation of idiff
    task_i_self = mean(diag(task_means));
    task_i_others = mean(task_means(~eye(config.numChosenTasks,config.numChosenTasks)));
    task_i_diff(i) = task_i_self - task_i_others;
end

%%  Find best fitness value
if strcmp(config.optimizer, 'subject')   
    [value, idx] = max(subj_i_diff);
elseif strcmp(config.optimizer, 'task')   
    [value, idx] = max(task_i_diff);
elseif strcmp(config.optimizer, 'pareto')
    [value, idx] = max(subj_i_diff);   
end

new_values = [subj_i_diff, task_i_diff];
%% Find best individual
best_indv = population(:,idx);
