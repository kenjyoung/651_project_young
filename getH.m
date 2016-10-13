function hOut = getH(i,h,errorRate)
%% Faulty heuristic read
% Vadim Bulitko
% Feb 8, 2016

hOut = i;
for j = 1:length(i)
         hOut(j) = h(i(j))+randn*errorRate;
end

%hOut = h(i) + errorRate*randn(1,length(i));

end
