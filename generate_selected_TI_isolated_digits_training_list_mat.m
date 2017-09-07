
list_filename='training_list.mat';
MODEL_NO=11;
dir1='mfcc_e_d_a/isolated_digits_ti_train_endpt';
dir2={'MAN','WOMAN'};
dir3={{'AE','AJ','AL','AW','BD','CB','CF','CR','DL','DN','EH','EL','FC','FD','FF','FI','FJ','FK','FL','GG','GJ','GR','GT','HA','HH','HL','HN','HS','IE','IF','IN','IT','JR','JT','KD','KP','KR'} ,
       {'AC','AG','AI','AN','BH','BI','BR','CA','CG','CL','CM','DC','DG','EA','EC','EE','EG','EI','EK','ES','HG','HP','IG','IH','IL','JC','JI','JJ','JN','JP','KC','KF','KH','KK','KN','KT','LA','LD','LS','MK','MM','MS','MW','NC','NG','NH','PE','PK','PM','PP','RA','RE','RN','RP','RR','RS','SP'}
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
