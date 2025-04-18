module Rails
  module Hmvc
    module Controllers
      class ApplicationController < ActionController::API
        include Rails::Hmvc::Concerns::Renderable
        include Rails::Hmvc::Concerns::Errorable

        wrap_parameters false

        protected

        def pagination_meta(object)
          {
            current_page: object.current_page,
            next_page: object.next_page,
            prev_page: object.prev_page,
            total_pages: object.total_pages,
            total_count: object.total_count
          }
        end
      end
    end
  end
end
