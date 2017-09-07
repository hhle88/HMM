format compact;clear;

indir='wav';
in_filter='\.[Ww][Aa][Vv]';
outdir='mfcc_e_d_a';
out_ext='.mfc';
outfile_format='htk';% htk format
frame_size_sec = 0.025;
frame_shift_sec= 0.010;
use_hamming=1;
pre_emp=0;
bank_no=26;
cep_order=12;
lifter=22;

delta_win=2;
delta_win_weight = ones(1,2*delta_win+1);

dr_wav2mfcc_e_d_a(indir,in_filter,outdir,out_ext,outfile_format,frame_size_sec,frame_shift_sec,use_hamming,pre_emp,bank_no,cep_order,lifter,delta_win_weight);
