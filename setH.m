function h = setH(i,v,h,errorRate)
%% Faulty heuristic write
% Vadim Bulitko
% Feb 8, 2016

h(i) = v+randn*errorRate;

end
