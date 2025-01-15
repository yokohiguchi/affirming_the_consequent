function [p, c] = func_setCurrentCondition(p,d,trial,phase)

c.trial = trial;

switch phase
    case {1} % learning phase
        cSequence = p.sequence.learn(trial);
        c.block = cSequence.block;
        c.phase = phase;
        c.setID = cSequence.setID;
        c.imgCat = p.set(c.setID).cat;
        c.setItem = p.set(c.setID).setItem;
        
    case {2} % familiarity test
        cSequence = p.sequence.familiarity(trial);
        c.day = d.day(end);
        c.phase = phase;
        c.cond = cSequence.cond;
        c.setID = cSequence.setID;
%         c.pairID = cSequence.pairID;
        
        if d.day(end)==1 && c.setID+8>p.nRepeatSet/2
            c.pairID = c.setID+8-p.nRepeatSet/2;
        elseif d.day(end)==2 && c.setID+8>p.nRepeatSet
            c.pairID = c.setID+8-p.nRepeatSet/2;
        else
            c.pairID = c.setID+8;
        end
        
        
        switch c.cond
            case {1}
                c.setItem = p.set(c.setID).setItem(1:2); %AB
                c.setCat = p.set(c.setID).cat(1:2);
                c.testItem = [p.set(c.setID).setItem(1) p.set(c.pairID).setItem(2)]; %AE
                c.testCat = [p.set(c.setID).cat(1) p.set(c.pairID).cat(2)];
            case {2}
                c.setItem = [p.set(c.setID).setItem(3) p.set(c.setID).setItem(1)]; %AC
                c.setCat = [p.set(c.setID).cat(3) p.set(c.setID).cat(1)];
                c.testItem = [p.set(c.pairID).setItem(3) p.set(c.setID).setItem(1)]; %AF
                c.testCat = [p.set(c.pairID).cat(3) p.set(c.setID).cat(1)];
        end
        
        c.setPresentation = cSequence.setPresentation;
        
        
end

return