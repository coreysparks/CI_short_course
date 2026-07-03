// Longitudinal Poisson model with a random walk 1 (RW1) random effect
// log(mu_n) = beta0 + X_n * beta + b_subject[n] + u_time[n]
//   b_j  ~ normal(0, sigma_b)      subject-specific random intercept
//   u_t  ~ RW1(sigma_u)            u_t - u_{t-1} ~ normal(0, sigma_u), u_1 fixed to 0

data {
  int<lower=1> N;                 // number of observations (subject-time rows)
  int<lower=1> J;                 // number of subjects
  int<lower=1> T;                 // number of distinct time points
  int<lower=1> K;                 // number of fixed-effect covariates (0 is fine)

  array[N] int<lower=1, upper=J> subject;  // subject index for row n
  array[N] int<lower=1, upper=T> time;     // time index for row n
  array[N] int<lower=0> y;                 // count outcome

  matrix[N, K] X;                 // fixed-effect design matrix
}

parameters {
  real beta0;                     // intercept
  vector[K] beta;                 // fixed-effect coefficients

  vector[J] b_raw;                // non-centered subject random intercepts
  real<lower=0> sigma_b;

  vector[T - 1] u_raw;            // non-centered RW1 innovations
  real<lower=0> sigma_u;
}

transformed parameters {
  vector[J] b = b_raw * sigma_b;

  vector[T] u;
  u[1] = 0;                       // anchor: RW1 is non-identified without a reference point
  for (t in 2:T) {
    u[t] = u[t - 1] + u_raw[t - 1] * sigma_u;
  }
}

model {
  vector[N] eta = beta0 + X * beta + b[subject] + u[time];

  // priors
  beta0 ~ normal(0, 5);
  beta ~ normal(0, 2);

  b_raw ~ normal(0, 1);
  sigma_b ~ normal(0, 1);

  u_raw ~ normal(0, 1);
  sigma_u ~ normal(0, 1);

  y ~ poisson_log(eta);
}

generated quantities {
  vector[N] log_lik;
  array[N] int y_rep;
  {
    vector[N] eta = beta0 + X * beta + b[subject] + u[time];
    for (n in 1:N) {
      log_lik[n] = poisson_log_lpmf(y[n] | eta[n]);
      y_rep[n] = poisson_log_rng(eta[n]);
    }
  }
}
