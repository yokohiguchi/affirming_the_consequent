function KeyN = GetKeyNum

%%% エラー回避のために使いたいキーボードが取得できない時のエラー回避 %%%
KeyN=0;
AppKey='Apple Internal Keyboard / Trackpad'; % Macのキーボードなどの名前

%%% 使いたいキーボードの名前 %%%
UseKey='932';

devices=PsychHID('Devices'); % 接続されているデバイスを確認する
for di=1:length(devices)
    d=devices(di);
    s=sprintf('device %d: %s, %s, %s',di,d.usageName,d.manufacturer,d.product);
    s=sprintf('%s, %d inputs, %d outputs',s,d.inputs,d.outputs);
    if (strcmpi(d.product,AppKey)) && (strcmpi(d.usageName,'Keyboard'))
        apple_key=di;
    end
    if (strcmpi(d.product,UseKey)) && (strcmpi(d.usageName,'Keyboard'))
        KeyN=di;
    end
    if ~isempty(d.serialNumber)
        s=sprintf('%s, serialNumber %s',s,d.serialNumber);
    end
    fprintf('%s\n',s);
end
if (KeyN==0) % 使いたいキーボードが見つからなかった時のエラー回避
    KeyN=apple_key;
end
return