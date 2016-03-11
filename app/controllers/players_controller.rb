class PlayersController < ApplicationController

  # Determine year to display and create object to generate
  # JSON data for dataTable.
  def index

    # Array of years that stats are provided for
    years = [1998]

    # If there's only 1 choice load data for that year.
    # If a year was selected display that year.
    # Otherwise load statistics for 1998 by default.

    if years.length == 1
      selected_year = years[0]
    elsif params[:selected_year]
      selected_year = params[:selected_year]
    else
      selected_year = 1998
    end

    @years = years.join(',')
    @selected_year = selected_year

    respond_to do |format|
      format.html
      format.json { render json: PlayersDatatable.new(view_context) }
    end
  end


end
