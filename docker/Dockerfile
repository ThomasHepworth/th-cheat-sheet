# Base image https://hub.docker.com/u/rocker/
# FROM rocker/r-base:latest
# R 3.5.1 - renv steps need adjusting for this image to work (need to remote install curl with conda or remotes)
# FROM rocker/shiny@sha256:761711ab26348e324df8e657647ea221f5e28a6d13d7bb57fdaf02ce2bd725b1
# R 4.0.5
FROM rocker/shiny@sha256:c80faec93eaca29a35706e830d9ed4ba8fb9a238535127a148f7b06fda6037c9

# trial installing renv using Sam's dockerfile...
# CMD bash
CMD ./run.sh

# use renv for packages
ADD renv.lock renv.lock
RUN R -e "install.packages('renv')"
RUN R -e 'renv::restore()'

COPY . .
# Run the script
CMD Rscript testing.R
