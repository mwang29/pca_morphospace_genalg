function [new_population, pareto_membership] = evolve(population, subj_i_diff, task_i_diff, config)
    %new_population = false(config.numPCs, config.pop_size);
    
    %% Pareto Front 
    pareto_membership = find_pareto(subj_i_diff, task_i_diff, config);
    new_population = false(config.numPCs,config.pop_size);
    unique_pareto_individuals = unique(population(:, pareto_membership).', 'rows').';
    pareto_size = size(unique_pareto_individuals, 2);
    new_population(:,1:pareto_size) = unique_pareto_individuals;


    
    %% Genetic Algorithm
    for i = pareto_size+1:2:config.pop_size
        % Selection
        if strcmp(config.optimizer, 'subject')
            p1 = population(:,tournament_selection(subj_i_diff, config));
            p2 = population(:,tournament_selection(subj_i_diff, config));
            p1 = population(:,tournament_selection(subj_i_diff, config));
            p2 = population(:,tournament_selection(subj_i_diff, config));
        elseif strcmp(config.optimizer, 'task')
            p1 = population(:,tournament_selection(task_i_diff, config));
            p2 = population(:,tournament_selection(task_i_diff, config));
        elseif strcmp(config.optimizer, 'pareto')
            lottery1 = ceil(rand*pareto_size);
            lottery2 = ceil(rand*pareto_size);
            temp1 = find(pareto_membership, lottery1);
            temp2 = find(pareto_membership, lottery2);
            p1 = population(:,temp1(end));
            p2 = population(:,temp2(end));
        end    
        
        c1 = p1;
        c2 = p2;
        % Crossover
        crossover_rand = rand;
        if crossover_rand < config.crossover_prob   
            c_idx = randi(config.numPCs-1, 1);
            c1 = [p1(1:c_idx); p2(c_idx+1:end)];
            c2 = [p2(1:c_idx); p1(c_idx+1:end)];
        end
        
        % Mutation
        if (rand < config.mutation_prob) | (crossover_rand >= config.crossover_prob)
            m_idx = randi(config.numPCs,[1,2]);
            c1(m_idx(1)) = ~c1(m_idx(1));
            c2(m_idx(2)) = ~c2(m_idx(2));
        end
        if i<=config.pop_size-1
            new_population(:,i) = c1; 
            new_population(:,i+1) = c2;
        else %config.pop_size
            if rand>0.5
                new_population(:,i) = c1;
            else
                new_population(:,i) = c2;
            end             
        end
    end        
end