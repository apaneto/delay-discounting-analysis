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
  vector[nRealExperimentFiles] m;
  vector[nRealExperimentFiles] c;
  vector<lower=0>[nRealExperimentFiles] alpha;
  vector<lower=0,upper=0.5>[nRealExperimentFiles] epsilon;
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
  m        ~ normal(-0.243, 0.5);
  c        ~ normal(0, 10);
  epsilon  ~ beta(1.1, 10.9);
  alpha    ~ exponential(0.01);

  R ~ bernoulli(P);
}

generated quantities { // see page 76 of manual // NO VECTORIZATION IN THIS BLOCK
  int <lower=0,upper=1> Rpostpred[totalTrials];

  for (t in 1:totalTrials){
    Rpostpred[t] = bernoulli_rng(P[t]);
  }
}
