function wav = func_initializeSound

	wav.start = func_wavPreparation('wav/start.wav');
	wav.feedback = func_wavPreparation('wav/tone.wav');
	wav.error = func_wavPreparation('wav/error.wav');
	wav.finish = func_wavPreparation('wav/finish.wav');


return