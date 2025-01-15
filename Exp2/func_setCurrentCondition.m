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
        
        if trial==1
            foil1idx = find(p.condidx(c.cond,:,c.day)==c.setID)+1;
            foil2idx = find(p.condidx(c.cond,:,c.day)==c.setID)+2;
            foil3idx = find(p.condidx(c.cond,:,c.day)==c.setID)+3;
        else
            foil1idx = find(p.condidx(c.cond,:,c.day)==c.setID)+1+ismember(c.setID,[d.familiarity.setID]);
            foil2idx = find(p.condidx(c.cond,:,c.day)==c.setID)+2+ismember(c.setID,[d.familiarity.setID]);
            foil3idx = find(p.condidx(c.cond,:,c.day)==c.setID)+3+ismember(c.setID,[d.familiarity.setID]);
        end
        
        
        if foil1idx>12
            c.foilID1 = p.condidx(c.cond,foil1idx-12,c.day);
        else
            c.foilID1 = p.condidx(c.cond,foil1idx,c.day);
        end
        
        if foil2idx>12
            c.foilID2 = p.condidx(c.cond,foil2idx-12,c.day);
        else
            c.foilID2 = p.condidx(c.cond,foil2idx,c.day);
        end
        
         if foil3idx>12
            c.foilID3 = p.condidx(c.cond,foil3idx-12,c.day);
        else
            c.foilID3 = p.condidx(c.cond,foil3idx,c.day);
        end
        
        switch c.cond
            case {1}
                c.setItem = p.set(c.setID).setItem; %ABC
                c.setCat = p.set(c.setID).cat;
                c.testItem = [p.set(c.foilID1).setItem(1) p.set(c.foilID2).setItem(2) p.set(c.foilID3).setItem(3)]; %AEG
                c.testCat = [p.set(c.foilID1).cat(1) p.set(c.foilID2).cat(2) p.set(c.foilID3).cat(3)];
            case {2}
                c.setItem =  p.set(c.setID).setItem; %ABC
                c.setCat = p.set(c.setID).cat;
                c.testItem = fliplr(p.set(c.foilID1).setItem); %CBA
                c.testCat =  fliplr(p.set(c.foilID1).cat);
        end
       
        c.setPresentation = cSequence.setPresentation;
        
        
end

return