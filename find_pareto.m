% Function to determine the indices of the pareto front 

function [pareto_front_membership]=find_pareto(subj_i_diff_vec, task_i_diff_vec, config) 

pareto_front_membership=false(1,config.pop_size);

for i=1:config.pop_size
    subj_i_diff = subj_i_diff_vec(i);
    task_i_diff = task_i_diff_vec(i);
    
    subj_front = subj_i_diff_vec>subj_i_diff;
    task_front = task_i_diff_vec>task_i_diff;
    total_fronts = subj_front+task_front;
    if nnz(total_fronts==2)==0
        %I am a pareto front member
        pareto_front_membership(i)=true;
    end
end



