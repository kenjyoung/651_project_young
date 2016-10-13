function exportFigure(fig,fileName,extension,size,~)
% exportFigure exports a figure
% extension and size are optional. The default values are 'pdf' and [8 11]

% Fill in the default values
if (nargin < 4)
    size = [11 8];
end
if (nargin < 3)
    extension = 'pdf';
end

%% R014b
set(fig,'PaperUnits','inches');
set(fig,'PaperPosition',[0 0 size]);
set(fig,'PaperSize',size);
saveas(fig,[fileName '.' extension]);

%% Pre R2014b
% set(fig,'Renderer','painters');              % vector: for final prints
% set(fig,'PaperType','<custom>');
% set(fig,'Color',[1 1 1]);
% set(fig,'PaperOrientation','portrait');
% set(fig,'PaperUnits','normalized');
% set(fig,'PaperPosition',[0 0 1 1]);
% set(fig,'PaperPositionMode','manual');
% set(fig,'PaperUnits','inches');
% set(fig,'PaperSize',size);
% 
% [fileName, ~] = sprintf('%s.%s',fileName,extension);
% printMode = sprintf('-d%s',extension);
% if (nargin < 5)
%     print(fig,printMode,fileName);
% else
%     print(fig,printMode,sprintf('-r%d',resolution),fileName);
% end

end
