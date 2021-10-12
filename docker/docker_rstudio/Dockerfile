# FROM rocker/rstudio:4.0.5
FROM rocker/rstudio:3.5.1 
 
LABEL maintainer = "Tom Hepworth <thomas.hepworth@justice.gov.uk>"

RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    libssl-dev \
    libssh2-1-dev \
    && rm -rf /var/lib/apt/lists/*
 
RUN Rscript -e "install.packages(c('renv'));"
 
COPY user-settings /home/rstudio/.rstudio/monitored/user-settings/user-settings
# WORKDIR "/home/rstudio/working/"
COPY .Rprofile /home/rstudio/r_projects/

# some extra commands...
# RUN mkdir -p /th-playground
# WORKDIR "/th-playground"
# # initialise renv on load
# RUN R -e "renv::init()"
