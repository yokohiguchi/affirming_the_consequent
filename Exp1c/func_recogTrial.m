function c = func_recogTrial(p, w, c)

% setting (duration and SOA)
% --------------------------
stimulusDur = p.testStimDur;
stimulusSOA = p.testSOA;

%	instruction & rest
% ------------------------
func_instruction(p,w,c);

% +++++ load stimulus textures +++++
[w,tex] = func_makeStimulusTextures(p,w,c);

%	ITI
%   (no iti in this exp)
% ------------------------
c.t.itiStart = GetSecs;
w = func_drawfixationCross(p, w);

%	Blank Display
%   (no blank in this exp)
% --------------------------
Screen('Flip', w);
c.t.fixStart = GetSecs;
while((GetSecs-c.t.fixStart)<1);end

% draw the first frame
% --------------------------
w = func_drawStimFrame(p, w, c, tex, 1);


%%	Stimulus presentation
% --------------------------
balancer = 0.01;
stimOn = 0;
responseOn = 0;

% present display
Screen('Flip', w);
c.t.stimPresentation(1) = GetSecs;
stimOn = 1;

% draw blank display
Screen('FillRect', w, p.bgColor);
w = func_drawfixationCross(p, w);

while 1
    [k.IsDown,k.ptime,k.code] = KbCheck;
    if (GetSecs-c.t.stimPresentation(1))>stimulusDur-balancer && stimOn
        
        % stop presentation
        Screen('Flip', w); stimOn = 0;
        
        % draw next stimuli
        w = func_drawStimFrame(p, w, c, tex, 2);
        
    elseif (GetSecs-c.t.stimPresentation(1))>stimulusSOA-balancer
        break;
        
    elseif k.IsDown && k.code(p.keyEscape)
        error('The program was terminated by the user.');
    end
end
    
Screen('Flip', w); stimOn = 1;
c.t.stimPresentation(2) = GetSecs;

% Get mouse response
c = getMouseResponse(p, w, c);

Screen('FillRect', w, p.bgColor);
Screen('Flip', w);
WaitSecs(0.5);

c = getConfidence(p, w, c);


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

return


function w = func_drawfixationCross(p, w)

Screen('DrawLine',w,p.fixColor,p.sx0,p.sy0-p.fixSize(2)/2,p.sx0,p.sy0+p.fixSize(2)/2,3);
Screen('DrawLine',w,p.fixColor,p.sx0-p.fixSize(1)/2,p.sy0,p.sx0+p.fixSize(1)/2,p.sy0,3);

return


function w = func_drawStimFrame(p, w, c, tex, frame)

for item = 1:c.nDispItem(frame)
    
    if c.imgCat(item,frame) < 3
        [cir, loc] = func_locIdx2cirloc(p,c.loc(item,frame));
        [x,y] = func_cirloc2xy(p,cir,loc);
        
        stimRect = ...
            CenterRectOnPoint(...
            [0 0 p.itemSize(cir)*tex.size(item,frame,1) p.itemSize(cir)*tex.size(item,frame,2)],...
            x+p.sx0, y+p.sy0);
        
        mess = 'DrawTexture';
        Screen('Blendfunction', w, GL_ONE, GL_ZERO);
        eval(['Screen(mess, w, tex.stim' num2str(item) '(frame), [], stimRect);']);
    else
        
        mess = 'DrawTexture';
        Screen('Blendfunction', w, GL_ONE, GL_ZERO);
        eval(['Screen(mess, w, tex.stim' num2str(item) '(frame));']);
    end
    
end

if c.imgCat(item,frame) < 3
    w = func_drawfixationCross(p, w);
    % w = func_drawPlaceHolder(p, w);
end
return



function [w,tex] = func_makeStimulusTextures(p, w, c)

for ii = 1:p.nSetFrame
    for item = 1:c.nDispItem(ii)
        eval(['[imgMat' num2str(item) ', map, bg]'...
            '= imread(p.stim.imgname{c.imgCat(item,ii),c.setItem(item,ii)});']);
        
        % change background color
        eval(['imgMat' num2str(item)...
            '= changeBackgroundColor(p,imgMat' num2str(item) ', bg);']);
        
        % aspect ratio
        eval(['tex.size(item,ii,1) = size(imgMat' num2str(item) ', 2)'...
            '/max(size(imgMat' num2str(item) '));']);
        eval(['tex.size(item,ii,2) = size(imgMat' num2str(item) ', 1)'...
            '/max(size(imgMat' num2str(item) '));']);
    end
    
    mess = 'MakeTexture';
    for item = 1:c.nDispItem(ii)
        eval(['tex.stim' num2str(item) '(ii)'...
            '= Screen(mess, w, imgMat' num2str(item) ');']);
    end
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
function func_instruction(p,w,c)

if mod(c.trial, p.nTestTrial/4) == 1;
    if p.prac == 1
        mes = p.txt.pracStart;
    elseif c.trial == 1;
        mes = p.txt.recogStart;
    else
        mes = ['Trial:    ' num2str(c.trial-1) ' / ' num2str(sum(p.nTestTrial))];
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

function w = func_drawPlaceHolder(p, w)

for locIdx = 1:p.nPlaceHolder
    [cir, loc] = func_locIdx2cirloc(p,locIdx);
    [x,y] = func_cirloc2xy(p,cir,loc);
    phRect = ...
        CenterRectOnPoint([0 0 p.itemSize(cir) p.itemSize(cir)], x+p.sx0, y+p.sy0);
    
    Screen('FrameOval', w, p.itemColor, phRect);
end % for loc

return

function c = getMouseResponse(p, w, c)
    ShowCursor('Arrow');
    SetMouse(p.sx0,p.sy0,p.screenID);
    
    c.setLoc = c.loc(c.itemType,2);
    if c.itemType == 1;
        c.foilLoc = c.loc(2,2);
    else
        c.foilLoc = c.loc(1,2);
    end
        

    %	wait for mouse click
    % ---------------------------
    while (1)

        [mx,my,buttons] = GetMouse(p.screenID);
        [k.IsDown,k.ptime,k.code] = KbCheck;


        % is placeHolder selected?
        c.choiceLoc = func_isSelected(p,mx,my);

        % Which item was selected?
        if buttons(1)
            c.choiceTime = GetSecs - c.t.stimPresentation(2);
            if c.choiceLoc == c.setLoc
                c.choiceCorrect = 1;
                break;
            elseif c.choiceLoc == c.foilLoc
                c.choiceCorrect = 0;
                break;
            else
                continue;
            end
        elseif k.IsDown && k.code(KbName('escape'))
            error('The program was terminated by the user.')
        end
    end % wend

    HideCursor;
return

function selectedLoc = func_isSelected(p,mx,my)

	selectedLoc=0;

	for locIdx = 1:p.nPlaceHolder
		[cir, loc] = func_locIdx2cirloc(p,locIdx);
		[x,y] = func_cirloc2xy(p,cir,loc);
		phRect = ...
			CenterRectOnPoint([0 0 p.itemSize(cir) p.itemSize(cir)], x+p.sx0, y+p.sy0);
        
		if IsInRect(mx,my,phRect)
			selectedLoc = locIdx;
			break;
		end
	end

return

function c = getConfidence(p, w, c)

SetMouse(p.sx0,p.sy0,p.screenID);
c.t.confidence = GetSecs;

while (1)
    
    % put cans
    Screen('FillRect', w, p.bgColor);
    %     wCan = Screen('OpenOffScreenWindow', w, p.bgColor);
    %     Screen('CopyWindow', wCan, w);
    
    % draw scale
    Screen('DrawLine',w,0,p.sx0-400/2,p.sy0,p.sx0+400/2,p.sy0,3);
    Screen('DrawLine',w,0,p.sx0-400/2,p.sy0-p.fixSize(2)/2,p.sx0-400/2,p.sy0+p.fixSize(2)/2,3);
    Screen('DrawLine',w,0,p.sx0+400/2,p.sy0-p.fixSize(2)/2,p.sx0+400/2,p.sy0+p.fixSize(2)/2,3);
    
    % text
    DrawFormattedText(w,p.txt.confidence,'Center',p.sy0-100,p.txtColor);
    tRect = Screen('TextBounds',w,p.txt.high);
    tx = p.sx0+700/2 - RectWidth(tRect) / 2;
    DrawFormattedText(w,p.txt.high, tx,'Center',p.txtColor);
    tRect = Screen('TextBounds',w,p.txt.low);
    tx = p.sx0-700/2 - RectWidth(tRect) / 2;
    DrawFormattedText(w,p.txt.low, tx,'Center',p.txtColor);
    
    
    [k.IsDown,k.ptime,k.code] = KbCheck;
    [mx,my,buttons] = GetMouse(p.screenID);
    if mx > p.sx0+400/2
        mx = p.sx0+400/2;
    elseif mx < p.sx0-400/2
        mx = p.sx0-400/2;
    end
    
    pRect = [mx p.sy0;mx-15 p.sy0+30;mx+15 p.sy0+30];
    Screen('FillPoly',w,0,pRect);
    
    Screen('Flip',w);
    
    if buttons(1)
        c.confTime = GetSecs - c.t.confidence;
        c.confidence = 1-((p.sx0+400/2-mx)/400);
        break;
    elseif k.IsDown && k.code(KbName('escape'))
        error('The program was terminated by the user.')
    end
end % wend

return