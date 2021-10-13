import scrapy
from scrapy.loader import ItemLoader
from covid_data_scraper.items import DownloaderItem

class reverse_cohort_scraper(scrapy.Spider):
    name = 'reverse_cohort_scraper'

    start_urls = [
        "https://hmppsintranet.org.uk/ersd-guidance/2020/09/28/heat-map-for-reverse-cohorting-requirements-to-review-regime/"
    ]

    def parse(self, response):
        # pull out the link to our data
        main_url = response.xpath('//*[@id="post-1280"]/div[1]/div/div[2]/a[1]')
        url = main_url.xpath('./@href').get()
        filename = main_url.xpath('./text()').get()
        loader = ItemLoader(item = DownloaderItem(), selector = url)
        # join on the full link path
        absolute_url = response.urljoin(url)
        # and add our item to the loader
        loader.add_value('file_urls', absolute_url)
        loader.add_value('file_name', filename)
        yield loader.load_item()
