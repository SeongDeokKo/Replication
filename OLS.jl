
using LinearAlgebra 
using Distributions
function OLS(Y,X ;add_constant = 0 , print = 0 )
    # Input Y : Dependent Variable
    # Input X : Covariates
    # Input add_constant : 1 if we add one vector 
    # Output Estimator      : OLS Estimator 
    # Output SE             : Standard Error 
    # Output SE_robust      : Robust Standard Error 
    # Output sigma2         : Standard Error of Regression
    # Output fitted         : Fitted Value by model 

    Y = reshape(Y,length(Y),1);
    # Reshape data if X is one dimensional vector 
    if ndims(X) == 1
        X = reshape(X,length(X),1);
    end
    
nobs , nvar = size(X);
    
    if add_constant == 1
        X = [ones(nobs,1) X];
        nvar += 1;
    end

df = nobs - nvar;                # Degree of Freedom
XX = X'*X;
estimator = (XX)\(X'*Y);
fitted = X * estimator;
resid = Y - fitted;
SSR = sum(resid.^2);
sigma2 = SSR / (nobs-nvar);
inv_XX = inv(XX);
cov_mat = sigma2*inv_XX ;
SE = sqrt.(diag(cov_mat));

t_stat = estimator ./ SE;

Y_demean = Y .- mean(Y);
R2 = 1-SSR/sum(Y_demean.^2);
log_like = -nobs/2 * (1 + log(2*pi) + log(SSR/nobs) );
DW = sum(diff(resid, dims = 1).^2) ./ SSR; # Durbin Watson 
    if print == 1
    println(" ")
    println("Number of observations   " , nobs  )
    println("Number of regressors     " ,nvar)
    println("result")
        
    println("R-square     :    ", R2)
    println("Variance of s2:    ",sigma2)
    println("Log likelihood:    ",log_like)
    println("D-W statistics:    ",DW)
    end 
    
    return estimator, SE
end
 
