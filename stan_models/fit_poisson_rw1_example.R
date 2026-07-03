# Example: simulate longitudinal Poisson data and fit poisson_rw1_longitudinal.stan
# Requires the cmdstanr package (https://mc-stan.org/cmdstanr/)

library(cmdstanr)

set.seed(123)

J <- 50   # subjects
T <- 8    # time points per subject
K <- 1    # one fixed-effect covariate

sigma_b <- 0.4
sigma_u <- 0.3
beta0 <- 1.0
beta <- c(0.2)

b_j <- rnorm(J, 0, sigma_b)
u_t <- cumsum(c(0, rnorm(T - 1, 0, sigma_u)))

dat <- expand.grid(subject = 1:J, time = 1:T)
dat$x1 <- rnorm(nrow(dat))
eta <- beta0 + beta[1] * dat$x1 + b_j[dat$subject] + u_t[dat$time]
dat$y <- rpois(nrow(dat), lambda = exp(eta))

stan_data <- list(
  N = nrow(dat),
  J = J,
  T = T,
  K = K,
  subject = dat$subject,
  time = dat$time,
  y = dat$y,
  X = matrix(dat$x1, ncol = K)
)

mod <- cmdstan_model("stan_models/poisson_rw1_longitudinal.stan")

fit <- mod$sample(
  data = stan_data,
  chains = 4,
  parallel_chains = 4,
  iter_warmup = 1000,
  iter_sampling = 1000,
  seed = 123
)

fit$summary(c("beta0", "beta", "sigma_b", "sigma_u"))
