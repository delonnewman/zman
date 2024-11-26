module Zman
  class Log
    def append(tx_id, action)
    end

    def filter_by_date(date)
      self
    end

    def filter_by_transaction(tx_id)
      self
    end
  end
end
