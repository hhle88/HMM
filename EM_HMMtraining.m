function HMM = EM_HMMtraining(training_file_list, DIM, num_of_model, num_of_state)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Min-Lee Lee, Hoang-Hiep Le
% EE Department, Dayeh University
% version 1 (2017-08-25)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin==0
    DIM = 39;
    num_of_model = 10;
    num_of_state = 13; % 13 nodes, and not including START and END node
    training_file_list = 'trainingfile_list.mat';
end

HMM.mean = zeros(DIM, num_of_state, num_of_model);
HMM.var  = zeros(DIM, num_of_state, num_of_model);
HMM.Aij  = zeros(num_of_state+2, num_of_state+2, num_of_model);
% generate initial HMM
HMM = EM_initialization_model(HMM, training_file_list, DIM, num_of_state, num_of_model);

num_of_iteration = 30; % it should be bigger than 10
log_likelihood_iter = zeros(1, num_of_iteration);
likelihood_iter = zeros(1, num_of_iteration);

load (training_file_list, 'trainingfile');
num_of_uter = size(trainingfile,1);

for iter = 1: num_of_iteration
    % reset value of sum_of_features, sum_of_features_square, num_of_feature, num_of_jump
    sum_mean_numerator = zeros(DIM, num_of_state, num_of_model);
    sum_var_numerator = zeros(DIM, num_of_state, num_of_model);
    sum_aij_numerator = zeros(num_of_state, num_of_state, num_of_model);
    sum_denominator = zeros(num_of_state, num_of_model);
    log_likelihood = 0;
    likelihood = 0;
    
    for u = 1:num_of_uter
        
        k = trainingfile{u,1}; % k: MODEL ID (0, 1, 2,..., 9)
        filename = trainingfile{u,2};
        
        mfcfile = fopen(filename, 'r', 'b' );
        if mfcfile ~= -1
            nSamples = fread(mfcfile, 1, 'int32');
            sampPeriod = fread(mfcfile, 1, 'int32')*1E-7;
            sampSize = fread(mfcfile, 1, 'int16');
            dim = 0.25*sampSize; % dim = 39
            parmKind = fread(mfcfile, 1, 'int16');
            
            features = fread(mfcfile, [dim, nSamples], 'float');
            [mean_numerator, var_numerator, aij_numerator, denominator, log_likelihood_i, likelihood_i] =  EM_HMM_FR(HMM.mean(:,:,k), HMM.var(:,:,k), HMM.Aij(:,:,k), features); % model k_th
            
            sum_mean_numerator(:,:,k) = sum_mean_numerator(:,:,k) + mean_numerator(:,2:end-1);
            sum_var_numerator(:,:,k) = sum_var_numerator(:,:,k) + var_numerator(:,2:end-1);
            sum_aij_numerator(:,:,k) = sum_aij_numerator(:,:,k) + aij_numerator(2:end-1,2:end-1);
            sum_denominator(:,k) = sum_denominator(:,k) + denominator(2:end-1);
            
            log_likelihood = log_likelihood + log_likelihood_i;
            likelihood = likelihood + likelihood_i;
            
            fclose(mfcfile);
            
            
        end
    end
    
    % calculate value of means, variances, aij
    for k = 1:num_of_model
        for n = 1:num_of_state
            HMM.mean(:,n,k) = sum_mean_numerator(:,n,k) / sum_denominator (n,k);
            HMM.var (:,n,k) = sum_var_numerator(:,n,k) / sum_denominator (n,k) -  HMM.mean(:,n,k).* HMM.mean(:,n,k);
        end
    end
    for k = 1:num_of_model
        for i = 2:num_of_state+1
            for j = 2:num_of_state+1
                HMM.Aij (i,j,k) = sum_aij_numerator(i-1,j-1,k) / sum_denominator (i-1,k);
            end
        end
        HMM.Aij (num_of_state+1,num_of_state+2,k) = 1 - HMM.Aij (num_of_state+1,num_of_state+1,k);
    end
    HMM.Aij (num_of_state+2,num_of_state+2,k) = 1;
    log_likelihood_iter(iter) = log_likelihood;
    likelihood_iter(iter) = likelihood;
end
% % log_likelihood_iter
% % likelihood_iter
figure();
plot(log_likelihood_iter,'-*');
xlabel('iterations'); ylabel('log likelihood');
title(['number of states: ', num2str(num_of_state)]);
save HMM;
end

function HMM = EM_initialization_model(HMM, training_file_list, DIM, num_of_state, num_of_model)
sum_of_features = zeros(DIM,1);
sum_of_features_square = zeros(DIM, 1);
num_of_feature = 0;

load (training_file_list, 'trainingfile');
num_of_uter = size(trainingfile,1);

parfor u = 1:num_of_uter
    filename = trainingfile{u,2};
    mfcfile = fopen(filename, 'r', 'b' );
    if mfcfile ~= -1
        nSamples = fread(mfcfile, 1, 'int32');
        sampPeriod = fread(mfcfile, 1, 'int32')*1E-7;
        sampSize =fread(mfcfile, 1, 'int16');
        dim = 0.25*sampSize; % dim = 39
        parmKind = fread(mfcfile, 1, 'int16');
        
        features = fread(mfcfile, [dim, nSamples], 'float');
        
        sum_of_features = sum_of_features + sum(features, 2); % for calculating mean
        sum_of_features_square = sum_of_features_square + sum(features.^2, 2); % for calculating variance
        num_of_feature = num_of_feature + size(features,2); % number of elements (feature vectors) in state m of model k
        
        fclose(mfcfile);
    end
    
end
% calculate value of means, variances, aijs
HMM = calculate_inital_EM_HMM_items(HMM, num_of_state, num_of_model, sum_of_features, sum_of_features_square, num_of_feature);
end



function HMM = calculate_inital_EM_HMM_items(HMM, num_of_state, num_of_model, sum_of_features, sum_of_features_square, num_of_feature)

for k = 1:num_of_model
    for m = 1:num_of_state
        HMM.mean(:,m,k) = sum_of_features/num_of_feature;
        HMM.var(:,m,k) = sum_of_features_square/num_of_feature - HMM.mean(:,m,k).*HMM.mean(:,m,k);
    end
    for i = 2:num_of_state+1
        HMM.Aij(i,i+1,k) = 0.4;
        HMM.Aij(i,i,k) = 1-HMM.Aij(i,i+1,k);
        
    end
    HMM.Aij(1,2,k) = 1;
end
end
