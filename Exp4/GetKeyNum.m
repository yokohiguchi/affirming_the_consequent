function KeyN = GetKeyNum

%%% �G���[����̂��߂Ɏg�������L�[�{�[�h���擾�ł��Ȃ����̃G���[��� %%%
KeyN=0;
AppKey='Apple Internal Keyboard / Trackpad'; % Mac�̃L�[�{�[�h�Ȃǂ̖��O

%%% �g�������L�[�{�[�h�̖��O %%%
UseKey='932';

devices=PsychHID('Devices'); % �ڑ�����Ă���f�o�C�X���m�F����
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
if (KeyN==0) % �g�������L�[�{�[�h��������Ȃ��������̃G���[���
    KeyN=apple_key;
end
return