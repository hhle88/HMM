function accuracy_rate = HMMtesting(HMM, testing_file_list)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Min-Lee Lee, Hoang-Hiep Le
% EE Department, Dayeh University
% testing for isolated digital models (0, 1,..., 9), version 1 (2017-08-25)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin==0
    load HMM;
    testing_file_list = 'testingfile_list.mat';
end

num_of_model = 10;
num_of_error = 0;
num_of_testing = 0;

load (testing_file_list, 'testingfile');
num_of_uter = size(testingfile,1);

parfor u = 1:num_of_uter
    k = testingfile{u,1}; %%%%%% k: MODEL ID (0, 1, 2,..., 9)
    filename = testingfile{u,2};
    mfcfile = fopen(filename, 'r', 'b' );
    if mfcfile ~= -1
        nSamples = fread(mfcfile, 1, 'int32');
        sampPeriod = fread(mfcfile, 1, 'int32')*1E-7;
        sampSize = fread(mfcfile, 1, 'int16');
        dim = 0.25*sampSize; % dim = 39
        parmKind = fread(mfcfile, 1, 'int16');
        
        features = fread(mfcfile, [dim, nSamples], 'float');
        fclose(mfcfile);
        
        num_of_testing = num_of_testing + 1;
        % predict which the digit is.......
        fopt_max = -Inf; digit = -1;
        for p = 1:num_of_model
            fopt = viterbi_dist_FR(HMM.mean(:,:,p), HMM.var(:,:,p), HMM.Aij(:,:,p), features); % model k_th
            if fopt > fopt_max
                digit = p;
                fopt_max = fopt;
            end
        end
        if digit ~= k % testing
            num_of_error = num_of_error + 1;
        end
    end
end
accuracy_rate = (num_of_testing - num_of_error)*100/num_of_testing;
end