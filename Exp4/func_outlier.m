function [nOut,newdata] = func_outlier(olddata)
nOut=0; nData = length(olddata);
data = olddata;

%% recursion
	while 1
		maxD = max(data);
		idx = find(data<maxD);

		if isempty(idx)
			break
		end

		mean_except_max = mean(data(idx));
		sd_except_max = std(data(idx));

		if maxD > mean_except_max + (sd_except_max*4)
			data = data(idx);
			nOut = nOut + 1;
		else
			break;
		end
	end

% 	if nOut~=0
% 		fprintf('excluded %d of %d\n',nOut,nData);
% 	end

	newdata = data;

% %% mean+nSD
% idx=find(data<mean(data)+std(data)*3 & data>mean(data)-std(data)*3);
% newdata = data(idx);
% nOut = nData-length(newdata);
% 
% %% cut under 1500ms
% idx=find(data<1.5);
% newdata = data(idx);
% nOut = nData-length(newdata);

return
