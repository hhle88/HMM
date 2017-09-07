% by Lee-Min Lee

function feature_seq=fwav2mfcc_e_d_a(infilename,outfilename,outfile_format,frame_size_sec,frame_shift_sec,use_hamming,pre_emp,bank_no,cep_order,lifter,delta_win_weight)
  [speech_raw, fs, bit_res]=audioread(infilename,'native');
%    [speech_raw, fs, bit_res]=wavread(infilename,'native');
  speech_raw=double(speech_raw);

  feature_seq=wav2mfcc_e_d_a(speech_raw,fs,frame_size_sec,frame_shift_sec,use_hamming,pre_emp,bank_no,cep_order,lifter,delta_win_weight);
  
  [dim frame_no]=size(feature_seq);
  
  switch lower(outfile_format)
      case 'htk' % write htk header, big endian
          fout=fopen(outfilename,'w','b'); % 'n'==local machine format 'b'==big endian 'l'==little endian
          fwrite(fout,frame_no,'int32');
          sampPeriod=round(frame_shift_sec*1E7);    
          fwrite(fout,sampPeriod,'int32');
          sampSize=dim*4;   
          fwrite(fout,sampSize,'int16');
          parmKind=838; % parameter kind code: MFCC=6, _E=64, _D=256, _A=512, MFCC_E_D_A=6+64+256+512=838
          fwrite(fout,parmKind,'int16');  
      case 'b' %big endian  
          fout=fopen(outfilename,'w','b'); 
      case 'ieee-be' %big endian  
          fout=fopen(outfilename,'w','b');     
      case 'l' %little endian  
          fout=fopen(outfilename,'w','l'); 
      case 'ieee-le' %little endian  
          fout=fopen(outfilename,'w','l');          
      otherwise % no header
          fout=fopen(outfilename,'w','n'); % 'n'==local machine format 'b'==big endian 'l'==little endian
  end
  
  % write data
  fwrite(fout, feature_seq,'float32');
  
  fclose(fout);

  
 
  