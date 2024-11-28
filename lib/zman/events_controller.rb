module Zman
  class EventsController
    def initialize(request)
      @request = request
    end

    def list
      events.all
    end

    def show
      events.find(params[:id])
    end

    def create
      errors = Event.validate(params[:event])

      if errors.empty?
        events.add(Event.new(params[:event]))
      else
        errors
      end
    end

    private

    def events
      @events ||= EventsRepository.new(Zman.db)
    end
  end
end
