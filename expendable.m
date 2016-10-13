function e = expendable(availableN)
%% Checks if a state is expendable
% We do so by going through the available neighborhood and checking if they are contigious

e = contigious(find(availableN)) || contigious(find(~availableN));

end

function c = contigious(i)
%% Checks if a set of integers are contigious (i.e., the differences between the neighbors are exactly one)
% Assumes that the numbers in i are non-decreasing

for j = 1:length(i)-1
    if (i(j+1)-i(j) > 1)
        c = false;
        return
    end
end

c = true;

end
