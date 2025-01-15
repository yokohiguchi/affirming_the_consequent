function c = func_familiarityTrial(p, w, c)

%	instruction & rest
% ------------------------
func_instruction(p,w,c);

% %	ITI
% % ------------------------
% Screen('FillRect',w,p.bgColor);
% c.t.itiStart = 	Screen('Flip',w);
%
% while((GetSecs-c.t.itiStart)<1);end

%	Fixation Display
% ------------------------
% w = func_drawfixationCross(p, w);
Screen('FillRect',w,p.bgColor);
Screen('Flip', w);
WaitSecs(1);

DrawFormattedText(w,'1st','center','center',p.txtColor);
c.t.fixStart = Screen('Flip', w);
while((GetSecs-c.t.fixStart)<0.75);end

%	Blank Display
% ------------------------
Screen('FillRect',w,p.bgColor);
Screen('Flip', w);
WaitSecs(0.75);

% prepare stream
stream.frameType = 1:6;
stream.length = length(stream.frameType);

% +++++ load stimulus textures +++++
[w,tex] = func_makeStimulusTextures(p,w,c);

% draw the first frame
w = func_drawStimFrame(p, w, c, tex, 1);

%	Stimulus presentation
% --------------------------
for ff = 1:stream.length
    
    % set balancer to match SOA
    if ff == stream.length
        balancer = 0.04;
    else
        balancer = 0.02;
    end
    
    stimOn = 0;
    responseOn = 0;
    
    % present display
    Screen('Flip', w);
    c.t.stimPresentation(ff) = GetSecs;
    stimOn = 1;
    
    % draw blank display
    Screen('FillRect', w, p.bgColor);
    %     w = func_drawfixationCross(p, w);
    
    while 1
        [k.IsDown,k.ptime,k.code] = KbCheck;
        
        if ff==stream.length/2 % between set and foil
            if (GetSecs-c.t.stimPresentation(ff))>p.learnStimDur && stimOn
                
                % stop presentation
                Screen('Flip', w); stimOn = 0;
                WaitSecs(0.75);
                
                % draw blank display
                Screen('FillRect', w, p.bgColor);
                Screen('Flip', w);
                WaitSecs(1);
                
                % fixation
                %                 w = func_drawfixationCross(p, w);
                DrawFormattedText(w,'2nd','center','center',p.txtColor);
                Screen('Flip', w);
                WaitSecs(0.75);
                
                % blank
                Screen('FillRect', w, p.bgColor);
                Screen('Flip', w);
                
                % draw next stimuli
                w = func_drawStimFrame(p, w, c, tex, ff+1);
                WaitSecs(1);
                break;
                
            elseif k.IsDown && k.code(p.keyEscape)
                error('The program was terminated by the user.')
            end
            
        else
            if (GetSecs-c.t.stimPresentation(ff))>p.learnStimDur && stimOn
                
                
                % stop presentation
                Screen('Flip', w); stimOn = 0;
                
                % draw next stimuli
                if ff~=stream.length
                    w = func_drawStimFrame(p, w, c, tex, ff+1);
                end
                
            elseif (GetSecs-c.t.stimPresentation(ff))>p.learnSOA-balancer;
                break;
                
            elseif k.IsDown && k.code(p.keyEscape)
                error('The program was terminated by the user.')
            end
        end % if
        
    end % while
    
end % for ff


%	set discrimination
% ------------------------
c = func_getDiscrimResponse(p, w, c);


return

% - - - - - - - - - - - - - - - -
function c = func_getDiscrimResponse(p, w, c)

Screen('FillRect', w, p.bgColor);
DrawFormattedText(w,p.txt.recogMes,'Center','Center',p.txtColor);
c.t.discrimStart = Screen('Flip', w);

while (1)
    
    [k.IsDown,k.ptime,k.code] = KbCheck;
    
    if k.IsDown
        if k.code(p.keyLeft)
            c.discrimAnswer = 1;
            c.DiscrimReactionTime = GetSecs - c.t.discrimStart;
            break;
        elseif k.code(p.keyRight)
            c.discrimAnswer = 2;
            c.DiscrimReactionTime = GetSecs - c.t.discrimStart;
            break;
            
        elseif k.code(p.keyEscape)
            error('The program was terminated by the user.')
        end
    end
    
end % wend

%	Correct?
% ---------------------------
if c.setPresentation == c.discrimAnswer
    c.discrimCorrect = 1;
else
    c.discrimCorrect = 0;
end

return


function w = func_drawfixationCross(p, w)

Screen('DrawLine',w,p.fixColor,p.sx0,p.sy0-p.fixSize(2)/2,p.sx0,p.sy0+p.fixSize(2)/2,3);
Screen('DrawLine',w,p.fixColor,p.sx0-p.fixSize(1)/2,p.sy0,p.sx0+p.fixSize(1)/2,p.sy0,3);

return


function w = func_drawStimFrame(p, w, c, tex, frame)

stimRect = ...
    CenterRectOnPoint(...
    [0 0 p.itemSize*tex.size(frame,1) p.itemSize*tex.size(frame,2)],p.sx0, p.sy0);

Screen('Blendfunction', w, GL_ONE, GL_ZERO);
Screen('DrawTexture', w, tex.stim(frame), [], stimRect);


return



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


function [cir, loc] = func_locIdx2cirloc(p,locIdx)

for ii=1:p.nCircle
    if ii==1
        startIdx = 1;
        endIdx = p.nPlaceHoldersForCircle(1);
    else
        startIdx = startIdx+p.nPlaceHoldersForCircle(ii-1);
        endIdx = startIdx+p.nPlaceHoldersForCircle(ii)-1;
    end
    
    if locIdx >= startIdx && locIdx <= endIdx
        cir = ii;
        loc = locIdx - startIdx + 1;
        break;
    end
end

if isempty(cir)
    error('does not work');
end


return


% - - - - - - - - - - - - - - - -
function [x,y] = func_cirloc2xy(p,cir,loc)
degStep = 360/p.nPlaceHoldersForCircle(cir);
degArray = degStep.*(0:p.nPlaceHoldersForCircle(cir)-1) + ((degStep/2)*(cir-1));
degArray = degArray*pi/180;

deg = degArray(loc);
r = p.diameters(cir)/2;

x = round(cos(deg)*r);
y = round(sin(deg)*r);

return


% - - - - - - - - - - - - - - - -
function func_instruction(p,w,c)

if mod(c.trial,p.nFamiliarityTrial/8) == 1;
    if p.prac == 1
        mes = p.txt.pracStart;
    elseif c.trial == 1;
        mes = p.txt.recogStart;
    else
        mes = ['Trial:    ' num2str(c.trial-1) ' / ' num2str(sum(p.nFamiliarityTrial))];
    end
else
    return;
end % if mod

%	present the text
% -------------------------
PsychPortAudio('Start',p.wav.start);

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


function imgMat = changeBackgroundColor(p,imgMat,bg)

idx = find(bg==0);

for cc = 1:3
    iM = imgMat(:,:,cc);
    iM(idx) = p.bgColor(cc);
    imgMat(:,:,cc) = iM;
end

return
