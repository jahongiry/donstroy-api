# app/controllers/api/v1/students_controller.rb
module Api
  module V1
    class StudentsController < ApplicationController
      before_action :set_student, only: [:show, :update, :destroy]

      # GET /students
      def index
        @students = Student.includes(:course).all
        render json: @students, include: { course: { only: [:name] } }
      end

      # GET /students/1
      def show
        render json: @student, include: { course: { only: [:name] } }
      end

      # POST /students
      def create
        @student = Student.new(student_params)

        if @student.save
          render json: @student, status: :created
        else
          render json: @student.errors, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /students/1
      def update
        if @student.update(student_params)
          render json: @student
        else
          render json: @student.errors, status: :unprocessable_entity
        end
      end

      # DELETE /students/1
      def destroy
        @student.destroy
      end

      private
        # Use callbacks to share common setup or constraints between actions.
        def set_student
          @student = Student.find(params[:id])
        end

        # Only allow a list of trusted parameters through.
      def student_params
        params.require(:student).permit(:name, :course_id, :certificate_date, :hour, :level, :control, :passport)
      end
    end
  end
end
