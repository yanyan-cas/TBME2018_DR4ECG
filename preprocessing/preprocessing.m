function output = preprocessing( dataName, X)
    % this func mostly focus on the preprocessing of data
    % modofied from the code of Xin-Bin Qin
    [m1, n1] = size(X.M);
    [m2, n2] = size(X.TIME);
    [m3, n1] = size(X.);
    [m1, n1] = size(X.M);
    
    
     switch datasetName
        case 'MITBIH_Arrhythmia'
             disp('preprocessing X for dataset MITBIH_Arrhythmia, please wait ...');
         
   %%================== 
        case  'MITBIH_LT'   
            disp('preprocessing X for dataset MITBIH_LongTerm, please wait ...');
    
    %%==================
        case 'PICTArrhythmia'
                disp('preprocessing X for dataset PICT12LEAD_Arrhythmia_MAT, please wait ...');
    
          %%==================  
        otherwise
            disp('error,  dataset unrecognized ...');
    end
    
    
    
    
    
    data = data_filter(data,frequency); % butter high pass filter 
    norm_data = normalize(data);        % normalize the data to [0,1]
    Rtime = round(frequency * ATRTIME(4:size(ATRTIME,1)-1,1));
    annot = ANNOT(4:size(ANNOT,1)-1,1);
    [frm_annot,filter_time] = annot_filter(annot,Rtime); % remove the labels not used
    for j = 2 : size(filter_time,1)-1   % split data to windows
        tmp = zeros(340,1);
        pos_time = filter_time(j+1) - filter_time(j);
        pre_time = filter_time(j) - filter_time(j - 1);
        if  pos_time < 300 || pre_time < 280
            tmp = adaptWind(filter_time(j),pre_time,pos_time,norm_data);
        else
            tmp = norm_data(filter_time(j)-140 : filter_time(j)+199,1);
        end
        wave = [wave,tmp];       
    end
    wdata = [wdata, wave];
    labels = [labels,frm_annot(2:end-1)'];
end


