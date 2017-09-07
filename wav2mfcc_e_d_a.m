% by Lee-Min Lee

function feature_seq=wav2mfcc_e_d_a(speech_raw,fs,frame_size_sec,frame_shift_sec,use_hamming,pre_emp,bank_no,cep_order,lifter,delta_win_weight)
   mfcc=wav2mfcc(speech_raw,fs,frame_size_sec,frame_shift_sec,use_hamming,pre_emp,bank_no,cep_order,lifter);
   logpow=wav2logpow(speech_raw,fs,frame_size_sec,frame_shift_sec);
   d_fea=(0.01/frame_shift_sec)*slope([mfcc;logpow],delta_win_weight); % in unit of 10ms
   dd_fea=(0.01/frame_shift_sec)*slope(d_fea,delta_win_weight); % in unit of 10ms
   feature_seq=[mfcc;logpow;d_fea;dd_fea];

  