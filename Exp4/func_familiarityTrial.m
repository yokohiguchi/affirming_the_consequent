function [c,d] = func_familiarityTrial(p, d, w, c)

%	instruction & rest
% ------------------------
func_instruction(p,w,c);

% Dammy scan (only for the very 1st trial)
if mod(c.trial,p.nFamiTrlPerRun)==1
    Screen('FillRect',w,p.bgColor);
    Screen('Flip', w);
    
    disp('========================');
    disp(['Day ' sprintf('%d',c.day) ' Run ' sprintf('%d',c.run) ' is ready']);
    disp('========================');
    disp('Waiting for an fMRI pulse...');
    
    count=0;
    while 1
        [mx,my,buttons] = GetMouse;
        if buttons(1)
            count = count + 1;
            disp('fMRI pulse detected');
        end
        
        if count == p.nPulse
            break;
        end
        
    end
    disp('Run started');
    d.t.runStartTime(c.day,c.run) = GetSecs;
    WaitSecs(p.nWaitOnset);
    
end

% prepare stream
stream.frameType = 1:length([c.setItem c.testItem]);
stream.length = length(stream.frameType);

% +++++ load stimulus textures +++++
[w,tex] = func_makeStimulusTextures(p,w,c);

% draw the first frame
w = func_drawStimFrame(p, w, c, tex, 1);

disp('---------');

if mod(c.trial,p.nFamiTrlPerRun)==0
    disp(['Day ' sprintf('%d',c.day) ' Run ' sprintf('%d\n',c.run) ...
        'Trial ' sprintf('%d\n',6)]);
else
    disp(['Day ' sprintf('%d',c.day) ' Run ' sprintf('%d\n',c.run) ...
        'Trial ' sprintf('%d\n', mod(c.trial,p.nFamiTrlPerRun)) ]);
end

disp('1st sequence');

%	Stimulus presentation
% --------------------------

% first sequence
for ff = 1:length(c.setItem)
    
    % present item
    c.t.stimPresentation(ff) = Screen('Flip', w);
    stimOn = 1;
    
    % draw blank display
    Screen('FillRect', w, p.bgColor);
    
    while 1
        [k.IsDown,k.ptime,k.code] = KbCheck;
        
        if (GetSecs-c.t.stimPresentation(ff)) >= p.learnStimDur && stimOn
            
            % stop presentation
            Screen('Flip', w); stimOn = 0;
            
            % draw next stimuli
            if ff~=length(c.setItem)
                w = func_drawStimFrame(p, w, c, tex, ff+1);
            end
            
        elseif (GetSecs-c.t.stimPresentation(ff)) >= p.learnSOA && ff~=length(c.setItem)
            break;
            
        elseif (GetSecs-c.t.stimPresentation(1)) >= c.design.seq1.dur
            break;
            
        elseif k.IsDown && k.code(p.keyEscape)
            error('The program was terminated by the user.')
        end
    end
    
    % Blank between sequences
    if ff == length(c.setItem)
        
        Screen('FillRect', w, p.bgColor);
        c.t.blankStart = Screen('Flip', w);
        
        while ((GetSecs-c.t.blankStart) < c.design.blank1.dur-1.5); end
        
        DrawFormattedText(w,'2nd','center','center',p.txtColor);
        c.t.txt1 = Screen('Flip', w);
        WaitSecs(0.3);
        
        % calculate difference between the scheduled and actual onset
        if mod(c.trial,p.nFamiTrlPerRun)==1
            onset = c.t.stimPresentation(1);
        else
            if c.day==1
                onset = d.familiarity(1+p.nFamiTrlPerRun*(c.run-1)).t.stimPresentation(1);
            elseif c.day==2
                onset = d.familiarity(1+p.nFamiTrlPerRun*(c.run-1)+p.nFamiliarityTrial).t.stimPresentation(1);
            end
        end
        
        diff = (c.t.blankStart - onset)- c.design.blank1.onset;
        
        Screen('FillRect', w, p.bgColor);
        Screen('Flip', w);
        while ((GetSecs-c.t.blankStart) < c.design.blank1.dur-diff); end
        clear diff onset
        
        % draw the 4th frame
        w = func_drawStimFrame(p, w, c, tex, length(c.setItem)+1);
        
    end
    
end

disp('2nd sequence');

% second sequence
for ff = length(c.setItem)+1:stream.length
    
    % present item
    c.t.stimPresentation(ff) = Screen('Flip', w);
    stimOn = 1;
    
    % draw blank display
    Screen('FillRect', w, p.bgColor);
    
    while 1
        [k.IsDown,k.ptime,k.code] = KbCheck;
        
        if (GetSecs-c.t.stimPresentation(ff)) >= p.learnStimDur && stimOn
            
            % stop presentation
            Screen('Flip', w); stimOn = 0;
            
            % draw next stimuli
            if ff~=stream.length
                w = func_drawStimFrame(p, w, c, tex, ff+1);
            end
            
        elseif (GetSecs-c.t.stimPresentation(ff)) >= p.learnSOA && ff~=stream.length
            break;
            
        elseif (GetSecs-c.t.stimPresentation(length(c.setItem)+1)) >= c.design.seq2.dur
            break;
            
        elseif k.IsDown && k.code(p.keyEscape)
            error('The program was terminated by the user.')
        end
    end
    
end

%	set discrimination
% ------------------------
c = func_getDiscrimResponse(p, w, c);


%	ITI
% ------------------------
Screen('FillRect', w, p.bgColor);
c.t.itiStart = 	Screen('Flip',w);
if mod(c.trial,p.nFamiTrlPerRun)==0
    disp('Closing experiment...');
else
    disp('Waiting for next trial');
end

while 1
    [k.avail, k.numChars] = CharAvail;
    
    if (GetSecs-c.t.discrimStart) >= c.design.blank2.dur-1.5
        break;
    elseif k.avail && isnan(c.discrimAnswer)
        k.pressed = GetChar;
        if strcmp(k.pressed,p.key4_char)
            c.discrimAnswer = 1;
            disp('Too slow response!');
            c.discrimReactionTime = GetSecs - c.t.discrimStart;
            
            if c.setPresentation == c.discrimAnswer
                c.discrimCorrect = 1;
            else
                c.discrimCorrect = 0;
            end
        elseif strcmp(k.pressed,p.key3_char)
            c.discrimAnswer = 2;
            disp('Too slow response!');
            c.discrimReactionTime = GetSecs - c.t.discrimStart;
            
            if c.setPresentation == c.discrimAnswer
                c.discrimCorrect = 1;
            else
                c.discrimCorrect = 0;
            end
        end
        FlushEvents('keyDown');
    end
end

if mod(c.trial,p.nFamiliarityTrial/p.nFamiBlockPerDay) ~= 0
    DrawFormattedText(w,'1st','center','center',p.txtColor);
    c.t.txt2 = Screen('Flip', w);
    WaitSecs(0.3);
end

Screen('FillRect', w, p.bgColor);
Screen('Flip', w);
while ((GetSecs-c.t.discrimStart) < c.design.blank2.dur); end

% Dammy scan
if mod(c.trial,p.nFamiTrlPerRun)==0
    Screen('FillRect',w,p.bgColor);
    Screen('Flip', w);
    
    WaitSecs(p.nWaitOnset);
    d.t.runFinishTime(c.day,c.run) = GetSecs;
    run_time = d.t.runFinishTime(c.day,c.run) - d.t.runStartTime(c.day,c.run);
    disp('========================');
    disp(['Day ' sprintf('%d',c.day) ' Run ' sprintf('%d',c.run) ' ended, took ' sprintf('%.5f',run_time) ' [sec]']);
    disp('========================');
    
end


return


% Sub functions
% - - - - - - - - - - - - - - - -
function c = func_getDiscrimResponse(p, w, c)
Screen('FillRect', w, p.bgColor);
DrawFormattedText(w,p.txt.recogMes,'Center','Center',p.txtColor);
c.t.discrimStart = Screen('Flip', w);

responseOn = 0;
FlushEvents('keyDown');

while (1)
    [k.avail, k.numChars] = CharAvail;
    if (GetSecs-c.t.discrimStart) > p.discrimLimit
        break;
        
    elseif k.avail
        k.pressed = GetChar;
        
        if strcmp(k.pressed,p.key4_char)
            responseOn = 1;
            c.discrimAnswer = 1;
            c.discrimReactionTime = GetSecs - c.t.discrimStart;
            break;
        elseif strcmp(k.pressed,p.key3_char)
            responseOn = 1;
            c.discrimAnswer = 2;
            c.discrimReactionTime = GetSecs - c.t.discrimStart;
            break;
        end
        FlushEvents('keyDown');
    end
    
end % wend

%	Correct?
% ---------------------------
if responseOn == 0
    
    if isfield(c,'discrimAnswer')
        disp('Too fast response!');
        c.discrimReactionTime = 0;
        if c.setPresentation == c.discrimAnswer
            c.discrimCorrect = 1;
        else
            c.discrimCorrect = 0;
        end
    else
        disp('No response!');
        c.discrimAnswer = NaN;
        c.discrimReactionTime = NaN;
        c.discrimCorrect = NaN;
    end
elseif responseOn == 1
    if c.setPresentation == c.discrimAnswer
        c.discrimCorrect = 1;
    else
        c.discrimCorrect = 0;
    end
end
disp(['RT: ' sprintf('%.5f',c.discrimReactionTime) ' [sec]']);


return

% - - - - - - - - - - - - - - - -
function w = func_drawfixationCross(p, w)

Screen('DrawLine',w,p.fixColor,p.sx0,p.sy0-p.fixSize2(2)/2,p.sx0,p.sy0+p.fixSize2(2)/2,3);
Screen('DrawLine',w,p.fixColor,p.sx0-p.fixSize2(1)/2,p.sy0,p.sx0+p.fixSize2(1)/2,p.sy0,3);

return

% - - - - - - - - - - - - - - - -
function w = func_drawStimFrame(p, w, c, tex, frame)

stimRect = ...
    CenterRectOnPoint(...
    [0 0 p.itemSize2*tex.size(frame,1) p.itemSize2*tex.size(frame,2)],p.sx0, p.sy0);

Screen('Blendfunction', w, GL_ONE, GL_ZERO);
Screen('DrawTexture', w, tex.stim(frame), [], stimRect);


return


% - - - - - - - - - - - - - - - -
function [w,tex] = func_makeStimulusTextures(p, w, c)

if c.setPresentation == 1
    seq = [c.setItem c.testItem];
    cat = [c.setCat c.testCat];
else
    seq = [c.testItem c.setItem];
    cat = [c.testCat c.setCat];
end

for ii = 1:length(seq)
    
    [imgMat, map, bg]...
        = imread(p.stim.imgname{cat(ii),seq(ii)});
    
    % change background color
    imgMat...
        = changeBackgroundColor(p,imgMat, bg);
    
    % aspect ratio
    tex.size(ii,1) = size(imgMat, 2)/max(size(imgMat));
    tex.size(ii,2) = size(imgMat, 1)/max(size(imgMat));
    
    tex.stim(ii)= Screen('MakeTexture', w, imgMat);
end

clear imgMat;

return


% - - - - - - - - - - - - - - - -
function func_instruction(p,w,c)

if mod(c.trial,p.nFamiliarityTrial/p.nFamiBlockPerDay) == 1
    if p.prac == 1
        mes = p.txt.pracStart;
    elseif c.trial == 1
        mes = p.txt.recogStart;
    else
        mes = ['Trial:    ' num2str(c.trial-1) ' / ' num2str(sum(p.nFamiliarityTrial))];
    end
else
    return;
end % if mod

%	present the text
% -------------------------
Screen('FillRect',w,p.bgColor);
DrawFormattedText(w,mes,'Center','Center',p.txtColor);
Screen('Flip',w);

%	wait spacekey
% -------------------------
KbReleaseWait;
waitSpaceKey(p);

return


% - - - - - - - - - - - - - - - -
function waitSpaceKey(p)

while (1)
    [k.IsDown,k.ptime,k.code] = KbCheck;
    if k.IsDown && k.code(p.keySpace)
        break;
    elseif k.IsDown && k.code(p.keyEscape)
        error('The program was terminated by the user.')
    end
end

return

% - - - - - - - - - - - - - - - -
function imgMat = changeBackgroundColor(p,imgMat,bg)

idx = find(bg==0);

for cc = 1:3
    iM = imgMat(:,:,cc);
    iM(idx) = p.bgColor(cc);
    imgMat(:,:,cc) = iM;
end

return
