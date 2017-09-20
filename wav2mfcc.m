% by Lee-Min Lee

function [mfcc,frame_no]=wav2mfcc(speech_raw,fs,frame_size_sec,frame_shift_sec,use_hamming,pre_emp,bank_no,cep_order,lifter)
len=length(speech_raw);
%pre-emphasis
speech=zeros(len,1);
speech(1)=speech_raw(1);
speech(2:end)=speech_raw(2:end)-pre_emp*speech_raw(1:end-1);

frame_size=round(fs*frame_size_sec);
frame_shift=round(fs*frame_shift_sec);
frame_no= floor( 1 + (len - frame_size)/frame_shift );

% Mel scale filter bank
max_mf = 2595*log10(1 + 0.5*fs/700.0);
delta_mf=max_mf/(bank_no+1);
f=zeros(bank_no+2,1);
for m=1:bank_no+2
    f(m)=(10^((m-1)*delta_mf/2595)-1)*700.0;
end
mfcc_tran=zeros(cep_order,bank_no);
for k=1:cep_order
    for m=1:bank_no
        mfcc_tran(k,m)=sqrt(2/bank_no)*cos(k*pi/bank_no * (m-0.5));
    end
end

%lifter weighting
n=(1:cep_order)';
lifter_weighting=1+(lifter/2)*sin(pi*n/lifter);

%hamming window
k=(1:frame_size)';
h=0.54-0.46*cos(2*pi*(k-1)/(frame_size-1));

mfcc=zeros(cep_order,frame_no);

melspec=zeros(bank_no,frame_no);
for fr=1:frame_no
    % extract the i-th frame of the speech
    s=speech((fr-1)*frame_shift+1:(fr-1)*frame_shift+frame_size);

    % hamming-windowing
    if use_hamming ~= 0
        s=s.*h;
    end
    % calculate the filter bank power
    fftN=2;
    while fftN<frame_size
        fftN=fftN*2;
    end
    PowerSpec=abs(fft(s,fftN));
    % PowerSpec=abs(fft(s));
    mel_power=zeros(bank_no,1);
    for m=1:bank_no
        kmin=f(m)/fs*fftN +1;   % Matlab convention
        kcen=f(m+1)/fs*fftN +1; % Matlab convention
        kmax=f(m+2)/fs*fftN +1; % Matlab convention
        for k=ceil(kmin):floor(kmax)
            mel_k=2595*log10(1 + (k-1)/fftN*fs/700.0);
            if k < kcen
                mel_power(m) = mel_power(m) + PowerSpec(k)*(mel_k-(m-1)*delta_mf)/delta_mf;
            else
                mel_power(m) = mel_power(m) + PowerSpec(k)*(1 - (mel_k-delta_mf*(m))/delta_mf);
            end
        end     
    end

    % inverse cosine transform
    mfcc(:,fr)=mfcc_tran*log(mel_power);

    %liftering
    mfcc(:,fr)=lifter_weighting.*mfcc(:,fr);

end

