function [index] =  roulette_selection(fitness_array)
len = length(fitness_array);

if (~isempty(find(fitness_array<1, 1)))
    if (min(fitness_array) ~=0)
    fitness_array = 1/min(fitness_array)*fitness_array;
    else
    temp= fitness_array;
    temp(fitness_array==0) = inf;
    fitness_array = 1/min(temp)*fitness_array;
    end
end
temp = 0;
tempProb = zeros(1,len);
for i= 1:len
    tempProb(i) = temp + fitness_array(i);
    temp = tempProb(i);
end
i = fix(rand*floor(tempProb(end)))+1;
index = find(tempProb >= i, 1 );