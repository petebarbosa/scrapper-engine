class Api::V1::TasksController < ApplicationController
  def index
    tasks = current_user.tasks
    render json: tasks
  end

  def create
    task = current_user.tasks.build(task_params)

    if task.save
      WebScraperService.new(task).perform_scraping
      render json: task, status: :created
    else
      render json: { errors: task.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def show
    task = current_user.tasks.find(params[:id])
    render json: task
  end

  def update
    task = current_user.tasks.find(params[:id])

    if task.update(task_params)
      render json: task
    else
      render json: { errors: task.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    task = current_user.tasks.find(params[:id])

    if task.delete
      render json: :ok
    else
      render json: { errors: task.errors.full_messages }, status: :unprocessable_entity
    end
  end
  private

  def task_params
    params.require(:task).permit(:name, :description, :url_to_scrape)
  end
end
