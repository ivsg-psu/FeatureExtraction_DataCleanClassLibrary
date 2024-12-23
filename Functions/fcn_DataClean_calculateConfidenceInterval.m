function CI_Range = fcn_DataClean_calculateConfidenceInterval(x,C)

Npoints = size(x,1);

upper_bond = mean(x) + C*std(x)/sqrt(Npoints);

lower_bond = mean(x) - C*std(x)/sqrt(Npoints);


CI_Range = [upper_bond, lower_bond];