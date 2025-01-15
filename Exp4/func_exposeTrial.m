function c = func_exposeTrial(p, w, c, d)

% setting (duration and SOA)
% --------------------------
stimulusDur = p.learnStimDur;
stimulusSOA = p.learnSOA;

%	instruction & rest
% ------------------------
func_instruction(p,w,c,d);

% +++++ load stimulus textures +++++
[w,tex] = func_makeStimulusTextures(p,w,c);

%	ITI
%   (no iti in this exp)
% ------------------------
c.t.itiStart = GetSecs;

% offscrRect = [0 0 p.displaySize];
% onscrRect = CenterRect(offscrRect,p.screenRect);
% Screen('FillRect', w, p.bgColor);

% w = func_drawfixationCross(p, w);
% w = func_drawPlaceHolder(p, w);
% while((GetSecs-c.t.itiStart)<p.itiDur);end


%	Blank Display
% --------------------------
Screen('Flip', w);
c.t.blankStart = GetSecs;

% prepare stream
stream.frameType = 1:p.nSetFrame;
stream.length = length(stream.frameType);

% draw the first frame
w = func_drawStimFrame(p, w, c, tex, 1);
% while((GetSecs-c.t.blankStart)<p.blankDur);end


%%	Stimulus presentation
% --------------------------
for ff = 1:stream.length
    
    % set balancer to match SOA
    if ff == stream.length
        balancer = 0.05;
    else
        balancer = 0.01;
    end
    
    stimOn = 0;
    responseOn = 0;
    
    % close texture (to release memory)
    Screen('close', tex.stim(ff));
    
    % present display
    Screen('Flip', w);
    c.t.stimPresentation(ff) = GetSecs;
    stimOn = 1;
    
    % draw blank display
    Screen('FillRect', w, p.bgColor);
%     w = func_drawfixationCross(p, w);
    
    nn = 0;
    while 1
        [k.IsDown,k.ptime,k.code] = KbCheck;
        
        if (GetSecs-c.t.stimPresentation(ff))>stimulusDur-balancer && stimOn
            
            % stop presentation
            Screen('Flip', w); stimOn = 0;
            
            % draw next stimuli
            if ff~=stream.length
                w = func_drawStimFrame(p, w, c, tex, ff+1);
            end
            
        elseif (GetSecs-c.t.stimPresentation(ff))>stimulusSOA-balancer;
            break;
            
            
        elseif k.IsDown
            nn = nn + 1;
            responseOn = 1;
            
            if nn == 1
                if k.code(p.keyLeft)
                    c.pushKey(ff) = 1;
                    c.reactionTime(ff) = k.ptime-c.t.stimPresentation(ff);
                elseif k.code(p.keyRight)
                    c.pushKey(ff) = 2;
                    c.reactionTime(ff) = k.ptime-c.t.stimPresentation(ff);
                elseif k.code(p.keyZ)
                    c.pushKey(ff) = 3;
                    c.reactionTime(ff) = k.ptime-c.t.stimPresentation(ff);
                elseif k.code(p.keyEscape)
                    error('The program was terminated by the user.')
                else
                    c.pushKey(ff) = 99;
                    c.reactionTime(ff) = k.ptime-c.t.stimPresentation(ff);
                end
            end
        end
    end% while
    
    % ----- response check -----
    
    if ~responseOn
        c.pushKey(ff) = 0;
        c.reactionTime(ff) = -1;
        c.correctResponse(ff) = 0;
        func_feedbackError(p, w);
        
    elseif c.imgCat(ff) == c.pushKey(ff)
        c.correctResponse(ff) = 1;
        
    else
        c.correctResponse(ff) = 0;
        func_feedbackError(p, w);
    end
    
end

return


function func_feedbackError(p, w)

PsychPortAudio('Start',p.wav.error);
% for ii = 1:1
%     Screen('FillRect', w, [255 0 0]);
%     Screen('Flip', w);
%     WaitSecs(0.25);
%
%     Screen('FillRect', w, p.bgColor);
%     Screen('Flip', w);
%     WaitSecs(0.25);
% end
WaitSecs(1.5);
PsychPortAudio('Stop',p.wav.error);

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

for ii = 1:p.nSetFrame
        [imgMat, map, bg]...
            = imread(p.stim.imgname{c.imgCat(ii),c.setItem(ii)});
        
        % change background color
        imgMat...
            = changeBackgroundColor(p,imgMat, bg);
        
        % aspect ratio
        tex.size(ii,1) = size(imgMat, 2)/max(size(imgMat));
        tex.size(ii,2) = size(imgMat, 1)/max(size(imgMat));
    
       tex.stim(ii)= Screen('MakeTexture', w, imgMat);
end

clear imgMat*;

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
function func_instruction(p,w,c,d)

    if p.prac == 1
        nRestTrial = 10;
    else
        nRestTrial = p.nRestTrial;
    end


if mod(c.trial,nRestTrial) == 1;
    Screen('FillRect',w,p.bgColor);
    waitMouseClick = 0;
    
             if p.prac == 1
                mes = p.txt.pracStart;
                PsychPortAudio('Start',p.wav.start);
                
            elseif c.trial == 1;
                mes = p.txt.exposeStart;
                PsychPortAudio('Start',p.wav.start);
                
            else
                %                 mes = p.txt.rest;
                mes = ['Correct rate:    '  num2str(floor(mean([d.learn.correctResponse])*100)) ' % '];
                PsychPortAudio('Start',p.wav.start);
                
            end

else
    return;
    
end % if mod

%	present the text
% -------------------------
DrawFormattedText(w,mes,'Center','Center',p.txtColor);

Screen('Flip',w);

%	waitMouseClick?
% -------------------------
KbReleaseWait;

if ~waitMouseClick
    waitSpaceKey(p);
    
else
    WaitSecs(5);
    while(1)
        [mx,my,buttons] = GetMouse(p.screenID);
        if buttons(1);break;end
    end % wend
    
    Screen('FillRect',w,p.bgColor);
    DrawFormattedText(w,mes2,'Center','Center',p.txtColor);
    Screen('Flip',w);
    waitSpaceKey(p);
    
end
Screen('FillRect', w, p.bgColor);
Screen('Flip', w);

WaitSecs(1);

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

function w = func_drawPlaceHolder(p, w)

for locIdx = 1:p.nPlaceHolder
    [cir, loc] = func_locIdx2cirloc(p,locIdx);
    [x,y] = func_cirloc2xy(p,cir,loc);
    phRect = ...
        CenterRectOnPoint([0 0 p.itemSize(cir) p.itemSize(cir)], x+p.sx0, y+p.sy0);
    
    Screen('FrameOval', w, p.itemColor, phRect);
end % for loc

return

