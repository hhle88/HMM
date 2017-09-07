clear;
list_filename='testing_list.mat';
MODEL_NO=11;
dir1='mfcc_e_d_a/isolated_digits_ti_test_endpt';
dir2={'MAN','WOMAN'};
dir3={{'AH','AR','AT','BC','BE','BM','BN','CC','CE','CP','DF','DJ','ED','EF','ET','FA','FG','FH','FM','FP','FR','FS','FT','GA','GP','GS','GW','HC','HJ','HM','HR','IA','IB','IM','IP','JA','JH','KA','KE','KG','LE','LG','MI','NL','NP','NT','PC','PG','PH','PR','RK','SA','SL','SR','SW','TC'},
      {'AK','AP','BA','BF','BJ','BL','BS','BW','CD','CJ','CS','CT','DP','DR','DW','EJ','EM','EP','ER','EW','FN','GB','GC','GK','GL','GM','GN','HF','ID','II','IW','JD','JE','JW','KB','KJ','LJ','LL','LP','LR','MC','MJ','ML','NA','NK','PF','PJ','PL','PN','PT','RG','RL','RM','SI','SM','SN','TB'}
    }
wordids={'1','2','3','4','5','6','7','8','9','O','Z'};


k=1;
for d2=1:length(dir2)
    for d3=1:length(dir3{d2})
        for w=1:length(wordids)
            for pass='A':'B'
                list{k,1}=w;
                list{k,2}=sprintf('%s/%s/%s/%c%c_endpt.mfc', dir1,dir2{d2},dir3{d2}{d3},wordids{w},pass);
                k=k+1;
            end
        end
    end
end
save(list_filename,'list');
