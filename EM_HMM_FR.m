function [mean_numerator, var_numerator, aij_numerator, denominator, log_likelihood, likelihood] = EM_HMM_FR(mean, var, aij, obs)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Min-Lee Lee, Hoang-Hiep Le
% EE Department, Dayeh University
% EM algorithm for full frame (FR) case, version 1 (2017-08-25)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin==0
    load mean;
    load var;
    load aij;
    load obs;
end
[dim, T] = size(obs); % T: length of observations or number of observation frames
mean = [NaN(dim,1) mean NaN(dim,1)];
var = [NaN(dim,1) var NaN(dim,1)];
aij(end,end) = 1;
N = size(mean, 2); % number of states, including START and END states (nodes) in HMM
log_alpha = -Inf(N, T+1); % initialization 
log_beta = -Inf(N, T+1);  % initialization 

%% calculate alpha ( log(alpha), in fact), !!! notice alpha(1:state_NO, 1:T+1)
for i = 1:N % from state 1 (START) to END at time step 1
    log_alpha(i,1) = log(aij(1,i)) + logGaussian(mean(:,i),var(:,i),obs(:,1)); % log(alpha)
end

for t = 2:T % calculate alpha
    for j = 2:N-1    
        log_alpha(j,t) = log_sum_alpha(log_alpha(2:N-1,t-1),aij(2:N-1,j)) + logGaussian(mean(:,j),var(:,j),obs(:,t));
    end
end

log_alpha(N,T+1) = log_sum_alpha(log_alpha(2:N-1,T),aij(2:N-1,N)); % this value is  P(o1, o2,... , oT | lamda) also

%% calculate beta   (end,end)= (state_NO,T+1), !!! notice beta(1:state_NO, 0:T)
% beta(end,end) = 0; % not used
log_beta(:,T) = log(aij(:,N));
for t = T-1:-1:1 % calculate beta
    for i = 2:N-1
        log_beta(i,t) = log_sum_beta(aij(i,2:N-1),mean(:,2:N-1),var(:,2:N-1),obs(:,t+1),log_beta(2:N-1,t+1));
    end
end
log_beta(N,1) = log_sum_beta(aij(1,2:N-1),mean(:,2:N-1),var(:,2:N-1),obs(:,1),log_beta(2:N-1,1));

%% calculate Xi(1:N, 1:N, 0:T)
log_Xi = -Inf(N,N,T);
for t = 1:T-1
    for j = 2:N-1
        for i = 2:N-1
            log_Xi(i,j,t) = log_alpha(i,t) + log(aij(i,j)) + logGaussian(mean(:,j),var(:,j),obs(:,t+1)) + log_beta(j,t+1) - log_alpha(N,T+1);
        end
    end
end
%%% when t=T;
for i = 1:N
    log_Xi(i,N,T) = log_alpha(i,T) + log(aij(i,N)) - log_alpha(N, T+1);
end
%%% when t=0 -> not used
% for j = 1:N
%     log_Xi(1,j,0) = log_alpha(1,j) + log_beta(j,1) - log_alpha(N, T+1);
% end

%% calculate gamma
log_gamma = -inf(N,T);
for t = 1:T
    for i = 2:N-1
        log_gamma(i,t) = log_alpha(i,t) + log_beta(i,t) - log_alpha(N,T+1);
    end
end
gamma = exp(log_gamma);

%% calculate sum of mean_numerator, var_numerator, aij_numerator and denominator (single data)
mean_numerator = zeros(dim,N); 
var_numerator = zeros(dim,N);
denominator = zeros(N,1);
aij_numerator = zeros(N,N);
for j = 2:N-1
    for t = 1:T
        mean_numerator(:,j) = mean_numerator(:,j) + gamma(j,t)*obs(:,t);
%         var_numerator(:,j) = var_numerator(:,j)+ gamma(j,t)*(obs(:,t)-mean(:,j)).^2;
        var_numerator(:,j) = var_numerator(:,j)+ gamma(j,t)*(obs(:,t)).*(obs(:,t));
        denominator(j) = denominator(j) + gamma(j,t);
    end  
end
for i = 2:N-1
    for j = 2:N-1
        for t = 1:T
            aij_numerator(i,j) = aij_numerator(i,j) + exp(log_Xi(i,j,t));
        end
    end
end

log_likelihood = log_alpha(N,T+1);
likelihood = exp(log_alpha(N,T+1));

end

function log_b = logGaussian (mean_i, var_i, o_i)
dim = length(var_i);
log_b = -1/2*(dim*log(2*pi) + sum(log(var_i)) + sum((o_i - mean_i).*(o_i - mean_i)./var_i));
end

function logsumalpha = log_sum_alpha(log_alpha_t,aij_j)
len_x = size(log_alpha_t,1);
y = -Inf(1,len_x);
ymax = -Inf;
for i = 1:len_x
    y(i) = log_alpha_t(i) + log(aij_j(i));
    if y(i) > ymax
        ymax = y(i);
    end
end
if ymax == Inf;
    logsumalpha = Inf;
else
    sum_exp = 0;
    for i = 1:len_x
        if ymax == -Inf && y(i) == -Inf
            sum_exp = sum_exp + 1;
        else
            sum_exp = sum_exp + exp(y(i) - ymax);
        end
    end
    logsumalpha = ymax + log(sum_exp);
end
end

function logsumbeta = log_sum_beta(aij_i,mean,var,obs,beta_t1)
len_x = size(mean,2); % number of state
y = -Inf(1,len_x);
ymax = -Inf;
for j = 1:len_x
    y(j) = log(aij_i(j)) + logGaussian(mean(:,j),var(:,j),obs) + beta_t1(j);
    if y(j) > ymax
        ymax = y(j);
    end
end
if ymax == Inf
    logsumbeta = Inf;
else
    sum_exp = 0;
    for i = 1:len_x
        if ymax == -Inf && y(i) == -Inf
            sum_exp = sum_exp + 1;
        else
            sum_exp = sum_exp + exp(y(i) - ymax);
        end
    end
    logsumbeta = ymax + log(sum_exp);
end
end
