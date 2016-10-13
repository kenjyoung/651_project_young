function str = gene2str(gene)
%% Displays the gene in a human-readable form
% Vadim Bulitko
% Feb 16, 2016

w = gene(1);
wc = gene(2);
da = round(gene(3));
markExpendable = round(gene(4));
backtrack = round(gene(5));
learningOperator = round(gene(6));
beamWidth = gene(7);
learningQuota = gene(8);

opNames = {'min','avg','median','max'};

if (~isempty(gene))
    bS = '';
    daS = '';
    eS = '';
    if (backtrack)
        bS = sprintf('+backtrack(%0.1f)',learningQuota);
    end
    if (da)
        daS = '+da';
    end
    if (markExpendable)
        eS = '+E';
    end
    str = sprintf('%0.3f * %s_{%0.3f}(%0.3f*c + h)%s%s%s',...
        w,opNames{round(learningOperator)},beamWidth,wc,bS,daS,eS);
else
    str = [];
end

end
