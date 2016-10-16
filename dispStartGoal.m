function dispStartGoal(start,goal)
%% Displays start and goal

if (~isempty(start))
    rectangle('Position',[start.x+0.3,start.y+0.3,0.4,0.4],'Curvature',[1 1],'FaceColor','w','EdgeColor','r');
end

if (~isempty(goal))
    rectangle('Position',[goal.x+0.3,goal.y+0.3,0.4,0.4],'Curvature',[1 1],'FaceColor','g','EdgeColor','g');
end

end
