%	script for familiarity test
%	2015/10/5

warning('off','MATLAB:dispatcher:InexactCaseMatch')

%   initialize
% +++++++++++++++++++++++++++++++++
clear all; close all; clc;
myKeyCheck;
rand('state',sum(100*clock));
KbName('UnifyKeyNames');
AssertOpenGL;
InitializePsychSound;


%%	parameter setting
% ===================================================================
% Load expose result file
cd('./result');
while 1
    [fname,fpath] = uigetfile('*.mat','Select the result file');
    if fname==0
        error('file not found!');
    else
        load(strcat(fpath,fname));
        
        yn = input(['subjectName is ',d.subjectName,', right? (y/n): '],'s');
        if strcmpi(yn,'y')
            day = input('day? (1 or 2): ');
            d.day(day)=day;
            eval(['d.famiTestStartTime' num2str(d.day(end)) ' = datestr(now,30)']);
            break;
        else
            clear p d;
        end
    end
end
cd ..
clear yn fname fpath;


%% make trial sequence
% ===================================================================
if d.day(end)==1
    set_id = 1:p.nRepeatSet/2;
else
    set_id = p.nRepeatSet/2+1:p.nRepeatSet;
end

% % cond1: ABC vs AEI, cond2: ABC vs DEF
% b(1,:) = repmat([1 2],1,p.nRepeatSet/4); % block1 cond
% b(2,:) = repmat([2 1],1,p.nRepeatSet/4); % block2 cond

condidx = Shuffle(set_id);
p.condidx(1,:,d.day(end)) = condidx(1:length(condidx)/2);
p.condidx(2,:,d.day(end)) = condidx(length(condidx)/2+1:end);

bcond = Shuffle(1:2);

cond = [bcond(1)*ones(1,length(set_id)) bcond(2)*ones(1,length(set_id))];
setID = [];
for bb = 1:2
    for ii = 1:2
        setID = [setID Shuffle(p.condidx(bcond(bb),:,d.day(end)))];
    end
end

setPresentation = [];
for ii = 1:2
    setPresentation...
        =[setPresentation Shuffle(repmat(1:2,1,p.nRepeatSet/4))];
end


for trl = 1:length(setID)
    
    p.sequence.familiarity(trl).setID = setID(trl);
%     p.sequence.familiarity(trl).pairID = pairID(trl);
    p.sequence.familiarity(trl).cond = cond(trl);
    p.sequence.familiarity(trl).setPresentation = setPresentation(trl);
    
end

%%	initializing sound
% ===================================================================
clear p.wav;
p.wav.start = func_wavPreparation('wav/start.wav');
p.wav.feedback = func_wavPreparation('wav/tone.wav');
p.wav.error = func_wavPreparation('wav/error.wav');
p.wav.finish = func_wavPreparation('wav/finish.wav');


try
    %%	initializing screens
    % ===================================================================
    [p,w] = func_initializeScreens(p);
    HideCursor;
    %     ListenChar(2);
    
    %%	familiaritynition phase
    % ===================================================================
    for trial = 1:p.nFamiliarityTrial
        
        %	settings for the current trial
        % ------------------------------------
        [p,c] = func_setCurrentCondition(p,d,trial,2);
        
        %	start trial
        % ------------------------
        c = func_familiarityTrial(p,w,c);
        if d.day(end) == 1
            d.familiarity(trial) = c;
        else
            d.familiarity(trial+p.nFamiliarityTrial) = c;
        end
        clear c
        
    end % for trial
    clear trial
    
    
    %% closigng experiment
    % ===================================================================
    eval(['d.famiTestFinishTime' num2str(d.day(end)) ' = datestr(now,30)']);
    
    %	save the results & parameters
    % ++++++++++++++++++++++++++++++++++++++
    save(strcat('result/',d.dataFileName,'.mat'),'p','d');
    
    %	message
    % ++++++++++++++++++++++++++
    Screen('FillRect',w,p.bgColor)
    DrawFormattedText(w,p.txt.expFinish,'Center','Center',p.txtColor);
    Screen('Flip',w);
    PsychPortAudio('Start',p.wav.finish);
    
    WaitSecs(5);
    
    
    %	close everything
    % ++++++++++++++++++++++++++
    Priority(0);
    Screen('CloseAll');
    PsychPortAudio('Close')
    ShowCursor;
    ListenChar(0);
    
    return;
    
    
    
    
catch
    d.familiarityAbortTime = datestr(now,30);
    % 	try
    % 		save(strcat('result/_incomplete_',d.dataFileName,'_familiarity.mat'),'p','d','c');
    % 	catch
    % 		disp('could not save the result!');
    % 	end
    
    %	close everything
    % ++++++++++++++++++++++++++
    Priority(0);
    Screen('CloseAll');
    PsychPortAudio('Close')
    ShowCursor;
    ListenChar(0);
    
    psychrethrow(psychlasterror);
end