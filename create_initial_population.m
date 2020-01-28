function [population] = create_initial_population(config)


%% R2 Initialization
if strcmp(config.policy, 'r2')
    population = repmat(config.r2,1,config.pop_size) > rand(config.numPCs,config.pop_size);
end


%% Random Initialization
if strcmp(config.policy, 'random')   
    population=rand(config.numPCs,config.pop_size);
    population=population < config.random_threshold;
end


