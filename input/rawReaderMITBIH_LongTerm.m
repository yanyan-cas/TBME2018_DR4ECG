function [M,TIME,ANNOT,ATRTIME] = rawReaderMITBIH_LongTerm( filename )



 %read the data and annotation of MIT_BIH_LongTerm.
%filename '14046';'14134';'14149';'14157';'14172';'14184';'15814'....
%M--samples
%TIME--samples occur time
%ANNOT--annotation
%ATRTIME--

% About the format, consider the explaintation of WFDB Application guide in 
% https://physionet.org/physiotools/wag/signal-5.htm
% Format 212: Each sample is represented by a 12-bit two’s complement amplitude.
% The first sample is obtained from the 12 least significant bits of the 
% first byte pair (stored least significant byte first). 
% The second sample is formed from the 4 remaining bits of the
% first byte pair (which are the 4 high bits of the 12-bit sample) 
% and the next byte (which contains the remaining 8 bits of the second sample). 
% The process is repeated for each successive pair of samples. 
% Most of the signal files in PhysioBank are written in format 212.


filename = char(filename);
PATH = '/Users/Yanyan/Documents/MATLAB/DATASET/ECG_DATASET/MITBIH_LongTerm';
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
code_format = zeros(1, 3);
gain = zeros(1, 3);
valid_bit =  zeros(1, 3);
zero_line = zeros(1, 3);
firstvalue = zeros(1, 3);

for k = 1 : channel           
    line = fgetl(hea_file);
    A = sscanf(line, '%*s %d %d %d %d %d',[1,5]);
    code_format(k) = A(1);          
    gain(k) = 200;  % if this value is 0, then default set as 200          
    valid_bit(k) = A(3);          
    zero_line(k) = A(4);      
    firstvalue(k) = A(5);
end

fclose(hea_file);

if filename == '15814'
         if any(code_format ~= 310)
            error('binary formats different to 212, try modify the code for another format!');
         else
             %% deal with .dat file in format '310'
                dataPath = fullfile(PATH, DATAFILE);   % deal with the format '212'
                data_file = fopen(dataPath,'r');
                % matrix with 4 rows, each 10 bits long, = 3 * 10bit + 2<- 4 * 8 bits
                A = fread(data_file, [4, SAMPLENUM], 'uint8')';  
                fclose(data_file);

                temp2 = bitand(A(:, 2), 7);
                temp3 = bitshift(temp2, 8) + A(:, 1);
                temp4 = bitshift(temp3, -1);
                signFirst = bitshift(bitand(temp4, 512), 1);
                M(:, 1) = temp4 - signFirst;

                temp2 = bitand(A(:, 4), 7);
                temp3 = bitshift(temp2, 8) + A(:, 3);
                temp4 = bitshift(temp3, -1);
                signSecond = bitshift(bitand(temp4, 512), 1);
                M(:, 2) = temp4 - signSecond;

                temp1 =  bitshift(A(:, 2), -3);
                temp2 = bitand(temp1, 31);
                temp3 = bitshift(A(:, 4), -3);
                temp4 = bitand(temp3, 31);
                temp5 = bitshift(temp4, 5) + temp2;
                signThird = bitshift(bitand(temp5, 512), 1);
                M(:, 3) = temp5 - signThird;

                if M(1,:) ~= firstvalue(1:3)
                    error('inconsistency in the first bit values');
                end

                M( : , 1) = (M( : , 1) - zero_line(1)) / gain(1);
                M( : , 2) = (M( : , 2) - zero_line(2)) / gain(2);
                M( : , 3) = (M( : , 3) - zero_line(3)) / gain(3);
                TIME = (0:(SAMPLENUM-1)) / frequency;
                TIME = TIME';

         end
         
         
else
        if any(code_format(1, 1:2) ~= 212)
            error('binary formats different to 212, try modify the code for another format!');
        else
        
          %% deal with .dat file in '212'
        dataPath = fullfile(PATH, DATAFILE);   % deal with the format '212'
        data_file = fopen(dataPath,'r');
        A = fread(data_file, [3, SAMPLENUM], 'uint8')';  % matrix with 3 rows, each 8 bits long, = 2*12bit <- 3 * 8 bits
        fclose(data_file);
        Ml2H = bitshift(A(:,2), -4);        %move right for 4
        Ml1H = bitand(A(:,2), 15);     %get the least significant 4 pos, for each sampe 12bits, the first is the sign?
        PRL = bitshift(bitand(A(:,2),8),9);              % sign-bit
        PRR = bitshift(bitand(A(:,2),128),5);            % sign-bit
        M( : , 1) = bitshift(Ml1H,8)+ A(:,1)-PRL;
        M( : , 2) = bitshift(Ml2H,8)+ A(:,3)-PRR;

        if M(1,:) ~= firstvalue(1:2)
            error('inconsistency in the first bit values');
        end

        M( : , 1) = (M( : , 1) - zero_line(1)) / gain(1);
        M( : , 2) = (M( : , 2) - zero_line(2)) / gain(2);
        TIME = (0:(SAMPLENUM-1)) / frequency;
        TIME = TIME';
        end
end




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