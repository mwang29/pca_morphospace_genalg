% selects subset of k solutions from population and returns solution with
% highest fitness
function [index] =  tournament_selection(fitness_array, config)
    best_fitness = -999; %initialize to very small fitness value 
    for i = 1:config.k
        random_index = randi(1:2);
        temp_fitness = fitness_array(random_index);
        if temp_fitness > best_fitness % within k random selections, find the best 
            best_fitness = temp_fitness;
            index = random_index;
        end
    end
end