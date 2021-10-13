import scrapy
from scrapy.loader import ItemLoader
from covid_data_scraper.items import DownloaderItem
import re
import numpy as np
from itertools import compress

class community_prev_scraper(scrapy.Spider):
    name = 'community_prev_scraper'

    start_urls = [
        "https://www.ons.gov.uk/peoplepopulationandcommunity/healthandsocialcare/conditionsanddiseases/bulletins/coronaviruscovid19infectionsurveypilot/19march2021"
    ]

    def parse(self, response):
        # sends us to the latest HTML publication
        latest_pub = response.xpath('//*[@id="main"]/div[1]/div[2]/div/div/p/a/@href').get()

        yield response.follow(latest_pub, callback=self.parse_latest_pub)

    def parse_latest_pub(self, response):
        # sends us through to the download screen with our backing data
        latest_data = response.xpath('//*[@id="main"]/div[2]/div/div[2]/div/a/@href').get()

        yield response.follow(latest_data, callback=self.parse_latest_data)

    def parse_latest_data(self, response):
        available_files = response.xpath('//*[@id="main"]/div[2]/div/section//h3//span/text()').getall()
        accepted_countries = re.compile('(?i)England|Wales')
        valid_files = [bool(re.search(accepted_countries, l)) for l in available_files]  # this works...
        valid_indices = np.where(valid_files)[0]

        # grab our links
        urls = response.xpath('//*[@id="results"]/div/ul/li//h3/a/@href').getall()
        urls_to_use = list(compress(urls, valid_files))
        # follow our urls
        for url in urls_to_use:
            yield response.follow(url, callback=self.parse_pull_data)


    def parse_pull_data(self, response):
        # this page has some js embedded in it,
        # which means we have to go for the brute force method...
        links_on_page = response.xpath('//*[@id="main"]/div//@href').getall()

        # find the link containing our .xlsx file
        valid_files = [bool(re.search('.xlsx$', l)) for l in links_on_page]  # this works...
        # grab our links
        links_to_download = list(compress(links_on_page, valid_files))

        # pull out the link to our data
        loader = ItemLoader(item = DownloaderItem(), selector = links_to_download[0])
        # join on the full link path
        absolute_url = response.urljoin(links_to_download[0])
        # add our item to the loader
        loader.add_value('file_urls', absolute_url)
        # and finally, extract our filename from our link url and add this to the loader
        loader.add_value('file_name', re.search('([^\/]+$)', links_to_download[0])[0])

        yield loader.load_item()
