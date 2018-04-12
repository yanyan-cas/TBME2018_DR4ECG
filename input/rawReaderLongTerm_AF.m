function [ M,ANNOT,AFANNOT,ATRTIME,AFATRTIME ] = rawreaderLongTerm_AF( filename )
%LT_READER Summary of this function goes here
%   Detailed explanation goes here
%filename
%M--samples
%TIME--samples occur time
%ANNOT--annotation
%ATRTIME--

PATH = '../LT_AF';
filename = char(filename);
HEADERFILE= strcat(filename,'.hea');    % .hea
ATRFILE= strcat(filename,'.atr');       % .atr
DATAFILE=strcat(filename,'.dat');       % .dat

%% deal with .hea file
heaPath = fullfile(PATH, HEADERFILE);
hea_file =fopen(heaPath,'r');
line = fgetl(hea_file);
A = sscanf(line, '%*s %d %d %d',[1,3]);
channel = A(1);
frequency = A(2);
SAMPLENUM = A(3);          %2*SAMPLENUM
fclose(hea_file);

%% deal with .atr file
dataPath = fullfile(PATH, DATAFILE);             % '212'
data_file = fopen(dataPath,'r');
A = fread(data_file, [4, SAMPLENUM], 'uint8')';  % matrix with 4 columns, each 8 bits long, = 2*12bit
fclose(data_file);
MR2H = bitshift(A(:,2), 8);        
MR4H = bitshift(A(:,4), 8);   
PRL = bitshift(bitand(A(:,2),128),9);              % sign-bit
PRR = bitshift(bitand(A(:,4),128),9);            % sign-bit
M( : , 1) = A(:,1)+MR2H-PRL;
M( : , 2) = A(:,3)+MR4H-PRR;
M( : , 1) = (M( : , 1)) / 200;
M( : , 2) = (M( : , 2)) / 200;

%% deal with .atr file
atrPath = fullfile(PATH, ATRFILE);  % attribute file with annotation data
atr_file = fopen(atrPath,'r');
A = fread(atr_file, [2, inf], 'uint8')';
fclose(atr_file);
ATRTIME = [];
ANNOT = [];
AF_index = [];
AFANNOT = [];
saa = size(A,1);
i = 1;
while i <= saa
    annoth = bitshift(A(i,2),-2);
    if annoth == 59
        ANNOT = [ANNOT;bitshift(A(i+3,2),-2)];
        ATRTIME=[ATRTIME;A(i+2,1)+bitshift(A(i+2,2),8)+...
                bitshift(A(i+1,1),16)+bitshift(A(i+1,2),24)];
        if bitshift(A(i+3,2),-2)==28 
            if A(i+5,2)==65 && A(i+6,2)==73
                AFANNOT=[AFANNOT;1];
                AF_index=[AF_index;numel(ATRTIME)];
            else
                AFANNOT=[AFANNOT;0];
                AF_index=[AF_index;numel(ATRTIME)];
            end
        end
        i=i+3;
    elseif annoth==60
        % nothing to do
    elseif annoth==61
        % nothing to do
    elseif annoth==62
        % nothing to do
    elseif annoth==63
        hilfe=bitshift(bitand(A(i,2),3),8)+A(i,1);
        hilfe=hilfe+mod(hilfe,2);
        i=i+hilfe/2;
    else
        ATRTIME=[ATRTIME;bitshift(bitand(A(i,2),3),8)+A(i,1)];
        ANNOT=[ANNOT;bitshift(A(i,2),-2)];
        if bitshift(A(i,2),-2)==28
            if A(i+2,2)==65 && A(i+3,2)==73
                AFANNOT=[AFANNOT;1];
                AF_index=[AF_index;numel(ATRTIME)];
            else
                AFANNOT=[AFANNOT;0];
                AF_index=[AF_index;numel(ATRTIME)];
            end
        end
   end;
   i=i+1;
end;
ANNOT(length(ANNOT)) = [];       % last line = EOF (=0)
ATRTIME(length(ATRTIME)) = [];   % last line = EOF
ATRTIME= (cumsum(ATRTIME)) ;
AFATRTIME = ATRTIME(AF_index);
end

