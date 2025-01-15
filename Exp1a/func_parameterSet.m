function p = func_parameterSet

%	Display
% -----------------------
p.displaySize = [800 800];
p.x0 = p.displaySize(1)/2;
p.y0 = p.displaySize(2)/2;


%	Stimuli
% -----------------------
p.itemSize = func_pixelPerDegree(8);
p.fixSize = func_pixelPerDegree([1 1]);
p.pointerSize = [30 30];

%	Experimental design
% -----------------------
p.nRepeatSet = 48;
p.nSetFrame = 3;

p.nLearningBlock = 10;
p.nFamiliarityBlock = 1;

p.nLearningTrial...
    = p.nRepeatSet * p.nLearningBlock;
p.nFamiliarityTrial = p.nRepeatSet/2;

p.nRestTrial...
    = p.nRepeatSet*2;



%	timing (in sec)
% ++++++++++++++++++++++++++
p.itiDur = 0;
p.fixDur = 0.75;
p.blankDur = 0;

p.learnStimDur = 0.75;
p.learnSOA = 1.5;


%	key
% ++++++++++++++++++++++++++
p.keyRight = KbName('RightArrow');
p.keyLeft = KbName('LeftArrow');
p.keySpace = KbName('Space');
% p.keySpace = KbName('DownArrow');
p.keyEscape = KbName('Escape');
p.keyZ = KbName('z');


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


function pixel = func_pixelPerDegree(va)

mon_width = 44.5;%モニタサイズ（単位：センチ）モニタ横の長さ
v_dist=57;%視距離（単位：センチ)
screenRect=[0 0 1280 768];

%視角1度あたりのピクセル数
ppd...
    = pi * (screenRect(3)-screenRect(1)) / atan(mon_width/v_dist/2) / 360;
pixel = round(ppd*va);
return

