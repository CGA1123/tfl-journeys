# frozen_string_literal: true

require "csv"

class RowParser
  def initialize(row)
    @row = row
  end

  def parse
    @parse ||= Journey.new(
      date: date,
      start_time: start_time,
      end_time: end_time,
      from: from,
      to: to,
      cost: cost,
      capped: capped,
      notes: notes
    )
  end

  private

  attr_reader :row

  def date
    Date.parse(row['Date'])
  end

  def start_time
    parsed_time.first
  end

  def end_time
    parsed_time.last
  end

  def parsed_time
    row['Time'].split('-').map do |t|
      Time.parse(t)
    rescue
      nil
    end
  end

  def locations
    row['Journey'].split(' to ')
  end

  def from
    locations.first
  end

  def to
    locations.last
  end

  def cost
    Float(row['Charge (GBP)'])
  end

  def capped
    row['Capped'] == 'Y'
  end

  def notes
    row['Notes'] || ""
  end
end
