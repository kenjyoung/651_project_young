function [ state ] = build_state( map, start, goal, h, h0)
mapSize = size(map);
map = map*255;
x_scale = 128/mapSize(1);
y_scale = 128/mapSize(2);
goal_plane = zeros(mapSize);
goal_plane(goal.y,goal.x) = 255;
start_plane = zeros(mapSize);
start_plane(start.y,start.x) = 255;
h(h==inf)=0;
h0(h0==inf)=0;
maxh = max(max(h));
delta = h - h0;
normalized_h = h/maxh*255;
normalized_delta = delta/maxh*255;


state(1,:,:) = imresize(map, [128,128]);
state(2,:,:) = imresize(goal_plane, [128,128]);
state(3,:,:) = imresize(start_plane, [128,128]);
state(4,:,:) = x_scale;
state(5,:,:) = y_scale;
state(6,:,:) = imresize(normalized_h, [128,128]);
state(7,:,:) = imresize(normalized_delta, [128,128]);
state = reshape(double(state)/255, 1, numel(state));
end

