import urllib.request
import re
from html.parser import HTMLParser

class Images(HTMLParser):
    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        if tag == 'img':
            print(attrs.get('src'), attrs.get('alt'))

url = 'https://cms-bmco.dmtlph.com/destination/national-capital-region/san-juan/'
request = urllib.request.Request(url, headers={'User-Agent': 'Rehiyonia educational game'})
html = urllib.request.urlopen(request, timeout=25).read().decode()
Images().feed(html)
print('\n'.join(sorted(set(re.findall(r'https?[^\s\"<>\)]+\.(?:jpg|jpeg|webp)', html, flags=re.I)))))
