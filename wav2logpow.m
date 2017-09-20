% by Lee-Min Lee

function [logpow,frame_no]=wav2logpow(speech_raw,fs,frame_size_sec,frame_shift_sec)
  len=length(speech_raw);
  %pre-emphasis
  
  frame_size=round(fs*frame_size_sec);
  frame_shift=round(fs*frame_shift_sec);
  frame_no= floor( 1 + (len - frame_size)/frame_shift );
  

  %hamming window
  k=(1:frame_size)';
  h=0.54-0.46*cos(2*pi*(k-1)/(frame_size-1));
   
  logpow=-inf*ones(1,frame_no);
  
  for fr=1:frame_no
     % extract the i-th frame of the speech
     s=speech_raw((fr-1)*frame_shift+1:(fr-1)*frame_shift+frame_size);
     
     % hamming-windowing
     % s=s.*h;
     
     logpow(fr)=log(s'*s); 
  end

 