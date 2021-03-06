module Locomotive
  module Routing
    module SiteDispatcher

      extend ActiveSupport::Concern

      included do
        if self.respond_to?(:before_filter)
          before_filter :fetch_site

          helper_method :current_site
        end
      end

      module InstanceMethods

        protected

        def fetch_site
          Locomotive.logger "[fetch site] host = #{request.host} / #{request.env['HTTP_HOST']}"
          @current_site ||= Site.match_domain(request.host).first
        end

        def current_site
          @current_site || fetch_site
        end

        def require_site
          return true if current_site

          redirect_to admin_installation_url and return false if Account.count == 0 || Site.count == 0

          render_no_site_error and return false
        end

        def render_no_site_error
          render :template => "/admin/errors/no_site", :layout => false
        end

        def validate_site_membership
          return if current_site && current_site.accounts.include?(current_admin)
          sign_out_and_redirect(current_admin)
        end

      end

    end
  end
end
