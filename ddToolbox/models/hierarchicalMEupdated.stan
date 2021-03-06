functions {
  real psychometric_function(real alpha, real epsilon, real VA, real VB){
    // returns probability of choosing B (delayed reward)
    return epsilon + (1-2*epsilon) * Phi( (VB-VA) / alpha);
  }

  vector magnitude_effect(vector m, vector c, vector reward){
    return m .* log(reward) + c; // we assume reward is positive
  }

  vector df_hyperbolic1(vector reward, vector logk, vector delay){
    return reward ./ (1+(exp(logk).*delay));
  }
}

data {
  int <lower=1> totalTrials;
  int <lower=1> nRealExperimentFiles;
  vector[totalTrials] A;
  vector[totalTrials] B;
  vector<lower=0>[totalTrials] DA;
  vector<lower=0>[totalTrials] DB;
  int <lower=0,upper=1> R[totalTrials];
  int <lower=0,upper=nRealExperimentFiles> ID[totalTrials];
}

transformed data {
  vector[totalTrials] Aabs;
  vector[totalTrials] Babs;
  for (t in 1:totalTrials){
    Aabs[t] = fabs(A[t]);
    Babs[t] = fabs(B[t]);
  }
}

parameters {
  real m_mu;
  real <lower=0> m_sigma;
  vector[nRealExperimentFiles+1] m;

  real c_mu;
  real <lower=0> c_sigma;
  vector[nRealExperimentFiles+1] c;

  real alpha_mu;
  real <lower=0> alpha_sigma;
  vector<lower=0>[nRealExperimentFiles+1] alpha;

  real <lower=0,upper=1> omega;
  real <lower=0> kappa;
  vector<lower=0,upper=0.5>[nRealExperimentFiles+1] epsilon;
}

transformed parameters {
  vector[totalTrials] logkA;
  vector[totalTrials] logkB;
  vector[totalTrials] VA;
  vector[totalTrials] VB;
  vector[totalTrials] P;

  logkA = magnitude_effect(m[ID], c[ID], Aabs);
  logkB = magnitude_effect(m[ID], c[ID], Babs);
  VA = df_hyperbolic1(A, logkA, DA);
  VB = df_hyperbolic1(B, logkB, DB);

  for (t in 1:totalTrials){
    P[t]     = psychometric_function(alpha[ID[t]], epsilon[ID[t]], VA[t], VB[t]);
  }
}

model {
  m_mu        ~ normal(-0.243, 0.27);
  m_sigma     ~ normal(0,5);
  m           ~ normal(m_mu, m_sigma);

  c_mu        ~ normal(0, 100);
  c_sigma     ~ normal(0,10);
  c           ~ normal(c_mu, c_sigma);

  alpha_mu    ~ exponential(0.01);
  alpha_sigma ~ normal(0,5);
  alpha       ~ normal(alpha_mu, alpha_sigma);

  omega       ~ beta(1.1, 10.9);  // mode for lapse rate
  kappa       ~ gamma(0.01, 0.01); // concentration parameter
  epsilon     ~ beta(omega*(kappa-2)+1 , (1-omega)*(kappa-2)+1 );

  R ~ bernoulli(P);
}

generated quantities { // see page 76 of manual // NO VECTORIZATION IN THIS BLOCK
  int <lower=0,upper=1> Rpostpred[totalTrials];
  for (t in 1:totalTrials){
    Rpostpred[t] = bernoulli_rng(P[t]);
  }
}
