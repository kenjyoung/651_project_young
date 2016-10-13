function newStr = removeUnderscore(str)
% removeUnderscore
% replaces all underscores with '\_'

if (isempty(str))
    newStr = '';
    return
end

up = strfind(str,'_');
if (isempty(up))
    newStr = str;
else
    newStr = [str(1:up-1) '\_' removeUnderscore(str(up+1:end))];
end

end
