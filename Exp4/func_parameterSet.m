function p = func_parameterSet

%	Display
% -----------------------
p.displaySize = [800 800];
p.x0 = p.displaySize(1)/2;
p.y0 = p.displaySize(2)/2;


%	Stimuli
% -----------------------
p.itemSize = func_pixelPerDegree(8,1);
p.fixSize = func_pixelPerDegree([1 1],1);
p.pointerSize = [30 30];

p.itemSize2 = func_pixelPerDegree(8,2); % for fMRI
p.fixSize2 = func_pixelPerDegree([1 1],2); % for fMRI


%	Experimental design
% -----------------------
p.nRepeatSet = 48;
p.nSetFrame = 3;

p.nLearningBlock = 10;
p.nLearningTrial...
    = p.nRepeatSet * p.nLearningBlock;
p.nRestTrial...
    = p.nRepeatSet*2;

p.nFamiliarityTrial = p.nRepeatSet/2;
p.nFamiliarityBlock = 1;
p.nFamiBlockPerDay = 4;
p.nFamiTrlPerRun...
    = p.nFamiliarityTrial/p.nFamiBlockPerDay;

%	timing (in sec)
% ++++++++++++++++++++++++++
p.itiDur = 0;
p.fixDur = 0.75;
p.blankDur = 0;
p.learnStimDur = 0.75;
p.learnSOA = 1.5;
p.discrimLimit = 1.5;


%	key
% ++++++++++++++++++++++++++
% p.keyboardIndices = GetKeyboardIndices;
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


%	color
% ++++++++++++++++++++++++++
p.bgColor = [123 123 123];
p.fixColor = [0 0 0];
p.itemColor = [255 255 255];
p.txtColor = 0;
p.pointerColor = [255 0 0];


%	sound
% ++++++++++++++++++++++++++
p.wav.start = func_wavPreparation('wav/start.wav');
p.wav.feedback = func_wavPreparation('wav/tone.wav');
p.wav.error = func_wavPreparation('wav/error.wav');
p.wav.finish = func_wavPreparation('wav/finish.wav');


%	load images
% ++++++++++++++++++++++++++
clc; commandwindow;
fprintf('Now loading images. please wait for a while.\n');

imgDir{1} = 'stim/cat01/';
imgDir{2} = 'stim/cat02/';

t = 0;
for ii=1:2
    Files = dir(strcat(imgDir{ii},'*.png'));
    p.nImg(ii)=length(Files);
    
    for jj=1:p.nImg(ii)
        t=t+1;
        if mod(t,50)==0
            fprintf('.\n');
        else
            fprintf('.');
        end
        p.stim.imgname{ii,jj} = strcat(imgDir{ii},Files(jj).name);
        
    end % for jj
end

return


function pixel = func_pixelPerDegree(va,sess)

if sess == 2 % fMRI setting
    mon_width = 42.6;%モニタサイズ（単位：センチ）モニタ横の長さ
    v_dist=90;%視距離（単位：センチ)
    screenRect=[0 0 1920 1080];
else
    mon_width = 44.5;%モニタサイズ（単位：センチ）モニタ横の長さ
    v_dist=57;%視距離（単位：センチ)
    screenRect=[0 0 1280 768];
end

%視角1度あたりのピクセル数
ppd...
    = pi * (screenRect(3)-screenRect(1)) / atan(mon_width/v_dist/2) / 360;
pixel = round(ppd*va);
return

