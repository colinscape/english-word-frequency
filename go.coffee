#!/usr/bin/env coffee

request = require 'request'
cheerio = require 'cheerio'
_ = require 'underscore'

# Use the index page to find the links to the word lists.
indexPage = "http://en.wiktionary.org/wiki/Wiktionary:Frequency_lists"
request.get indexPage, (err, resp, body) ->
  if err
    console.error err
    return

  # Find the links to the word lists.
  $ = cheerio.load body
  links = $('a').filter (i,a) -> $(a)?.attr('href')?.match /^\/wiki\/Wiktionary:Frequency_lists\/TV\/2006\/[0-9]/
  pages = ("http://en.wiktionary.org#{link.attribs.href}" for link in links)

  # Gather the word lists.
  results = []
  nPending = pages.length
  for page,index in pages
    do (page,index) ->
      request.get {url: page, headers: {'User-Agent': 'Mozilla/5.0 (Windows NT 6.0; WOW64) AppleWebKit/537.11 (KHTML, like Gecko) Chrome/23.0.1271.95 Safari/537.11'}}, (err, resp, body) ->
        --nPending

        if err
          console.error err
          return

        # Find the words.
        $ = cheerio.load body
        links = $('table td a')
        words = ($(link).text() for link in links)
        results[index] = words

        # Output the results.
        if nPending is 0
          results = _.flatten results
          console.log result for result in results


