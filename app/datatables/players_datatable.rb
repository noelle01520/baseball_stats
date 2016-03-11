require 'open-uri'
require 'active_record'
require 'activerecord-import'

class PlayersDatatable
  delegate :params, :link_to, :number_to_currency, to: :@view

  def initialize(view)
    @view = view
  end

  # Return JSON to controller.
  def as_json(options = {})
    {
        sEcho: params[:sEcho].to_i,
        iTotalRecords: Player.count,
        iTotalDisplayRecords: players.total_entries,
        aaData: data
    }
  end

  private

  # Populate players data
  # If there's no data in the db for selected year
  # call load_data to attempt to load from URL
  def data
    if params[:sSearch].present?
      if Player.where("year=:search", search: "#{params[:sSearch].to_i}").blank?
        load_data(params[:sSearch])
      end
    end

    players.map do |player|
      [
          player.name,
          player.position,
          player.team_name + ' (' + player.team_city + ')',
          player.division,
          player.league,
          player.avg,
          player.home_runs,
          player.rbi,
          player.runs,
          player.stolen_bases,
          player.ops
      ]
    end
  end

  def players
    @players ||= fetch_players
  end

  def fetch_players
    players = Player.order("#{sort_column} #{sort_direction}")
    players = players.page(page).per_page(per_page)
    if params[:sSearch].present?
      players = players.where("year=:search", search: "#{params[:sSearch].to_i}")
    end
    players
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[name position team division league avg home_runs rbi runs stolen_bases ops]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end

  # Attempt to load data for select year by constructing URL
  # using Nokogiri gem to process XML.
  # Save to db in batches of <batch_size> records with activerecord-import..
  # If the URL is not available, return no data.
  def load_data(year)
    batch,batch_size = [], 1_000
    url = 'http://www.cafeconleche.org/examples/baseball/' + year.to_s + 'statistics.xml'

    begin
      data = open(url)
    rescue
      return
    end

    root = Nokogiri::XML(data.read)
    leagues = root.xpath("//LEAGUE")
    leagues.each do |league|
      league_name = league.at_xpath("LEAGUE_NAME").text
      league.xpath("./DIVISION").each do |division|
        division_name = division.at_xpath("DIVISION_NAME").text
        division.xpath("./TEAM").each do |team|
          team_city = team.at_xpath("TEAM_CITY").text
          team_name = team.at_xpath("TEAM_NAME").text
          team.xpath("./PLAYER").each do |player|
            if player.at_xpath("POSITION").text.downcase.include? "pitcher"
              next
            end
            at_bats = player.at_xpath("AT_BATS").text.to_f rescue 0.0
            hits = player.at_xpath("HITS").text.to_f rescue 0.0
            home_runs = player.at_xpath("HOME_RUNS").text.to_f rescue 0.0
            rbi = player.at_xpath("RBI").text.to_f rescue 0.0
            runs = player.at_xpath("RUNS").text.to_f rescue 0.0
            stolen_bases = player.at_xpath("STEALS").text.to_f rescue 0.0
            doubles = player.at_xpath("DOUBLES").text.to_f rescue 0.0
            triples = player.at_xpath("TRIPLES").text.to_f rescue 0.0
            sacrifice_flies = player.at_xpath("SACRIFICE_FLIES").text.to_f rescue 0.0
            walks = player.at_xpath("WALKS").text.to_f rescue 0.0


            player_hash = {
                name: player.at_xpath("SURNAME").text + ', ' + player.at_xpath('GIVEN_NAME').text,
                position: player.at_xpath("POSITION").text,
                team_name: team_name,
                team_city: team_city,
                division: division_name,
                league: league_name,
                year: year,

                avg: calc_avg(hits, at_bats),
                home_runs: home_runs,
                rbi: rbi,
                runs: runs,
                stolen_bases: stolen_bases.to_i,
                ops: (calc_obp(hits, walks, at_bats, sacrifice_flies) + calc_slg(hits, doubles, triples, home_runs, at_bats)).round(2)

            }
            batch << Player.new(player_hash)
            # save after loading limit
            if batch.size  >= batch_size
              Player.import batch
              batch = []
            end
          end
        end
      end
    end
    Player.import batch
  end

  def calc_avg(hits, at_bats)
    if at_bats != 0
      avg = (hits/at_bats).round(3) * 1000
    else
      avg = 0
    end
    avg
  end

  def calc_obp(hits, walks, at_bats, sacrifice_flies)
    if at_bats + walks + sacrifice_flies != 0
      (hits + walks)/(at_bats + walks + sacrifice_flies)
    else
      0
    end
  end

  def calc_slg(hits, doubles, triples, home_runs, at_bats)
    if at_bats != 0
      non_singles = doubles + triples + home_runs
      (((hits - non_singles) + non_singles)/at_bats)
    else
      0
    end
  end
end