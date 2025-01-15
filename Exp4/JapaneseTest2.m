% Windowsではコントロールパネルからフォントを確認できます。
% Macではアプリケーション → Font Bookから、フォントを確認できます。
function JapaneseTest2
AssertOpenGL;
ListenChar(2);
%myKeyCheck;
try
  screenNumber=max(Screen('Screens'));
  [windowPtr, rect]=Screen('OpenWindow', screenNumber);
   

  % 実験環境によって文字列をdoubleでくくる必要がある場合とない場合があります。
  % 私の確認したところ、次のような結果でした。
  %  strFlag = 0; % doubleあり：Matlab(Mac), Matlab(Win) 
  %  strFlag = 1; % doubleなし：Matlab(Windows), Octave(Linux), Octave(Mac), Octave(Win)

  strFlag = 0;
  if strFlag == 1
    myText = 'TEST:日本語のテスト';
  else
    myText = double('TEST:日本語のテスト');
  end;
  
  % OSによってフォントの設定方法が異なります。
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
  
  % フォントサイズの設定
  Screen('TextSize', windowPtr, 30);
  
  % DrawTextを使って (x, y) = (100, 100) に描画
  Screen('DrawText', windowPtr, myText, 100, 100);
  
  % 多機能なDrawFormattedTextを使って、画面の中央に描画
  DrawFormattedText(windowPtr, myText, 'center', 'center', [0 0 0]);
   
  Screen('Flip', windowPtr);
  
  %キー入力を待つ
  KbWait;
   
  sca;
  ListenChar(0);
catch
  sca;
  ListenChar(0);
  psychrethrow(psychlasterror);
end