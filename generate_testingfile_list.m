function generate_testingfile_list
clear testingfile_list.mat;
testing_file_list = 'testingfile_list.mat';
fea_dir = 'mfcc';
k = 0;
for PHASE = 1:6
    for MODEL = 0:9
        for spk = 0:2:98
            k = k + 1;
            testingfile{k,1} = MODEL+1;
            testingfile{k,2} = sprintf('%s\\S%d\\%02d_%02d.mfc',fea_dir,PHASE,spk,MODEL);
        end
    end
end
save(testing_file_list, 'testingfile');
end