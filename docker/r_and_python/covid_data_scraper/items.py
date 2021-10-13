import scrapy
from scrapy.loader.processors import TakeFirst, MapCompose
import os

def remove_extension(value):
    #filename.extension
    return os.path.splitext(value)[0]

class DownloaderItem(scrapy.Item):
    file_urls = scrapy.Field()
    files = scrapy.Field()
    file_name = scrapy.Field(
        input_processor = MapCompose(remove_extension),
        output_processor = TakeFirst()
    )
