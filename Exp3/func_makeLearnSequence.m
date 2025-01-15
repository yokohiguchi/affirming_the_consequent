function p = func_makeLearnSequence(p)

trial = 0;

for bb = 1:p.nLearningBlock
    
    while 1
        % shuffle layout IDs
        setID = Shuffle(1:length([p.set]));
        
        % 1st in block n should not be the same
        % with last in block n-1 
        if bb==1
            break;
        elseif setID(1) ~= seq(length([p.set])*(bb-1)).setID
            break;
        end
    end
    
    for tt = 1:length([p.set])
        trial = trial + 1;
        seq(trial).block = bb;
        seq(trial).setID = setID(tt);
        
    end % for tt
    clear tt
    
end % for bb;

p.sequence.learn = seq;

clear bb trial seq

return