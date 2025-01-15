%	visual statistical learning
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

sess = input('session :  ');
if sess == 1
    d.session(sess)=sess;
    d.exposeStartTime = datestr(now,30);
    
    
    %%	parameter setting
    % ===================================================================
    % general parameter setting
    p = func_parameterSet;
    
    % input subject information
    [p, d] = func_subjectInfo(p, d);
    
    % assigning images to item sets
    p = func_makeSet(p);
    
    % Trial sequence (learning phase)
    p = func_makeLearnSequence(p);
    
else
    %%	Load search result file
    % ===================================================================
    cd('./result');
    while 1
        [fname,fpath] = uigetfile('*.mat','結果ファイルを選択してください');
        if fname==0
            error('file not found!');
        else
            load(strcat(fpath,fname));
            clc;
            yn = input(['subjectName is ',d.subjectName,', right? (y/n): '],'s');
            if strcmpi(yn,'y')
                d.session(sess)=sess;
                eval(['d.exposeStartTime' num2str(d.session(end)) ' = datestr(now,30)']);
                break;
            else
                clear p d;
            end
        end
    end
    cd ..
    clear yn fname fpath;
end

try
    %%	initializing screens
    % ===================================================================
    [p,w] = func_initializeScreens(p);
    HideCursor;
%     ListenChar(2);
    
    %%	learning phase
    % ===================================================================
    
    if sess == 1
        sTrl = 1;
        eTrl = p.nLearningTrial/5*3;
    elseif sess == 2
        p.wav = func_initializeSound;
        sTrl = p.nLearningTrial/5*3+1;
        eTrl = p.nLearningTrial;
    end
    
    for trial = sTrl:eTrl
        
        %	Settings for the current trial
        % ------------------------------------
        [p,c] = func_setCurrentCondition(p,d,trial,1);
        
        %	Start trial
        % ------------------------
        c = func_exposeTrial(p,w,c,d);
        d.learn(trial) = c;
        clear c
        
    end % for trial
    clear trial
    
    %% closigng experiment
    % ===================================================================
    eval(['d.exposeFinishTime' num2str(d.session(end)) ' = datestr(now,30)']);
    
    
    %	save the results & parameters
    % ++++++++++++++++++++++++++++++++++++++
    save(strcat('result/',d.dataFileName,'.mat'),'p','d');
    
    
    %	message
    % ++++++++++++++++++++++++++
    Screen('FillRect',w,p.bgColor)
    DrawFormattedText(w,p.txt.exposeFinish,'Center','Center',p.txtColor);
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
    mean([d.learn.correctResponse])
    return;
    
    
    
    
catch
    d.exposeAbortTime=datestr(now,30);
    
    % 	save(strcat('result/_incomplete_',d.dataFileName,'_expose.mat'),'p','d','c');
    
    
    %	close everything
    % ++++++++++++++++++++++++++
    Priority(0);
    Screen('CloseAll');
    PsychPortAudio('Close')
    ShowCursor;
    ListenChar(0);
    mean([d.learn.correctResponse])
    psychrethrow(psychlasterror);
end