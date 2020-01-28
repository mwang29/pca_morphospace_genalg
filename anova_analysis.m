ps = nan(2, config.numPCs);
tables = cell(config.numPCs, 1);
for c = 1:config.numPCs
    if mod(c, 100)==0
     fprintf('%d\n', c)
    end
    y = COEFFS(:,c);
    [ps(:,c), tables{c}] = anovan(y, {task', subject'}, 'display', 'off');
end

f_subj = nan(1, config.numPCs);
f_task = nan(1, config.numPCs);
for c = 1:config.numPCs
  f_task(c) = tables{c}{2,6};
  f_subj(c) = tables{c}{3,6};
end