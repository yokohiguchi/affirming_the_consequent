function p = func_makeFamiSequence(p,d)

load(p.designFile);

if d.day(end)==1
    p.designIdx = Shuffle(1:length(design));
end

if d.day(end)==1
    set_id = 1:p.nRepeatSet/2;
    dsnIdx = p.designIdx(1:p.nFamiBlockPerDay);
else
    set_id = p.nRepeatSet/2+1:p.nRepeatSet;
    dsnIdx = p.designIdx(p.nFamiBlockPerDay+1:p.nFamiBlockPerDay*2);
end

% run
rn = 1; runIdx = [];
for ii = 1:p.nFamiBlockPerDay
    runIdx = [runIdx ones(1,p.nFamiTrlPerRun)*ii];
    rn = rn+1;
end
clear ii rn

% cond2: ABC vs FED
b(1,:) = repmat(2,1,p.nRepeatSet/2);

setID = []; cond = [];
for ii = 1:size(b,1)
    [new, idx] = Shuffle(set_id);
    setID = [setID new];
    cond = [cond b(ii,idx)];
    clear new idx
end
clear ii

temp = [design(dsnIdx).trial];

for trl = 1:length(setID)
    p.sequence.familiarity(trl).run = runIdx(trl);
    p.sequence.familiarity(trl).setID = setID(trl);
    p.sequence.familiarity(trl).cond = cond(trl);
    p.sequence.familiarity(trl).setPresentation...
        = temp(trl).setPresentation;
    p.famiDesign(trl,d.day(end))=temp(trl);
end
clear trl


return