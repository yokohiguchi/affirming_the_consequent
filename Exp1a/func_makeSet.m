function p = func_makeSet(p)

imgID1 = Shuffle(1:p.nImg(1)); % manmade
imgID2 = Shuffle(1:p.nImg(2)); % natural

% category index
% (manmade:1 natural:2)
%------------------------------------------
objCatIdx...
    = repmat([1 1 1, 2 2 2, 1 2 1, 2 1 2, 1 1 2, 2 2 1, 1 2 2, 2 1 1],1,round(p.nRepeatSet/8));


%% make sets
%---------------------------------------------------------
cat1 = 0; cat2 = 0;

% make sets
for set = 1: p.nRepeatSet
    p.set(set).cat = objCatIdx((set-1)*3+1:set*3);
    
    for item = 1:numel(p.set(set).cat)
        switch p.set(set).cat(item)
            case {1}
                cat1 = cat1+1;
                p.set(set).setItem(item) = imgID1(cat1);
            case {2}
                cat2 = cat2+1;
                p.set(set).setItem(item) = imgID2(cat2);
        end
    end
end

return