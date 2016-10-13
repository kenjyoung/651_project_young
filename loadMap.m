% Copyright (C) 2008 by Vadim Bulitko, University of Alberta
% September 2, 2008

function map = loadMap(mapName,dmax)
% loadMap
% Reads a HOG-formatted map (or a TXT map) and creates a map from it or simply loads a MAT-format map

if (nargin < 2)
    dmax = 1;
end

% Decide if we are loading from a MAP-file, TXT-file or from a MAT-file
[~, ~, ext] = fileparts(mapName);
switch (ext)
    
    case '.map'
        %% Load the map from a MAP-file
        fid = fopen(mapName,'r'); a = textscan(fid,'%s','headerlines',4); fclose(fid);
        map = (cell2mat(a{:}) == '@') | ...     % walls
            (cell2mat(a{:}) == 'O') | ...       % 'out of bounds'
            (cell2mat(a{:}) == 'W') | ...       % water
            (cell2mat(a{:}) == 'T');            % trees
        % 'G', 'g', 'S', 's' are allowed (passable)
        %fprintf('Loaded a %dx%d (HxW) map from %s\n',size(map,1),size(map,2),mapName);
        
        %% Pad the map
        if (nargin >= 2)
            map = padMap(map,dmax);
        end
        %fprintf('Paded %d-thick to %dx%d (HxW)\n',dmax,size(map,1),size(map,2));
        
    case '.mat'
        %% Load a map and a matrix of all pairs shortest path from it
        load(mapName);
        
    case '.txt'
        %% Load the map from a TXT-file
        fid = fopen(mapName,'r'); a = textscan(fid,'%s','headerlines',2,'BufSize',32768); fclose(fid);
        map = (cell2mat(a{:}) == '0');     % walls
        %fprintf('Loaded a %dx%d (HxW) map from %s\n',size(map,1),size(map,2),mapName);
        
        %% Pad the map
        if (nargin >= 2)
            map = padMap(map,dmax);
        end
        %fprintf('Paded %d-thick to %dx%d (HxW)\n',dmax,size(map,1),size(map,2));
        
end

end