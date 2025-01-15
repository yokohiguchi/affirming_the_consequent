function [p,w] = func_initializeScreens(p)

	%	check display setting
	% ++++++++++++++++++++++++++
	Screen('Preference', 'SuppressAllWarnings', 1);
 	screens=Screen('Screens');
    p.screenID=max(screens);
  	p.screenID = 0;
    
    % The color depth should usually not be set to anything else than its default
    % of 32 bpp or 24 bpp. Other settings can impair alpha-blending on some systems,
    % a setting of 16 bpp will disable alpha-blending
%     Screen('Resolution', p.screenID,[],[],[],32); 
    
	
% 		screenResolution = Screen('Resolution',p.screenID);
% 		if screenResolution.width < p.displaySize(1) ...
% 				|| screenResolution.height < p.displaySize(2)
% 			error('error: not enough screen resolution.')
% 		end

	% Open a fullscreen, onscreen window with gray background. Enable 32bpc
	% floating point framebuffer via imaging pipeline on it, if this is possible
	% on your hardware while alpha-blending is enabled. Otherwise use a 16bpc
	% precision framebuffer together with alpha-blending. We need alpha-blending
	% here to implement the nice superposition of overlapping gabors. The demo will
	% abort if your graphics hardware is not capable of any of this.
	PsychImaging('PrepareConfiguration');
 	PsychImaging('AddTask', 'General', 'FloatingPoint32BitIfPossible');
	[w,p.screenRect] = PsychImaging('OpenWindow', p.screenID, p.bgColor);

	
	% Enable alpha-blending, set it to a blend equation useable for linear
	% superposition with alpha-weighted source. This allows to linearly
	% superimpose gabor patches in the mathematically correct manner, should
	% they overlap. Alpha-weighted source means: The 'globalAlpha' parameter in
	% the 'DrawTextures' can be used to modulate the intensity of each pixel of
	% the drawn patch before it is superimposed to the framebuffer image, ie.,
	% it allows to specify a global per-patch contrast value:
	Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE);	
%     Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

%	get screen size
	% ++++++++++++++++++++++++++
	[p.sx0,p.sy0] = RectCenter(p.screenRect);
% 	p.displayRect = CenterRect([0 0 p.displaySize],p.screenRect);

	%	text settings
	% ++++++++++++++++++++++++++
	Screen('TextSize',w, 32);
% 	allFonts = FontInfo('Fonts');
% 	foundfont = 0;
% 	for idx = 1:length(allFonts)
% 		if strcmpi(allFonts(idx).name, 'Hiragino Maru Gothic Pro W4')
% 			foundfont = 1;
% 			break;
% 		end
% 	end
% 	if ~foundfont
% 		error('Could not find wanted japanese font on OS/X !');
% 	end
% 	Screen('TextFont',w,allFonts(idx).number);
    Screen('TextFont',w,'Hiragino Maru Gothic Pro W4');
%     Screen('TextFont',w,'MS Gothic');
	clear allFonts foundfont idx;	
	
	% load texts
	p.txt.pracStart = func_loadUnicodeText('mes/pracStart.txt');
	p.txt.exposeStart = func_loadUnicodeText('mes/exposeStart.txt');
	p.txt.exposeFinish =  func_loadUnicodeText('mes/exposeFinish.txt');
 	p.txt.callSomeone = func_loadUnicodeText('mes/callSomeone.txt');
 	p.txt.recogStart = func_loadUnicodeText('mes/recogStart.txt');
    p.txt.recogMes = func_loadUnicodeText('mes/recogMes.txt');
	p.txt.expFinish = func_loadUnicodeText('mes/expFinish.txt');
    p.txt.rest = func_loadUnicodeText('mes/rest.txt');
    p.txt.key = func_loadUnicodeText('mes/key.txt');
    p.txt.confidence = func_loadUnicodeText('mes/confidence.txt');
    p.txt.high = func_loadUnicodeText('mes/high.txt');
    p.txt.low = func_loadUnicodeText('mes/low.txt');

	%	priority
	% ++++++++++++++++++++++++++
	priorityLevel=MaxPriority(w);
	Priority(priorityLevel);      
	
	
return
	

function out = func_loadUnicodeText(filename)

	fid = fopen(filename, 'r', 'n','Shift_JIS');
	mes = native2unicode(fread(fid),'Shift_JIS'); %#ok<N2UNI>
	out = double(transpose(mes));
	fclose(fid);

return
