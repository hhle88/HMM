function fopt = viterbi_dist_FR(mean, var, aij, obs)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Min-Lee Lee, Hoang-Hiep Le
% EE Department, Dayeh University
% viterbi algorithm for full frame (FR) case, version 1 (2017-08-25)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% an example:
if nargin==0
    mean = [[10; 5] [0; 2] [0; 9]];
    var = [[1; 1] [1; 1] [1; 1]];
    obs = [[8; 0] [8; 2] [4; 2] [2; 10] [3;5] [7;9]];
    A = [ 0    1    0    0    0
        0  0.5  0.5    0    0
        0    0  0.5  0.5    0
        0    0    0  0.5  0.5
        0    0    0    0    1];
    aij = cat(3,A,A*A,A*A*A); % for loss frame case
end

[dim, t_len] = size(obs);
mean = [NaN(dim,1) mean NaN(dim,1)];
var = [NaN(dim,1) var NaN(dim,1)];
aij(end,end) = 1;
timing = 1:t_len+1;
m_len = size(mean, 2);
fjt = -Inf(m_len, t_len);
s_chain = cell(m_len, t_len);

%%%%%% at t = 1
dt = timing(1);
for j=2:m_len-1 % 2->14
    fjt(j,1) = log(aij(1,j,dt)) + logGaussian(mean(:,j),var(:,j),obs(:,1));
    if fjt(j,1) > -Inf
        s_chain{j,1} = [1 j];
    end
end

for t=2:t_len
    dt = timing(t)-timing(t-1);
    for j=2:m_len-1 %(2->14)
        f_max = -Inf;
        i_max = -1;
        f = -Inf;
        for i=2:j
            if(fjt(i,t-1) > -Inf)
                f = fjt(i,t-1) + log(aij(i,j,dt)) + logGaussian(mean(:,j),var(:,j),obs(:,t));
            end
            if f > f_max % finding the f max
                f_max = f;
                i_max = i; % index
            end
        end
        if i_max ~= -1
            s_chain{j,t} = [s_chain{i_max,t-1} j];
            fjt(j,t) = f_max;
        end
    end
end
%%%%%% at t = end
dt = timing(end) - timing(end - 1);
fopt = -Inf;
iopt = -1;
for i=2:m_len-1
    f = fjt(i, t_len) + log(aij(i, m_len, dt));
    if f > fopt
        fopt = f;
        iopt = i;
    end
end
%%%%%% optimal result
% fjt
% fopt
if iopt ~=-1
    chain_opt = [s_chain{iopt,t} m_len];
end
end
function log_b = logGaussian (mean_i, var_i, o_i)
dim = length(var_i);
log_b = -1/2*(dim*log(2*pi) + sum(log(var_i)) + sum((o_i - mean_i).*(o_i - mean_i)./var_i));
end
