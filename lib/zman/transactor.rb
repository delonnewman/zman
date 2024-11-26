# frozen_string_literal: true

module Zman
  class Transactor
    def initialize(log)
      @log = log
      @current_tx_id = 0
    end

    def new_tx_id
      @current_tx_id += 1
    end

    def db(asof: nil)
      case asof
      when Date
        Database.new(@log.filter_by_date(asof))
      when Integer
        Database.new(@log.filter_by_transation(asof))
      else
        Database.new(@log)
      end
    end

    def transact(tx)
      tx_id = new_tx_id
      tx.tap do
        tx.actions.each do |action|
          @log.append(tx_id, action)
        end
      end
    end
  end
end
