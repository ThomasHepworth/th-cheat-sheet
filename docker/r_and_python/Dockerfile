# FROM rocker/r-base:4.0.5
FROM rocker/r-base:3.6.3

RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		libcurl4-openssl-dev \
		libssl-dev \
		procps \
        libxml2 \
        libxslt-dev \
    && apt-get install -y python3 python3-pip \
	&& rm -rf /var/lib/apt/lists/* \
	&& rm -rf /tmp/downloaded_packages/ /tmp/*.rds

# Deal with pydbtools issue
RUN pip install --upgrade pip
RUN pip install --upgrade pip setuptools
RUN pip install pydbtools==1.0.1
COPY requirements.txt .
RUN pip3 install -r requirements.txt

# Install renv then our package list from renv.lock
RUN R -e 'install.packages("renv", repos="http://cran.us.r-project.org")'

# run renv::restore() to get our package list
WORKDIR /project
COPY renv.lock renv.lock
RUN R -e 'renv::restore()'

# COPY r_files/ r_files/
ADD . /project
  
# Run script
CMD python3 -u scrapy_crawl.py
