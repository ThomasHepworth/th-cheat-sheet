FROM rocker/rstudio:4.0.5
# FROM rocker/rstudio:3.5.1
 
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
    && apt-get install -y python3 python3-pip \
    && apt install python3.8-venv \
    && rm -rf /var/lib/apt/lists/*
 
# RUN Rscript -e "install.packages(c('renv', 'devtools'));"
RUN R -e 'install.packages("https://cran.r-project.org/src/contrib/Archive/renv/renv_0.13.1.tar.gz")'
RUN Rscript -e "install.packages(c('devtools'));"
 
COPY user-settings /home/rstudio/.rstudio/monitored/user-settings/user-settings
COPY .Rprofile /home/rstudio/
COPY .gitignore /home/rstudio/

# some extra commands...
# RUN mkdir -p /th-playground
# WORKDIR "/th-playground"
# # initialise renv on load
# RUN R -e "renv::init()"
