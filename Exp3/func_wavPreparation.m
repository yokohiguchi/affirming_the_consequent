function pa = func_wavPreparation(filename)

		[wav.dat,wav.freq,wav.nBits]=wavread(filename);
		wav.dat = wav.dat';
		wav.nChannel=size(wav.dat,1);
		pa = PsychPortAudio('Open', [], [], 0, wav.freq, wav.nChannel);
		PsychPortAudio('FillBuffer', pa, wav.dat);
		PsychPortAudio('RunMode', pa, 1);

return