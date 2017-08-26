function generate_trainingfile_list
clear trainingfile_list.mat;
training_file_list = 'trainingfile_list.mat';
fea_dir = 'mfcc';
k = 0;
for PHASE = 1:6
    for MODEL = 0:9
        for spk = 1:2:99
            k = k + 1;
            trainingfile{k,1} = MODEL+1;
            trainingfile{k,2} = sprintf('%s\\S%d\\%02d_%02d.mfc',fea_dir,PHASE,spk,MODEL);
        end
    end
end
save(training_file_list, 'trainingfile');
end