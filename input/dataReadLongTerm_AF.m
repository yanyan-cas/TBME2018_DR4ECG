folder = '../LT_AF/';
target_folder = '../LT_AF_mat';
% scan all the .dat file
path = strcat(folder,'*.dat');
files = dir(path);
len = length(files);
%  Datafiles = cell(len,1);
data = [];
frequency = 128; % sampling frequency
for i = 1 : len
    % str = regexp(files(1).name,'.','split');
    [PATHSTR,NAME,EXT] = fileparts(files(i).name);
    fprintf('Parse the file: %s ... \n', NAME);
    marfile = strcat(NAME,'.mat');
    marfile = fullfile(target_folder,marfile);
     % Datafiles{i} = NAME;
    [ M,AFANNOT,ANNOT,AFATRTIME,ATRTIME ] = readerLongTerm_AF( NAME );  % read the '212' format data
    save(marfile,'M','ANNOT','ATRTIME');    
end