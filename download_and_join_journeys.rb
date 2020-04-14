# frozen_string_literal: true

require 'date'
require 'faraday'
require 'pry'
require 'csv'

# Downloads all the Journey CSVs for a given set of cards and a given time frame
# Joining them together into one joined CSV
#

# This should contain a list of all the CardDisplayId parameters which we
# want to pull journeys from.
#
# You should be able to get these by hovering over the links to your cards on
# https://contactless.tfl.gov.uk/MyCards
#
# i.e. Hover on 'Journey & Payment History' and copy that link, add only the
# value for the CardDisplayId query param
#
# Given a link: https://contactless.tfl.gov.uk/NewStatements/Billing?CardDisplayId=XXXXXXXXXXXXX
#
# Copy only the XXXXXXXXXXXXX into this array :D
CARDS = []

START_MONTH = Date.new(2019, 04, 01)
END_MONTH = Date.new(2020, 03, 01)

# This is needed to authenticate you to the tfl website, you can log in via the
# browser and find these in your cookies
COOKIES = {
  'ASP.NET_SessionId' => '',
  'ARRAffinity' => '',
  '.CSCAuth' => ''
}

MONTHS = Enumerator.new do |enum|
  month = START_MONTH
  while month <= END_MONTH
    enum << { year: month.year, month: month.month }
    month = month.next_month
  end
end

def fetch(card:, year:, month:)
  base = "https://contactless.tfl.gov.uk"
  path = "/NewStatements/DownloadJourneyCsv"
  query = "Period=#{month}%7C#{year}&CardDisplayId=#{card}"
  cookie = COOKIES.map { |k, v| "#{k}=#{v};" }.join(" ")

  url = "#{base}#{path}?#{query}"
  Faraday.get(url) do |request|
    request.headers['Cookie'] = cookie
  end
end


def fetch_all
  CARDS.flat_map do |card|
    MONTHS.map do |month|
      response = fetch(card: card, month: month[:month], year: month[:year])

      [response.status, response.body]
    end
  end
end


def fetch_and_dump(path)
  str = CSV.generate do |csv|
    fetch_all.map.with_index do |fetch_result, index|
      status, body, *_ = fetch_result

      if status != 200
        puts "got status #{status} -- skipping."
        puts body

        next
      end

      current_csv = CSV.parse(body)

      current_csv.shift unless index.zero?

      current_csv.each { |row| csv << row }
    end
  end

  File.write(path, str)
end

Pry.start
