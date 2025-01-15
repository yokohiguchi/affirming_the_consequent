% Windows�ł̓R���g���[���p�l������t�H���g���m�F�ł��܂��B
% Mac�ł̓A�v���P�[�V���� �� Font Book����A�t�H���g���m�F�ł��܂��B
function JapaneseTest2
AssertOpenGL;
ListenChar(2);
%myKeyCheck;
try
  screenNumber=max(Screen('Screens'));
  [windowPtr, rect]=Screen('OpenWindow', screenNumber);
   

  % �������ɂ���ĕ������double�ł�����K�v������ꍇ�ƂȂ��ꍇ������܂��B
  % ���̊m�F�����Ƃ���A���̂悤�Ȍ��ʂł����B
  %  strFlag = 0; % double����FMatlab(Mac), Matlab(Win) 
  %  strFlag = 1; % double�Ȃ��FMatlab(Windows), Octave(Linux), Octave(Mac), Octave(Win)

  strFlag = 0;
  if strFlag == 1
    myText = 'TEST:���{��̃e�X�g';
  else
    myText = double('TEST:���{��̃e�X�g');
  end;
  
  % OS�ɂ���ăt�H���g�̐ݒ���@���قȂ�܂��B
  if IsOSX % Mac       
    allFonts = FontInfo('Fonts');
    foundfont = 0;
    for idx = 1:length(allFonts)
        if strcmpi(allFonts(idx).name, 'Hiragino Maru Gothic ProN W4')
            foundfont = 1;
            break;
        end
    end
    if ~foundfont
        error('Could not find wanted japanese font on OS/X !');
    end
    Screen('TextFont', windowPtr, allFonts(idx).number);
  end;
  
  if IsLinux % Linux
      Screen('TextFont', windowPtr, '-:lang=ja');
  end;
  
  if IsWin % Windows
      Screen('TextFont', windowPtr, 'Courier New');
  end;
  
  % �t�H���g�T�C�Y�̐ݒ�
  Screen('TextSize', windowPtr, 30);
  
  % DrawText���g���� (x, y) = (100, 100) �ɕ`��
  Screen('DrawText', windowPtr, myText, 100, 100);
  
  % ���@�\��DrawFormattedText���g���āA��ʂ̒����ɕ`��
  DrawFormattedText(windowPtr, myText, 'center', 'center', [0 0 0]);
   
  Screen('Flip', windowPtr);
  
  %�L�[���͂�҂�
  KbWait;
   
  sca;
  ListenChar(0);
catch
  sca;
  ListenChar(0);
  psychrethrow(psychlasterror);
end