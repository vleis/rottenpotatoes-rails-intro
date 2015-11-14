class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    if !params[:sort] && session[:sort] && !params[:ratings] && session[:ratings]
      redirect = true
    end
    
    redirect_to movies_path(:sort => session[:sort], :ratings => session[:ratings]) if redirect
    
    @sorting = params[:sort] || session[:sort]
    if !params[:ratings] || params[:ratings].keys.empty?
      @ratings = session[:ratings]
    else
      @ratings = params[:ratings]
    end
    
    Rails.logger.info("Sorting: #{@sorting}")
    @movies = Movie.all.where(:rating => (!@ratings || @ratings.keys.empty? ? Movie.all_ratings : @ratings.keys)).order(@sorting)
    @all_ratings = Movie.all_ratings
    session[:sort] = @sorting
    session[:ratings] = @ratings || Hash[Movie.all_ratings.zip([1])]
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
