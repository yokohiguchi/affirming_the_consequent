function [p,d] = func_subjectInfo(p,d)

	clc;
	commandwindow;

	%   input
	% ++++++++++++++++++++++++++
	d.subjectName = input('name? :  ', 's');

	if isempty(d.subjectName)
		p.prac=1;
		d.subjecgAge=20;
		d.subjectSex='f';
		d.dataFileName='practice';

	else
		p.prac=0;
		d.subjecgAge=input('age :  ');
		d.subjectSex=input('male or female :  ','s');
		d.dataFileName=[d.exposeStartTime(3:13) '_' d.subjectName] ;
	end

return