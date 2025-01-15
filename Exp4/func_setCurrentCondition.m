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
        c.design = p.famiDesign(trial,d.day(end));
        c.day = d.day(end);
        c.phase = phase;
        c.cond = cSequence.cond;
        c.run = cSequence.run;
        c.setID = cSequence.setID;

        if d.day(end)==1 && c.setID+8>p.nRepeatSet/2
            c.foilID1 = c.setID+8-p.nRepeatSet/2;
        elseif d.day(end)==2 && c.setID+8>p.nRepeatSet
            c.foilID1 = c.setID+8-p.nRepeatSet/2;
        else
            c.foilID1 = c.setID+8;
        end
        
        if d.day(end)==1 && c.setID+16>p.nRepeatSet/2
            c.foilID2 = c.setID+16-p.nRepeatSet/2;
        elseif d.day(end)==2 && c.setID+16>p.nRepeatSet
            c.foilID2 = c.setID+16-p.nRepeatSet/2;
        else
            c.foilID2 = c.setID+16;
        end
        
        switch c.cond
            case {1} %ABC vs foil
                c.setItem = p.set(c.setID).setItem;
                c.setCat = p.set(c.setID).cat;
                c.testItem = [p.set(c.setID).setItem(1) p.set(c.foilID1).setItem(2) p.set(c.foilID2).setItem(3)]; %AEG
                c.testCat = [p.set(c.setID).cat(1) p.set(c.foilID1).cat(2) p.set(c.foilID2).cat(3)];
            case {2} %ABC vs FED
                c.setItem =  p.set(c.setID).setItem;
                c.setCat = p.set(c.setID).cat;
                c.testItem = fliplr(p.set(c.foilID1).setItem);
                c.testCat =  fliplr(p.set(c.foilID1).cat);
        end
       
        c.setPresentation = cSequence.setPresentation;
        
        
end

return