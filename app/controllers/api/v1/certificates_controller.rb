
module Api
  module V1
    class CertificatesController < ApplicationController
      def show
        certificate = Certificate.find_by(id: params[:id_certificate])

        if certificate
          send_file Rails.root.join('public', 'certificates', "#{certificate.id_certificate}_certificate.png"), type: 'image/png', disposition: 'inline'
        else
          render json: { error: 'Certificate not found' }, status: :not_found
        end
      end
    end
  end 
end 
