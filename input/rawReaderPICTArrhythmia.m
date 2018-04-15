function  [M,TIME,ANNOT,ATRTIME]  = rawReaderPICTArrhythmia(filename)
%read the data and annotation of MIT_BIH.
%M--samples
%TIME--samples occur time
%ANNOT--annotation
%ATRTIME--

%  algorithm is based on a program written by
%  Klaus Rheinberger (University of Innsbruck)

filename = char(filename);
PATH = '/Users/Yanyan/Documents/MATLAB/DATASET/ECG_DATASET/PICT12LEAD_Arrhythmia';
HEADERFILE= strcat(filename,'.hea.txt');      % .hea
ATRFILE= strcat(filename,'.atr');         % .atr
DATAFILE=strcat(filename,'.dat');         % .dat

%% deal with .hea file
heaPath = fullfile(PATH, HEADERFILE);
hea_file =fopen(heaPath,'r');
line = fgetl(hea_file);
A = sscanf(line, '%*s %d %d %d',[1,3]);
channel = A(1);
frequency = A(2);
SAMPLENUM = A(3);          %2*SAMPLENUM

code_format = zeros(1, 12);
gain = zeros(1, 12);
valid_bit =  zeros(1, 12);
zero_line = zeros(1, 12);
firstvalue = zeros(1, 12);

for k = 1 : channel           
    line = fgetl(hea_file);
    A = sscanf(line, '%*s %d %d %d %d %d',[1,5]);
    code_format(k) = A(1);          
    gain(k) = A(2);            
    valid_bit(k) = A(3);          
    zero_line(k) = A(4);      
    firstvalue(k) = A(5);
end
fclose(hea_file);

  if any(code_format(1:12) ~= 16)
            error('binary formats different to 16, try modify the code for another format!');
  end

%% deal with .dat file
dataPath = fullfile(PATH, DATAFILE);             % '212'
data_file = fopen(dataPath,'r');
A = fread(data_file, [24, SAMPLENUM], 'uint8')';  % matrix with 3 rows, each 8 bits long, = 2*12bit
fclose(data_file);

% for i = 1 : 12
%     M( :, i) = bitshift(A(:, 2*i), 8) + A(:, 1) - bitshift(bitand(A(:,2*i),128),9);
% end
M( :, 1) = bitshift(A(:, 2), 8) + A(:, 1) - bitshift(bitand(A(:,2),128),9);
M( :, 2) = bitshift(A(:, 4), 8) + A(:, 3) - bitshift(bitand(A(:,4),128),9);
M( :, 3) = bitshift(A(:, 6), 8) + A(:, 5) - bitshift(bitand(A(:,6),128),9);
M( :, 4) = bitshift(A(:, 8), 8) + A(:, 7) - bitshift(bitand(A(:,8),128),9);
M( :, 5) = bitshift(A(:, 10), 8) + A(:, 9) - bitshift(bitand(A(:,10),128),9);
M( :, 6) = bitshift(A(:, 12), 8) + A(:, 11) - bitshift(bitand(A(:,12),128),9);
M( :, 7) = bitshift(A(:, 14), 8) + A(:, 13) - bitshift(bitand(A(:,14),128),9);
M( :, 8) = bitshift(A(:, 16), 8) + A(:, 15) - bitshift(bitand(A(:,16),128),9);
M( :, 9) = bitshift(A(:, 18), 8) + A(:, 17) - bitshift(bitand(A(:,18),128),9);
M( :, 10) = bitshift(A(:, 20), 8) + A(:, 19) - bitshift(bitand(A(:,20),128),9);
M( :, 11) = bitshift(A(:, 22), 8) + A(:, 21) - bitshift(bitand(A(:,22),128),9);
M( :, 12) = bitshift(A(:, 24), 8) + A(:, 23) - bitshift(bitand(A(:,24),128),9);

if M(1,:) ~= firstvalue
    error('inconsistency in the first bit values');
end

for i = 1 : 12
    M( : , i) = (M( : , i) - zero_line(i)) / gain(i);
end

TIME = (0:(SAMPLENUM-1)) / frequency;
TIME = TIME';

%% deal with .atr file
atrPath = fullfile(PATH, ATRFILE);  % attribute file with annotation data
atr_file = fopen(atrPath,'r');
A = fread(atr_file, [2, inf], 'uint8')';
fclose(atr_file);
ATRTIME = [];
ANNOT = [];
saa = size(A,1);
i = 1;
while i <= saa
    annoth = bitshift(A(i,2),-2);
    if annoth == 59
        ANNOT = [ANNOT;bitshift(A(i+3,2),-2)];
        ATRTIME=[ATRTIME;A(i+2,1)+bitshift(A(i+2,2),8)+...
                bitshift(A(i+1,1),16)+bitshift(A(i+1,2),24)];
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
    end
   i=i+1;
end
ANNOT(length(ANNOT)) = [];       % last line = EOF (=0)
ATRTIME(length(ATRTIME)) = [];   % last line = EOF
ATRTIME= (cumsum(ATRTIME)) / frequency;

end