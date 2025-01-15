%	script for familiarity test
%	2015/10/5
%   written by Yoko Higuchi

warning('off','MATLAB:dispatcher:InexactCaseMatch')

%   initialize
% +++++++++++++++++++++++++++++++++
clear all; close all; clc;
myKeyCheck;
rand('state',sum(100*clock));
KbName('UnifyKeyNames');
AssertOpenGL;
InitializePsychSound;

%%	Load expose result file
% ===================================================================
cd('./result');
while 1
    [fname,fpath] = uigetfile('*.mat','Select the result file');
    if fname==0
        error('file not found!');
    else
        load(strcat(fpath,fname));
        
        yn = input(['subjectName is ',d.subjectName,', right? (y/n): '],'s');
        if strcmpi(yn,'y')
            break;
        else
            clear p d;
        end
    end
end
cd ..
clear yn fname fpath;

%%  make trial sequence
% ===================================================================
p.designFile = 'design/design_v160.mat';
p.deviceNum = GetKeyNum;
p.nPulse = 1; % number of fMRI pulse to start
p.nWaitOnset = 8; % in sec

if ~isfield(d,'familiarity')
    d.day(1)=1;
    eval(['d.t.famiTestStartTime' num2str(d.day(end)) ' = datestr(now,30)']);
    p = func_makeFamiSequence(p,d);
elseif length(d.familiarity) == p.nFamiliarityTrial
    d.day(2)=2;
    eval(['d.t.famiTestStartTime' num2str(d.day(end)) ' = datestr(now,30)']);
    p = func_makeFamiSequence(p,d);
end


%%  initializing keyboard
% ===================================================================
p.keyRight = KbName('RightArrow');
p.keyLeft = KbName('LeftArrow');
p.keySpace = KbName('Space');
p.keyEscape = KbName('Escape');
p.keyZ = KbName('z');
p.key1 = KbName('1!');
p.key2 = KbName('2@');
p.key3 = KbName('3#');
p.key4 = KbName('4$');
p.key5 = KbName('5%');
p.key3_char = '3';
p.key4_char = '4';


try
    %%	initializing screens
    % ===================================================================
    [p,w] = func_initializeScreens(p);
    HideCursor;
    ListenChar(2);
    
    %%	familiarity
    % ===================================================================
    if ~isfield(d,'familiarity')
        startTrial = 1;
    elseif length(d.familiarity) < p.nFamiliarityTrial
        startTrial = length(d.familiarity)+1;
    else
        startTrial = length(d.familiarity)-p.nFamiliarityTrial+1;
    end
    
    
    
    for trial = startTrial:p.nFamiliarityTrial
        
        %	settings for the current trial
        % ------------------------------------
        [p,c] = func_setCurrentCondition(p,d,trial,2);
        
        %	start trial
        % ------------------------
        [c,d] = func_familiarityTrial(p,d,w,c);
        
        if d.day(end) == 1
            d.familiarity(trial) = c;
        else
            d.familiarity(trial+p.nFamiliarityTrial) = c;
        end
        
        % backup
        save(strcat('backup/trial/',d.dataFileName,'_backup.mat'),'p','d');
        
        if mod(trial,p.nFamiTrlPerRun)==0
            save(strcat('backup/run/', d.dataFileName,...
                '_day', num2str(c.day), '_run', num2str(c.run),'.mat'),'p','d');
            break;
        end
        
        clear c
    end % for trial
    clear trial
    
    %% closigng experiment
    % ===================================================================
    eval(['d.t.famiTestFinishTime' num2str(d.day(end)) ' = datestr(now,30)']);
    
    %	save the results & parameters
    % ++++++++++++++++++++++++++++++++++++++
    save(strcat('result/',d.dataFileName,'.mat'),'p','d');
    
    
    %	message
    % ++++++++++++++++++++++++++
    Screen('FillRect',w,p.bgColor)
    DrawFormattedText(w,p.txt.expFinish,'Center','Center',p.txtColor);
    Screen('Flip',w);
    disp('Press space key to finish')
    
    while (1)
        [k.IsDown,k.ptime,k.code] = KbCheck;
        if k.IsDown && k.code(p.keySpace)
            break;
        elseif k.IsDown && k.code(p.keyEscape)
            error('The program was terminated by the user.')
        end
    end
    disp('Finished')

    WaitSecs(1);
    
    
    %	close everything
    % ++++++++++++++++++++++++++
    Priority(0);
    Screen('CloseAll');
    PsychPortAudio('Close')
    ShowCursor;
    ListenChar(0);
    
    return;
    
    
    
catch
    d.t.familiarityAbortTime = datestr(now,30);
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