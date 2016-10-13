function h = pcolor2(x,y,v,linewidth)
% pcolor2 - a corrected pcolor plot
% plots pcolor without chewing off the necessary parts and labels the plot

if (nargin < 3)
    v = x;
    x = [];
    y = [];
end

if (nargin < 4)
    linewidth = 0.5;
end

% Don't display x and y labels if they are too long
if (length(x) > 40)
    x = [];
end

if (length(y) > 40)
    y = [];
end

h = pcolor(padMatrix(v));

colorbar;
set(gca,'XTick',(1:length(x))+0.5);
set(gca,'XTickLabel',x);
set(gca,'YTick',(1:length(y))+0.5);
set(gca,'YTickLabel',y);
axis tight;

if (linewidth ~= 0)
    set(h,'LineWidth',linewidth);
else
    set(h,'EdgeColor','none');
end

end