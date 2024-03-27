module Api
  module V1
    class CoursesController < ApplicationController
      before_action :set_course, only: [:show, :update, :destroy]

      # GET /courses
      def index
        @courses = Course.all
        render json: @courses
      end

      # GET /courses/1
      def show
        render json: @course
      end

   # POST /courses
      def create
        if params[:course].present? && params[:course][:images].present?
          uploaded_images = Array(params[:course][:images])
          puts uploaded_images.length
          images = save_uploaded_images(uploaded_images)
          @course = Course.new(course_params.except(:images))
          @course.images = images
        else
          @course = Course.new(course_params)
        end

        if @course.save
          render json: @course, status: :created
        else
          render json: @course.errors, status: :unprocessable_entity
        end
      end


      # PATCH/PUT /courses/1
      def update
        if @course.update(course_params)
          render json: @course
        else
          render json: @course.errors, status: :unprocessable_entity
        end
      end

      # DELETE /courses/1
      def destroy
        @course.destroy
      end

      private
      # Use callbacks to share common setup or constraints between actions.
      def set_course
        @course = Course.find(params[:id])
      end

      # Only allow a list of trusted parameters through.
      def course_params
        params.require(:course).permit(:name, :description, :teacher, images: [])
      end
      
    # Helper method to save uploaded images
      def save_uploaded_images(uploaded_images)
        images = []

        uploaded_images.each do |uploaded_image|
          # Generate a unique filename for the uploaded image
          filename = "#{SecureRandom.hex(10)}_#{uploaded_image.original_filename}"

          # Specify the directory where you want to save the uploaded images
          upload_directory = Rails.root.join('public', 'uploads', 'courses')

          # Ensure that the directory exists, otherwise create it
          FileUtils.mkdir_p(upload_directory) unless File.directory?(upload_directory)

          file_path = File.join(upload_directory, filename)

          File.open(file_path, 'wb') do |file|
            file.write(uploaded_image.read)
          end

          images << "/uploads/courses/#{filename}"
        end
        images
      end


    end
  end 
end
