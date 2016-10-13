function d = distance(x1,y1,x2,y2)
% distance 
% computes obstalce-free distance between two points

dx = abs(x1-x2);
dy = abs(y1-y2);

% Manhattan distance
%d = dx + dy;

% Octile distance
dc = sqrt(2);
d = dc*min(dx,dy) + max(dx,dy) - min(dx,dy);

end