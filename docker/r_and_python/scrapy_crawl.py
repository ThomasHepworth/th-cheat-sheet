import os

def run_r():
    print("Running R Scripts!")
    os.system("r r_files/global.R")


print("Running python!")
import scrapy
from scrapy.crawler import CrawlerProcess
from scrapy.settings import Settings
from covid_data_scraper import settings as my_settings

# import spiders
from covid_data_scraper.spiders.reverse_cohort_scraper import reverse_cohort_scraper
from covid_data_scraper.spiders.community_prev_scraper import community_prev_scraper

if __name__ == "__main__":
    run_r() # run our r scripts
    # setup custom scraper settings
    crawler_settings = Settings()
    crawler_settings.setmodule(my_settings)
    process = CrawlerProcess(settings=crawler_settings)

    process.crawl(reverse_cohort_scraper)
    process.crawl(community_prev_scraper)
    process.start() # the script will block here until all crawling jobs are finished
