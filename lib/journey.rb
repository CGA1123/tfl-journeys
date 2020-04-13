# frozen_string_literal: true

require "dry-struct"

class Journey < Dry::Struct
  def self.t
    @t ||= Dry.Types()
  end

  attribute :date, t::Date
  attribute :start_time, t::Time.optional
  attribute :end_time, t::Time.optional
  attribute :from, t::String
  attribute :to, t::String
  attribute :cost, t::Float
  attribute :capped, t::Bool
  attribute :notes, t::String

  def time_in_minutes
    (end_time - start_time) / 60
  end

  def cost_per_minutes
    cost / time_in_minutes
  end
end
