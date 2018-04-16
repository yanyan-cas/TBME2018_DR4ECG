function output = preprocessing(datasetName, X)
    % this func mostly focus on the preprocessing of data
    % modofied from the code of Xin-Bin Qin
    len = length(X);
    frequency = 360;

    sample = struct('DATA', {},'LABEL',{});
    output = repmat(sample,  len, 1); 
    
 for i = 1 : len
     switch datasetName
         case 'MITBIH_LT'
                % resample the second database to 360
            data = resample(X(i).M(:,1),360,128);     
         case  'PICTArrhythmia'
            data = resample(X(i).M(:,1),360, 257);
         otherwise
             data = X(i).M(:,1);
     end
     
data = dataFilter(data,frequency); % butter high pass filter 
norm_data = normalize(data);        % normalize the data to [0,1]
Rtime = round(frequency * X(i).ATRTIME(4:size(X(i).ATRTIME,1)-1,1));
annot = X(i).ANNOT(4:size(X(i).ANNOT,1)-1,1);
[frm_annot, filter_time] = annotFilter(annot, Rtime); % remove the labels not used
       
    %wave = [];
    
    output(i).DATA = zeros(size(filter_time,1) - 2, 340);
    % FOR MITBHI_ARRHYTHMIA data set, each of the 48 records is slightly over 
    % 30 minutes long and 650000 samples
    % according to our count, There are 112551 annotations,so that each beat has
    % about 277 samples. To get more information ,We aloud part of overlap and 
    % define a window with length of 340 data points(the R peak of the wave is
    % located at 141th point)
    for j = 2 : size(filter_time,1)-1   % split data to windows
                pos_time = filter_time(j+1) - filter_time(j);
                pre_time = filter_time(j) - filter_time(j - 1);
                    if  pos_time < 300 || pre_time < 280
                        tmp = adaptWindows(filter_time(j),pre_time,pos_time,norm_data);
                    else
                        tmp = norm_data(filter_time(j)-140 : filter_time(j)+199,1);
                    end
                output(i).DATA(j-1, :) = tmp;    
               % wave = [wave, tmp];       
    end
    %wdata = [wdata, wave];
    output(i).LABEL = frm_annot(2: end-1);          
 end
 
 %ouput.data = wdata;
% output.labels = labels;
end


