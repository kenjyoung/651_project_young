function mH = displayMap(map,f,fColor,useLog)
% Visualize the map and, optionally, a given function on the map
% f should contain non-negative values
% f = 0 is displayed as walls

cla

%% Display the map
pcolor2([],[],double(map),0.0);
colormap([1 1 1; 0.25 0.25 0.25]);
colorbar off;
axis ij equal tight;
hold on

%% Display the function
if (nargin >= 2)
    f(map) = 0;
    nzi = find(f)';
    if (useLog)
        f(nzi) = log(f(nzi));
    end
    maxF = max(max(f));
    nShades = 99;
    cm = makeColorMap([1 1 1],fColor,nShades+1);
    for i = nzi
        [y,x] = ind2sub(size(map),i);
        if(maxF>0)
            colorI = 1+round(nShades*f(i)/maxF);
        else
            colorI = 1;
        end
        rectangle('Position',[x+0.025,y+0.025,0.95,0.95],'Curvature',[0 0],...
            'FaceColor',cm(colorI,:),'EdgeColor',cm(colorI,:));
    end
end

%% Wrap up
drawnow
mH = gca;

end